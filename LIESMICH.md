## SPEECH BASIC

### EINE BASIC ERWEITERUNG FÜR DEN C64

Diese Basic-Erweiterung und die Hardware wurden ursprünglich von Kristian
Köhntopp und Daniel Diezemann für den Commodore C64 entwickelt.

Diese Basic-Erweiterung stellt 23 neue Befehle bereit.

Dieser Quellcode basiert auf den vorhandenen Disk-Images, welche 1986 bei Markt
& Technik in der Computerzeitschrift „64'er 86/10“ erschienen sind.

An dieser Stelle möchte ich mich ganz herzlich bei Kristian und Dana bedanken,
die mir die Rechte am Quellcode und der Hardware-Schaltung überlassen haben.
Somit kann ich nun beides hier auf GitHub veroeffentlichen.

Eine kurze Geschichte zur Entstehung von Speech Basic, findest du in Kristian's
Blog:

https://blog.koehntopp.info/2006/10/26/mut-64er-10-86.html

„Speech-Basic besteht aus einer kleinen Schaltung, nämlich einem
2-Bit-Tondigitalisierer und einer 4 KByte langen Basic-Erweiterung. Beides
zusammen ermöglicht das einfache und komfortable Arbeiten mit Sprache und Musik
am Commodore 64. *)

### Liste der Befehle nach Gruppe

| Gruppe | Kategorie | Befehle |
| --- | --- | --- |
| a | Grundbefehle zur Steuerung der Erweiterung | `RESET`, `BASIC`, `HELP` |
| b | Utilities und Diskettenbefehle | `KEY`, `MEM`, `DISK`, `DIR`, `BLOAD`, `BSAVE` |
| c | Tonbefehle | `HEAR`, `RECORD`, `PLAY`, `VOLDEF`, `COLDEF` |
| d | Erweiterte Tonbefehle | `BLOCK`, `MAP`, `HIMEM`, `PAUSE`, `EXEC` |
| e | Sonstige Befehle | `BHEX`, `DEZ`, `SCREEN`, `MON` |

Zusätzliche Exec-Befehle: `p`, `s`, `w`, `v`, `c`, `#`.

Details zur Digitalisierungsschaltung und detailliertere Informationen zu den
Befehlen findest du unter:

- https://archive.org/details/64er_1986_10/page/n63/mode/2up
- https://www.c64-wiki.de/wiki/Speech_Basic

### SPEECH BASIC Screenshots

| | |
| --- | --- |
| ![Speech BASIC Screenshot 1](https://github.com/LeshanDaFo/C64-Speech-Basic/assets/97148663/e5a720d4-59c6-47f7-a286-d7bd7b8e06c7) | ![Speech BASIC Screenshot 2](https://github.com/LeshanDaFo/C64-Speech-Basic/assets/97148663/e5bc1f5f-b2b6-4cd0-ac3a-545b3b69063f) |

### Beispiel-Screenshots eines Digitalisierers

| | |
| --- | --- |
| ![Digitalisierer-Beispiel 1](https://github.com/LeshanDaFo/C64-Speech-Basic/assets/97148663/67fb171c-8fec-40c8-8c68-34f8ae4ab02e) | ![Digitalisierer-Beispiel 2](https://github.com/LeshanDaFo/C64-Speech-Basic/assets/97148663/1ce12357-e1bb-4ff1-b7b6-869174333874) |

!! Dieses Layout ist nur ein Beispiel. Wenn du planst, deinen eigenen
Digitalisierer zu bauen, solltest du den Beschreibungen in den entsprechenden
Dokumenten folgen. !!

### Informationen zum Quellcode

Beim Erstellen und Dokumentieren des Quellcodes habe ich einige kleine Fehler
und nicht notwendige Codeteile gefunden.

1. Der BLOAD-Befehl vergleicht die Ladeadresse nicht mit der Basic-Startadresse,
   daher ist es möglich, das Speech-Basic-Hauptprogramm zu überschreiben.
2. Die Unterroutine `checkparam`, die für DIR, DISK, BLOAD und auch BSAVE
   verwendet wird, prüft nicht, ob das angegebene Gerät existiert. Wird eine
   Gerätenummer eingegeben, die nicht existiert, friert der Rechner ein.
3. Der Befehl PAUSE weist einen Fehler auf, der manchmal dazu führt, dass 255
   Bytes vom Zählwert übersprungen werden.

Ich habe 2 Versionen veröffentlicht.

#### SpeechBasicV2.7asm ist der Originalcode.

#### SpeechBasicV2.8.asm ist die Version, in der ich diese Fehler korrigiert und einige kleine Codeoptimierungen vorgenommen habe.

Ich habe dem Quellcode so viele Informationen und Kommentare wie möglich
hinzugefügt, damit er leichter lesbar und verständlich ist.

Die Dokumentation ist vielleicht nicht perfekt, aber ich denke aber, es ist ein
guter Anfang.

### Anmerkungen

*)Auszug aus der Zeitschrifft 64'er 86/10 von Markt & Technik
