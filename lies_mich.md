# Erklärung zur Nutzung der Werkzeugvermessungsroutine für Probe Basic von TooTall18T .  
Version 4.0.0 stand 18.01.2024  
https://github.com/TooTall18T/tool_length_probe

  
---
## Inhalt

- Anmerkungen und Hinweise
- Anleitung und Funktionsablauf
- Funktionsumfang
- Letzte Änderungen
- Lizenz
      
---
## Anmerkungen und Hinweise
> [!IMPORTANT]
> Die Benutzung der Subroutinen geschieht auf eigene Gefahr!

Die Routinen wurden mit den Versionen LinuxCNC 2.8 und Probe Basic 0.3.8 getestet.  
Bei anderen Versionsständen können unter Umständen Unterschiede im Ablauf statt finden.  
Die Funktionen der Routine sollten mit verminderter Geschwindigkeit getestet werden, bevor die Routine im Fertigungseinsatz genutzt wird.

Die Routinen "tool_touch_off.ngc" und "go_to_g30.ngc" basieren auf den gleichnamigen Routinen die bei Probe Basic dabei waren.

---   
## Anleitung und Funktionsablauf
Die Anleitungen in englisch und deutsch sind im Ordner "docs" zu finden.  
[Manual](./docs/manual.md) / [Anleitung](./docs/anleitung.md)  
Darin ist auch ein Ablauf der Funktionen beschrieben.

---
## Funktionsumfang
Die Subroutine dient dazu in LinuxCNC, mit der Oberfläche Probe Basic, Werkzeuge an einem stationären Werkzeuglängentaster einzumessen.  
Dabei ist es egal, ob die Vermessung aus Probe Basic manuel gestartet wird, oder automatisch aus dem Fräsprogramm. Für den Ablauf gibt es optionale Einstellungen, die den Funktionsumfang zur original Subroutine erweitern.  

Die Maschine wird automatisch frei gefahren und bewegt sich an den Werkzeugwechselpunkt. Nach der Bestätigung, dass das Werkzeug gewechselt ist, vermisst die Maschine das Werkzeug und kehrt ggf. automatisch an den Ausgangspunkt zurück.

Dabei können Dinge wie die Benutzung der Werkzeugtabelle, die Häufigkeit von Vermessungsversuchen bei Fehlmessungen oder auch die Position an der das Werkzeug gewechslet wird einzeln eingestellt werden.

Eine Übersicht der Erweiterungen gegenüber der original Subroutine:  
- Aufruf mittels M-Befehl (M600)  
- Nutzung Werkzeugtabelle  
- Rückkehr zum Ausgangspunkt  
- Pausieren am Ausgangspunkt  
- Abschalten der Werkzeugspindel mit wählbarem M-Befehl  
- Zusätzliche Wiederholungen bei fehlgeschlagenen Messversuchen  
- Letzte Vermessung ohne Werkzeugtabelle  
- Wekzeugversatz bei größeren Durchmessern  
- Alternative Position zum Werkzeugwechseln  
- Alternative Vermessungsposition für 3D-Taster

Die Einstellungen in Probe Basic können weiterhin dort vorgenommen werden, die zusätzlichen werden am Anfang der Subroutine vorgenommen.

  
---
## Letzte Änderung:
V4.0.0
- readme.md / lies_mich.md - Überarbeitet, dient nun als Übersicht.
- manual.md / anleitung.md - Die Anleitung überarbeitet und in eine eigene Datei verschoben.
- tool_touch_off.ngc:
	- Die Positionierung über dem Werkzeugtaster geändert. Sichere Nutzung des G30 Befehls möglich. G30-Position als Werkzeugwechselposition.
	- Die Parameter in der .var-Datei von 4000-4005 auf 3000-3005 verschoben.
	- Durchmesserversatz hinzugefügt. Ab einem eingestellten Durchmesser versetzt die Maschine einen Prozentualenwert des Fräsers, um auch Fräser mit größerem Durchmesser messen zu können.
	- Werkzeug Kantentaster hinzugefügt. Ein Werkzeug kann als 3D/Kantentaster eingestellt werden, um an einer alternativen Position vermessen zu werden.
	- Zusätzliche Versuche hinzugefügt. Sollte die Schnellmessung fehlschlagen, können zusätzliche Versuche zur Messung des Werkzeugs eingestellt werden. Dazwischen kann die Werkzeugposition im Halter geändert werden.
	- Ein letzter Versuch. Als letzten Versuch kann eine Messung ohne die Werkzeugtabelle durchgeführt werden.
	- Deutsche Meldefenster hinzugefügt. Zum Wechsel muss das Semikolon vor "(DEBUG," und "(ABORT," versetzt werden.

V3.0.1
- tool_touch_off.ngc
	- IF Abfragen für log Befehle entfernt.
	- Logclose Befehle hinzugefügt.
	- Log END Markierungen eingefügt.
	- Von "o<tool_touch_off.ngc> endsub" nach "o<tool_touch_off.ngc> return" geändert und M2 entfernt.  
- readme.md / lies_mich.md
	- Ansicht der Notes/Warning/Important Blöcke geändert.

V3.0  
- tool_touch_prog.ngc - Routine in die "tool_touch_off.ngc" Routine verschoben.  
- tool_touch_off.ngc  - Speichern der erforderlichen Parameter aus der Oberfläche in der Variablendatei (4000-4005). Parameter müssen nicht mehr in die Dateien geschrieben werden.  
- Debug-Modus mit Dateiausgabe eingefügt. Datei wird im Maschinenordner als "logfile.txt" gespeichert.  
- Fester Parameter "#<brake_after_M600>" erweitert. Bei "1" pausiert die Maschine mittels M0 an der Position, an der der Werkzeugwechsel aufgerufen wurde. Bei "2" pausiert die Maschine statt dessen mittels M1, wenn dies auf der Oberfläche aktiviert ist. Bei wechsel auf gleiches Werkzeug wird ebenfalls pausiert.  
- Den festen Parameter "#<use_tool_table>" hinzugefügt. Bei "0" wird immer eine "Neuvermessung" durchgeführt.  
- #<go_back_to_start_pos> zu "Feste Parameter" verschoben.  
- #<spindle_stop_m> zur Auswahl des M-Befehls zum stoppen der Spindel (5 / 500).

  
---
## Lizenz
Copyright (C) 2022 TooTall18T

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.


