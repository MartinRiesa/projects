# Spezifikation des Vokabellernalgorithmus

Diese Spezifikation fasst exakt zusammen, welche Anforderungen der Vokabeltrainer erfüllen muss, um den Lernalgorithmus wie im Originalrepositorium umzusetzen.

## 1. Level- und Pool-Logik

1.1. Level-Definition: Jeder Level besteht aus den ersten *n × 7* Vokabeln der Wortliste (CSV).

1.2. Levelstart: Level beginnt mit *level = 1*, *streak = 0*.

## 2. Datenmodell

2.1. **VocabPair** mit Feldern:

* `en` (String)
* `de` (String)
* `mistakes` (int, initial 0)
* `corrects` (int, initial 0)

2.2. **Question** mit:

* `prompt` (String),
* `options` (List<String>),
* `correctIndex` (int),
* `sourcePair` (VocabPair).

## 3. Gewichtete Auswahl

3.1. Gewichtung jeder Karte:

```dart
weight = (mistakes + 1) / (corrects + 1)
```

3.2. Ziehung: Zufällige Auswahl aus dem aktuellen Pool anhand der relativen Gewichte.
3.3. **No Doublet**: Dieselbe Karte darf nicht unmittelbar nacheinander gezogen werden.

## 4. Distraktoren

4.1. Bis zu 2 Distraktoren aus bereits falsch beantworteten Karten (sorted by mistakes).
4.2. Auffüllen mit zufälligen Karten aus dem Rest des Pools, bis 3 Distraktoren.
4.3. Optionsliste: `[correct, ...distractors]` → gemischt.

## 5. Antwortverarbeitung

5.1. **Richtig**:

* `corrects++` auf `sourcePair`
* `streak++`
* Bei `streak == 10`: `level++`, `streak = 0`, Callback `onLevelUp()`.

5.2. **Falsch**:

* `mistakes++` auf `sourcePair`
* `streak = 0`
* Callback `onWrong()`.

## 6. Bild-Feedback

6.1. Jedes Level hat ein Bild `assets/images/<level>.jpg`.
6.2. Initial: Bild-Blur = `maxBlur` (z. B. 30.0).
6.3. Nach jeder richtigen Antwort: `blur = maxBlur * (1 - streak / 10)`.
6.4. Bei Fehler: `blur = maxBlur`.

## 7. Interfaces

7.1. **LanguageSelectionScreen**
7.2. **QuestionScreen** mit State-Handling, Bild-Blur, Buttons
7.3. **LoadingScreen** (FutureBuilder)

---

> **Hinweis:** Änderungen am Algorithmus müssen auch in dieser Spezifikation aktualisiert werden.
