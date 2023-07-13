<body>

## SPEECH BASIC

### EINE BASIC ERWEITERUNG FÜR DEN C64

Diese Basic-Erweiterung und die Hardware wurden ursprünglich von Kristian Köhntopp und Daniel Diezemann für den Commodore C64 entwickelt.<br />
Diese Basic-Erweiterung stellt 23 neue Befehle bereit.<br />
<br />
Dieser Quellcode basiert auf den vorhandenen Disk-Images,<br />
welche 1986 bei Markt & Technik in der Computerzeitschrift „64'er 86/10“ erschienen sind.
<br />
<br />
An dieser Stelle möchte ich mich ganz herzlich bei Kristian und Dana bedanken, die mir die Rechte am Quellcode und der Hardware-Schaltung überlassen haben. Somit kann ich nun beides hier auf GitHub veroeffentlichen<br />
Eine kurze Geschichte zur Entstehung von Speech Basic, findest du in Kristian's Blog:<br />
https://blog.koehntopp.info/2006/10/26/mut-64er-10-86.html
<br />
<br />
„Speech-Basic besteht aus einer kleinen Schaltung, nämlich einem 2-Bit-Tondigitalisierer und einer 4 KByte langen Basic-Erweiterung. Beides zusammen ermöglicht das einfache und komfortable Arbeiten mit Sprache und Musik am Commodore 64. *)<br />


### Liste der Befehle nach Gruppe

<div align="left">
<table border="0" cellpadding="6" width="600">
 <tr>
  <th>a</th>
  <th>Grundbefehle zur Steuerung der Erweiterung</th>
  <th>RESET,BASIC,HELP</th>
 </tr><tr>
 <tr>
  <th>b</th>
  <th>Utilities und Diskettenbefehle</th>
  <th>KEY,MEM,DISK,DIR,BLOAD,BSAVE</th>
 </tr><tr>
  <tr>
  <th>c</th>
  <th>Tonbefehle</th>
  <th>HEAR,RECORD,PLAY,VOLDEF,COLDEF</th>
 </tr><tr>
  <tr>
  <th>d</th>
  <th>Erweiterte Tonbefehle</th>
  <th>BLOCK,MAP,HIMEM,PAUSE,EXEC</th>
 </tr><tr>
  <tr>
  <th>e</th>
  <th>Sonstige Befehle</th>
  <th>BHEX,DEZ,SCREEN,MON</th>
 </tr><tr>
</table>
</div>


Zusätzliche Exec-Befehle:<br />
p,s,w,v,c,#
<br />
<br />

Details zur Digitalisierungsschaltung und detailliertere Informationen zu den Befehlen findest du unter: https://archive.org/details/64er_1986_10/page/n63/mode/2up <br />
und im C64-Wiki: https://www.c64-wiki.de/wiki/Speech_Basic <br />


### SPEECH BASIC Screenshots<br />
<div align="left">
<table border="0" cellpadding="6" width="600">
 <tr>
  <td align="center"><img src="https://github.com/LeshanDaFo/C64-Speech-Basic/assets/97148663/e5a720d4-59c6-47f7-a286-d7bd7b8e06c7" width="320" height="240"></td>
  <td align="center"><img src="https://github.com/LeshanDaFo/C64-Speech-Basic/assets/97148663/e5bc1f5f-b2b6-4cd0-ac3a-545b3b69063f" width="320" height="240"></td>
 </tr>
</table>
</div>

### Beispiel-Screenshots eines Digitalisierers<br />
<div align="left">
<table border="0" cellpadding="6">
 <tr>
  <td align="center"><img src="https://github.com/LeshanDaFo/C64-Speech-Basic/assets/97148663/67fb171c-8fec-40c8-8c68-34f8ae4ab02e" width="440" height="180"></td>
  <td align="center"><img src="https://github.com/LeshanDaFo/C64-Speech-Basic/assets/97148663/1ce12357-e1bb-4ff1-b7b6-869174333874" width="200" height="180"></td>
 </tr>
</table>
</div>
!! Dieses Layout ist nur ein Beispiel. Wenn du planst, deinen eigenen Digitalisierer zu bauen, solltest du den Beschreibungen in den entsprechenden Dokumenten folgen. !!
<br />
<br />

### Informationen zum Quellcode:

Beim Erstellen und Dokumentieren des Quellcodes habe ich einige kleine Fehler und nicht notwendige Codeteile gefunden.<br />

1. Der BLOAD-Befehl vergleicht die Ladeadresse nicht mit der Basic-Startadresse, daher ist es möglich, das Speech-Basic-Hauptprogramm zu überschreiben.<br />
2. Die Unterroutine „checkparam“, die für DIR, DISK, BLOAD und auch BSAVE verwendet wird, prüft nicht, ob das angegebene Gerät existiert. Wird eine Gerätenummer eingegeben, die nicht existiert, friert der Rechner ein.<br />
3. Der Befehl PAUSE weist einen Fehler auf, der manchmal dazu führt, dass 255 Bytes vom Zählwert übersprungen werden.
<br />
<br />
Ich habe 2 Versionen veröffentlicht.

#### SpeechBasicV2.7asm ist der Originalcode.
#### SpeechBasicV2.8.asm ist die Version, in der ich diese Fehler korrigiert und einige kleine Codeoptimierungen vorgenommen habe.<br />

Ich habe dem Quellcode so viele Informationen und Kommentare wie möglich hinzugefügt, damit er leichter lesbar und verständlich ist.<br />
Die Dokumentation ist vielleicht nicht perfekt, aber ich denke aber, es ist ein guter Anfang.<br />

<br />
Anmerkungen:
<br />
*)Auszug aus der Zeitschrifft 64'er 86/10 von Markt & Technik
</body>




