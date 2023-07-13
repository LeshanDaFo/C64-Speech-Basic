<body>

## SPEECH BASIC

### A BASIC EXTENSION FOR THE C64

This basic extension and the hardware is original developed by 
Kristian Köhntopp & Daniel Diezemann for the Commodore C64.<br />
This Basic extension provides 23 new basic functions.<br />
<br />
This source code is based on the existing disk images<br />
published by Markt & Technik in 1986 in the German computer magazine "64'er 86/10"
<br />
<br />
At this point I would like to say many thanks to Kristian and Dana, for giving me the rights to the source code and the hardware circuit. So I can now publish both here on GitHub.<br />
You can find a short story of the history about Speech Basic written by Kristian on his blog:<br />
https://blog.koehntopp.info/2006/10/26/mut-64er-10-86.html
<br />
<br />
"Speech Basic consists of a small circuit, namely a 2-bit audio digitizer and a 4-KByte Basic extension. Both together enable easy and comfortable working with speech and music on the Commodore 64. The Speech Basic commands support working in direct mode (for recording and simple playback of acoustic signals) as well as in the program."*)<br />

### List of commands by group

<div align="left">
<table border="0" cellpadding="6" width="600">
 <tr>
  <th>a</th>
  <th>Basic-commands</th>
  <th>RESET,BASIC,HELP</th>
 </tr><tr>
 <tr>
  <th>b</th>
  <th>Uttilities-, and Disc-commands</th>
  <th>KEY,MEM,DISK,DIR,BLOAD,BSAVE</th>
 </tr><tr>
  <tr>
  <th>c</th>
  <th>Sound-commands</th>
  <th>HEAR,RECORD,PLAY,VOLDEF,COLDEF</th>
 </tr><tr>
  <tr>
  <th>d</th>
  <th>Extended sound-commands</th>
  <th>BLOCK,MAP,HIMEM,PAUSE,EXEC</th>
 </tr><tr>
  <tr>
  <th>e</th>
  <th>other commands</th>
  <th>BHEX,DEZ,SCREEN,MON</th>
 </tr><tr>
</table>
</div>


Additional exec commands are
p,s,w,v,c,#
<br />
<br />

Details about the digitizer circuit, and more detailed information about the commands can be found at: https://archive.org/details/64er_1986_10/page/n63/mode/2up <br />
and on the C64-wiki: https://www.c64-wiki.de/wiki/Speech_Basic <br />


### SPEECH BASIC Screenshots<br />
<div align="left">
<table border="0" cellpadding="6" width="600">
 <tr>
  <td align="center"><img src="https://github.com/LeshanDaFo/C64-Speech-Basic/assets/97148663/e5a720d4-59c6-47f7-a286-d7bd7b8e06c7" width="320" height="240"></td>
  <td align="center"><img src="https://github.com/LeshanDaFo/C64-Speech-Basic/assets/97148663/e5bc1f5f-b2b6-4cd0-ac3a-545b3b69063f" width="320" height="240"></td>
 </tr>
</table>
</div>

### Digitizer example Screenshots<br />
<div align="left">
<table border="0" cellpadding="6">
 <tr>
  <td align="center"><img src="https://github.com/LeshanDaFo/C64-Speech-Basic/assets/97148663/67fb171c-8fec-40c8-8c68-34f8ae4ab02e" width="440" height="180"></td>
  <td align="center"><img src="https://github.com/LeshanDaFo/C64-Speech-Basic/assets/97148663/1ce12357-e1bb-4ff1-b7b6-869174333874" width="200" height="180"></td>
 </tr>
</table>
</div>
!! This layout is just an example, if you plan to build your own digitizer, you should follow the descriptions in the relevant documents. !!
<br />
<br />

### Information about the source code:
During creating and documenting the source-code, i found some small errors, and not necessary code parts.<br />
1. The BLOAD command does not compare the load address with the Basic start address, so it is possible, to overwrite the Speech-Basic main programm.<br />
2. The sub-routine 'checkparam', which is used for DIR, DISK, BLOAD and also BSAVE, does not check whether the specified device exists. If a device number is entered which does not exist, the computer freezes.<br />
3. The PAUSE command has a bug, sometimes skipping 255 bytes from the count value.<br />
<br />
I have puplished 2 version.

#### SpeechBasicV2.7.asm is the original code.<br />
#### SpeechBasicV2.8.asm is the Version where i have corrected these errors, and did some small code optimizations.<br />

I have added information and comments to the source as much as possible, so that it is more easy to read and understand.<br />
The documantation is maybe not perfect, but I think, it is a good start.<br />
<br />
### Remark:
*)Translated from original Text, published by Markt & Technik
<br /><br />
Used Software:    
Visual Studio Code, Version: 1.75.1    
Acme Cross-Assembler for VS Code (c64) v0.0.18  
<br />
Used Hardware:    
Apple iMac (24-inch, M1, 2021)      
<br />
The source code can be compiled by using the Acme Cross Compiler (C64)
<br />
Please use this source code on your own risk ;)
</body>

