// lib/ui/question_screen.dart
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:vokabeltrainer_app/core/level_manager.dart';
import 'package:vokabeltrainer_app/core/question_generator.dart';

class QuestionScreen extends StatefulWidget {
  final String source;   // z. B. 'de'
  final String target;   // z. B. 'en'

  const QuestionScreen({
    Key? key,
    required this.source,
    required this.target,
  }) : super(key: key);

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  // ─────────────────────────────  Lern-Logik  ─────────────────────────────
  late final LevelManager _manager = LevelManager();
  late Question           _question;

  bool _awaitWrong   = false;
  bool _awaitLevelUp = false;
  int? _wrongIndex;

  // ─────────────────────────────  UI-State  ───────────────────────────────
  static const double _maxBlur = 30;
  double        _blur     = _maxBlur;
  ImageProvider? _levelImg;

  bool   _loadError = false;
  String _errorMsg  = '';

  // ─────────────────────────────  Text-to-Speech  ─────────────────────────
  final FlutterTts _tts = FlutterTts();
  bool _ttsReady = false;
  bool _autoTts  = true;

  // ───────────────────────────── Lifecycle ────────────────────────────────
  @override
  void initState() {
    super.initState();
    _initTts();
    _initManager();
  }

  /// lädt Wortliste + richtet Callbacks ein
  Future<void> _initManager() async {
    try {
      await _manager.init();                                // CSV laden
      _levelImg = AssetImage('assets/images/${_manager.level}.jpg');
      _question = _manager.nextQuestion();

      // Callbacks **erst nach** erfolgreichem Init setzen
      _manager.onWrong   = () => setState(() => _blur = _maxBlur);
      _manager.onLevelUp = () {
        final prev = (_manager.level - 1).clamp(1, _manager.level);
        setState(() {
          _awaitLevelUp = true;
          _blur         = 0;
          _levelImg     = AssetImage('assets/images/$prev.jpg');
        });
      };

      setState(() {});          // Spinner beenden
      _speakIfNeeded();
    } catch (e, st) {
      debugPrint('LevelManager-Init fehlgeschlagen: $e\n$st');
      setState(() {
        _loadError = true;
        _errorMsg  = e.toString();
      });
    }
  }

  /// richtet TTS ein – robust gegen fehlende Stimmen / Netzwerk-Fehler
  Future<void> _initTts() async {
    try {
      await _tts.setLanguage(_detectLocale());
      await _tts.setSpeechRate(0.45);
      await _tts.setPitch(1.0);

      final voicesDyn = await _tts.getVoices;
      if (voicesDyn is List) {
        final voices = voicesDyn
            .whereType<Map>()
            .map((m) => Map<String, String>.from(m))
            .toList();
        Map<String, String>? pleasant;
        for (final v in voices) {
          final n = (v['name'] ?? '').toLowerCase();
          if (n.contains('female') || n.contains('woman') ||
              n.contains('neural') || n.contains('natural')) {
            pleasant = v;
            break;
          }
        }
        pleasant ??= voices.isNotEmpty ? voices.first : null;
        if (pleasant != null) await _tts.setVoice(pleasant);
      }
    } catch (e) {
      debugPrint('TTS-Init-Fehler: $e');
    } finally {
      if (mounted) setState(() => _ttsReady = true);
    }
  }

  String _detectLocale() =>
      widget.source.toLowerCase().startsWith('en') ? 'en-US' : 'de-DE';

  Future<void> _speak(String text) async {
    if (_ttsReady) {
      try {
        await _tts.stop();
        await _tts.speak(text);
      } catch (_) {}
    }
  }

  Future<void> _speakIfNeeded() =>
      _autoTts ? _speak(_question.prompt) : Future.value();

  @override
  void dispose() {
    _tts.stop();   // dispose() existiert nicht mehr in flutter_tts v4
    super.dispose();
  }

  // ───────────────────────── Antwort-Logik ────────────────────────────────
  void _check(int idx) {
    if (_awaitWrong || _awaitLevelUp) return;

    final ok = _manager.answer(_question, idx);
    if (ok) {
      if (_awaitLevelUp) return;                                   // Level-Up abwarten
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

  // ───────────────────────── Pop-up für TTS-Schalter ─────────────────────
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

  // ───────────────────────── Build-Methode ───────────────────────────────
  @override
  Widget build(BuildContext context) {
    // 1) schwerer Fehler (z. B. Asset nicht gefunden)
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
                      'Stimmen die Asset-Pfade in pubspec.yaml?',
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
                    _initManager();        // erneuter Lade-Versuch
                  },
                  child: const Text('Erneut versuchen'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // 2) Initial-Spinner bis Wortliste + erstes Bild bereitstehen
    if (_levelImg == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // 3) Level-geschafft-Screen
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
                    onPressed: _nextLevel, child: const Text('Weiter')),
              ),
            ],
          ),
        ),
      );
    }

    // 4) Regulärer Frage-Screen
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Level ${_manager.level} – '
              'Streak ${_manager.streak}/${LevelManager.levelGoal}',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            tooltip: 'Einstellungen',
            onPressed: _showTtsPopup,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Bild oben
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

            // Weiter-Button nach falscher Antwort
            if (_awaitWrong)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: ElevatedButton(
                    onPressed: _nextWrong, child: const Text('Weiter')),
              ),
          ],
        ),
      ),
    );
  }
}
