// lib/ui/question_screen.dart
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:vokabeltrainer_app/core/level_manager.dart';
import 'package:vokabeltrainer_app/core/question_generator.dart';

class QuestionScreen extends StatefulWidget {
  /// Sprache der Ausgangswörter (z. B. „en“)
  final String source;
  /// Sprache der Lern-/Zielwörter (z. B. „de“)
  final String target;

  const QuestionScreen({
    Key? key,
    required this.source,
    required this.target,
  }) : super(key: key);

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  // ───────────────── Lern-Logik ─────────────────
  late final LevelManager _manager = LevelManager();
  late Question _question;

  bool _awaitWrong   = false;
  bool _awaitLevelUp = false;
  int? _wrongIndex;

  // ───────────────── Bild-Blur ─────────────────
  static const double _maxBlur = 30.0;
  double _blur = _maxBlur;
  ImageProvider? _levelImg;

  bool   _loadError = false;
  String _errorMsg  = '';

  // ───────────────── Text-to-Speech ─────────────────
  final FlutterTts _tts = FlutterTts();
  String _currentLocale = '';
  bool   _ttsReady      = false;
  bool   _autoTts       = true;

  // erzeugt einen ISO-Code wie „de-DE“ oder „en-US“
  String _langToLocale(String lang) {
    lang = lang.toLowerCase();
    if (lang.startsWith('de')) return 'de-DE';
    if (lang.startsWith('en')) return 'en-US';
    if (lang.startsWith('es')) return 'es-ES';
    if (lang.startsWith('fr')) return 'fr-FR';
    return 'en-US'; // fallback
  }

  Future<void> _ensureLocale(String locale) async {
    if (locale == _currentLocale) return;
    try {
      await _tts.setLanguage(locale);
      _currentLocale = locale;

      // angenehme Stimme der gewünschten Sprache wählen
      final voicesDynamic = await _tts.getVoices;
      if (voicesDynamic is List) {
        final voices = voicesDynamic
            .whereType<Map>()
            .map((m) => Map<String, String>.from(m))
            .where((v) => (v['locale'] ?? '').startsWith(locale))
            .toList();
        if (voices.isNotEmpty) {
          Map<String, String>? pleasant;
          for (final v in voices) {
            final n = (v['name'] ?? '').toLowerCase();
            if (n.contains('female') || n.contains('woman') ||
                n.contains('neural') || n.contains('natural')) {
              pleasant = v;
              break;
            }
          }
          pleasant ??= voices.first;
          await _tts.setVoice(pleasant);
        }
      }
    } catch (e) {
      debugPrint('TTS-Locale-Wechsel fehlgeschlagen: $e');
    }
  }

  Future<void> _speak(String text) async {
    if (!_ttsReady) return;
    final locale = _langToLocale(widget.target);     // ► Ziel-Sprache!
    await _ensureLocale(locale);
    try {
      await _tts.stop();
      await _tts.speak(text);
    } catch (_) {}
  }

  Future<void> _speakIfNeeded() =>
      _autoTts ? _speak(_question.prompt) : Future.value();

  // ───────────────── Init ─────────────────
  @override
  void initState() {
    super.initState();
    _initTts();
    _initManager();
  }

  Future<void> _initTts() async {
    await _ensureLocale(_langToLocale(widget.target));
    await _tts.setSpeechRate(0.45);
    await _tts.setPitch(1.0);
    if (mounted) setState(() => _ttsReady = true);
  }

  Future<void> _initManager() async {
    try {
      await _manager.init();
      _levelImg = AssetImage('assets/images/${_manager.level}.jpg');
      _question = _manager.nextQuestion();

      _manager.onWrong   = () => setState(() => _blur = _maxBlur);
      _manager.onLevelUp = () {
        final prev = (_manager.level - 1).clamp(1, _manager.level);
        setState(() {
          _awaitLevelUp = true;
          _blur         = 0;
          _levelImg     = AssetImage('assets/images/$prev.jpg');
        });
      };

      setState(() {});
      _speakIfNeeded();
    } catch (e, st) {
      debugPrint('Init-Fehler: $e\n$st');
      setState(() {
        _loadError = true;
        _errorMsg  = e.toString();
      });
    }
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  // ───────────────── Antwort-Logik ─────────────────
  void _check(int idx) {
    if (_awaitWrong || _awaitLevelUp) return;

    final ok = _manager.answer(_question, idx);
    if (ok) {
      if (_awaitLevelUp) return;
      setState(() {
        _blur       = _maxBlur * (1 - _manager.streak / LevelManager.levelGoal);
        _question   = _manager.nextQuestion();
        _wrongIndex = null;
      });
      _speakIfNeeded();
    } else {
      setState(() {
        _wrongIndex = idx;
        _awaitWrong = true;
      });
    }
  }

  void _nextWrong() {
    setState(() {
      _blur       = _maxBlur * (1 - _manager.streak / LevelManager.levelGoal);
      _question   = _manager.nextQuestion();
      _awaitWrong = false;
      _wrongIndex = null;
    });
    _speakIfNeeded();
  }

  void _nextLevel() {
    setState(() {
      _blur        = _maxBlur;
      _levelImg    = AssetImage('assets/images/${_manager.level}.jpg');
      _question    = _manager.nextQuestion();
      _awaitLevelUp = false;
      _wrongIndex  = null;
    });
    _speakIfNeeded();
  }

  // ───────────────── TTS-Popup ─────────────────
  void _showTtsPopup() => showDialog(
    context: context,
    builder: (c) => AlertDialog(
      title: const Text('Vorlese-Einstellungen'),
      content: StatefulBuilder(
        builder: (ctx, setLocal) => SwitchListTile(
          title: const Text('Automatisch vorlesen'),
          value: _autoTts,
          onChanged: (v) {
            setLocal(() => _autoTts = v);
            setState(() => _autoTts = v);
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: Navigator.of(c).pop,
          child: const Text('OK'),
        ),
      ],
    ),
  );

  // ───────────────── Build ─────────────────
  @override
  Widget build(BuildContext context) {
    if (_loadError) {
      return Scaffold(
        appBar: AppBar(title: const Text('Fehler')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Daten konnten nicht geladen werden.\n'
                      'Stimmen die Asset-Pfade (pubspec.yaml)?',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(_errorMsg, textAlign: TextAlign.center),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _loadError = false;
                      _blur      = _maxBlur;
                    });
                    _initManager();
                  },
                  child: const Text('Erneut versuchen'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_levelImg == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_awaitLevelUp) {
      return Scaffold(
        appBar: AppBar(title: Text('Level ${_manager.level - 1} geschafft!')),
        body: SafeArea(
          child: Column(
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Image(image: _levelImg!, fit: BoxFit.cover),
              ),
              const SizedBox(height: 24),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Super gemacht! Tippe auf „Weiter“, um das nächste Level zu starten.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: ElevatedButton(
                  onPressed: _nextLevel,
                  child: const Text('Weiter'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Level ${_manager.level} – Streak '
              '${_manager.streak}/${LevelManager.levelGoal}',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: _showTtsPopup,
            tooltip: 'Einstellungen',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Bild
            AspectRatio(
              aspectRatio: 16 / 9,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: _blur, sigmaY: _blur),
                child: Image(
                  image: _levelImg!,
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ),
            ),
            // Vokabel + Lautsprecher
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      _question.prompt,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    iconSize: 32,
                    icon: const Icon(Icons.volume_up),
                    tooltip: 'Aussprache anhören',
                    onPressed: () => _speak(_question.prompt),
                    onLongPress: _showTtsPopup,
                  ),
                ],
              ),
            ),
            // Antwort-Buttons
            ..._question.options.asMap().entries.map((e) {
              final i   = e.key;
              final txt = e.value;

              Color? bg;
              if (_awaitWrong) {
                if (i == _question.correctIndex) bg = Colors.green;
                if (i == _wrongIndex)            bg = Colors.red;
              }

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: bg,
                    minimumSize: const Size.fromHeight(56),
                  ),
                  onPressed: () => _check(i),
                  child: Text(txt, style: const TextStyle(fontSize: 18)),
                ),
              );
            }),
            if (_awaitWrong)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: ElevatedButton(
                  onPressed: _nextWrong,
                  child: const Text('Weiter'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
