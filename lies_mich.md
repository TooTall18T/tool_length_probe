# Erklärung zur Nutzung der Werkzeugvermessungsroutine für Probe Basic und anderen GUIs von TooTall18T .  
Version 6.0.0 stand 23.02.2025  
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

Die Routinen wurden mit den Versionen LinuxCNC 2.9.3 und Probe Basic 0.6.0-37.dev getestet.  
Bei anderen Versionsständen können unter Umständen Unterschiede im Ablauf statt finden.  
Die Funktionen der Routine sollten mit verminderter Geschwindigkeit getestet werden, bevor die Routine im Fertigungseinsatz genutzt wird.

> [!NOTE]  
> Diese Version der Routine ist für Probe Basic 0.6.0-37.dev und höher.
> Für ältere Versionen von Probe Basic:
> PB0.6.0 Version 5.0 benutzen
> PB0.5.4 oder vorher Version 4.0.1 benutzen

> [!NOTE]  
> QTPYVCP 5.0.2-5.dev oder höher ist erfoderlich.

> [!NOTE]  
> Mit kleinen Anpassungen, kann die Routine mit jeder GUI genutzt werden.

> [!NOTE]  
> Die Routinen "tool_touch_off.ngc" und "go_to_g30.ngc" basieren auf den gleichnamigen 
> Routinen die bei Probe Basic dabei waren.

---   
## Anleitung und Funktionsablauf
Die Anleitungen in englisch und deutsch sind im Ordner "docs" zu finden.  
[Manual](./docs/manual.md) / [Anleitung](./docs/anleitung.md)  
Darin ist auch ein Ablauf der Funktionen beschrieben.

---
## Funktionsumfang
Die Subroutine dient dazu in LinuxCNC, mit der Oberfläche Probe Basic oder jeder Anderen, Werkzeuge an einem stationären Werkzeuglängentaster einzumessen. Ein Benutzertab für Probe Basic ist integriert.  
Dabei ist es egal, ob die Vermessung manuel gestartet wird, oder automatisch aus dem Fräsprogramm. Für den Ablauf gibt es optionale Einstellungen, die den Funktionsumfang zur original Subroutine erweitern.  

Die Maschine wird automatisch frei gefahren und bewegt sich an den Werkzeugwechselpunkt. Nach der Bestätigung, dass das Werkzeug gewechselt ist, vermisst die Maschine das Werkzeug und kehrt ggf. automatisch an den Ausgangspunkt zurück.

Dabei können Dinge wie die Benutzung der Werkzeugtabelle, die Häufigkeit von Vermessungsversuchen bei Fehlmessungen oder auch die Position an der das Werkzeug gewechslet wird einzeln eingestellt werden.

Eine Übersicht der Erweiterungen gegenüber der original Subroutine:  
- Aufruf mittels M-Befehl (M600 / M601)  
- Nutzung Werkzeugtabelle  
- Rückkehr zum Ausgangspunkt  
- Pausieren am Ausgangspunkt  
- Abschalten der Werkzeugspindel mit wählbarem M-Befehl  
- Zusätzliche Wiederholungen bei fehlgeschlagenen Messversuchen  
- Letzte Vermessung ohne Werkzeugtabelle  
- Werkzeugversatz bei größeren Durchmessern  
- Alternative Position zum Werkzeugwechseln  
- Alternative Vermessungsposition für 3D-Taster

Die Einstellungen werden in Probe Basic über einen eigenen Benutzertab vorgenommen.  
Bei der Benutzung einer anderen GUI werden alle Einstellungen in der Subroutine vorgenommen.

  
---
## Letzte Änderung:
V6.0.0
- readme.md / lies_mich.md - Information zur möglichen Benutzung mit anderen GUIs hinzugefügt
- manual.md / anleitung.md - Den Ablauf der Konfiguration an Probe Basic 0.6.0-37.dev und für die allgemeine Verwendung angepasst
- Einen Benutzertab für Probe Basic hinzugefügt
- tool_touch_off.ngc:
	- Die Kommunikation an den Benutzertab angepasst
	- Das Verfahren zur Positionierung bei größeren Durchmessern überarbeitet
	- Die LOG Befehle an die neue Ansteuerung angepasst.  

V5.0.1
- tool_touch_off.ngc: "M50 P1" zu den returns hinzugefügt, um die Vorschubssperre aufzuheben  

V5.0.0
- readme.md / lies_mich.md - Information zur möglichen Benutzung mit anderen GUIs hinzugefügt
- manual.md / anleitung.md - Den Ablauf der Konfiguration an Probe Basic 0.6.0 und für die allgemeine Verwendung angepasst
- tool_touch_off.ngc:
	- Aktualisierung der Parameternummern für Probe Basic 0.6.0
	- Die direkte Parameterübergabe entfernt
	- Den Parameter "traverse fr" für die Geschwindigkeit bei schnellen Bewegungen hinzugefügt
	- "M50 Vorschubregelung" hinzugefügt, um die Manipulation der Vorschubsgeschwindigkeit, während des Prozesses, zu unterbinden.
	- Die Ausrichtung des Versatz bei größeren Durchmessern aktualisiert
- M600 - Den Modusparameter "#2000" hinzugefügt
- M601 - Hinzugefügt, zum starten der Subroutine im manuellen Modus

V4.0.1
- Kompatibilitäts Hinweise hinzugefügt und Schreibfehler korrigiert.  

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


