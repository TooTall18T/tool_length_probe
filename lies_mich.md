# Erklärung zur Nutzung der Werkzeugvermessungsroutine für Probe Basic von TooTall18T .
Version 3.1.0 stand 23.10.2022<br>
https://github.com/TooTall18T/tool_length_probe

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

> [!IMPORTANT]
> Die Benutzung der Subroutinen geschieht auf eigene Gefahr!
> Die Routinen "tool_touch_off.ngc" und "go_to_g30.ngc" basieren auf den gleichnamigen Routinen die bei Probe Basic dabei waren.


## Inhalt
- Letzte Änderungen
- Anmerkungen und Hinweise
- Installation
- Einrichten
- Ablauf der Routine
- Weitere Informationen



## Letzte Änderung:
V3.1.0
- readme.md / lies_mich.md - Anleitung überarbeitet.

V3.0  
- tool_touch_prog.ngc - Routine in die "tool_touch_off.ngc" Routine verschoben.  
- tool_touch_off.ngc  - Speichern der erforderlichen Parameter aus der Oberfläche in der Variablendatei (4000-4005). Parameter müssen nicht mehr in die Dateien geschrieben werden.  
- Debug-Modus mit Dateiausgabe eingefügt. Datei wird im Maschinenordner als "logfile.txt" gespeichert.  
- Fester Parameter "#<brake_after_M600>" erweitert. Bei "1" pausiert die Maschine mittels M0 an der Position, an der der Werkzeugwechsel aufgerufen wurde. Bei "2" pausiert die Maschine statt dessen mittels M1, wenn dies auf der Oberfläche aktiviert ist. Bei wechsel auf gleiches Werkzeug wird ebenfalls pausiert.  
- Den festen Parameter "#<use_tool_table>" hinzugefügt. Bei "0" wird immer eine "Neuvermessung" durchgeführt.  
- #<go_back_to_start_pos> zu "Feste Parameter" verschoben.  
- #<spindle_stop_m> zur Auswahl des M-Befehls zum stoppen der Spindel (5 / 500).

## Anmerkungen und Hinweise
Die Routinen wurden mit den Versionen LinuxCNC 2.8 und Probe Basic 0.3.8 getestet.  
Bei anderen Versionsständen können unter Umständen Unterschiede im Ablauf statt finden.  
Die Funktionen der Routine sollten mit verminderter Geschwindigkeit getestet werden, bevor die Routine im Fertigungseinsatz genutzt wird.

> [!NOTE]
> Bei Angaben wie "**#<tool_min_dis>**" handelt es sich um Variablen aus der Routine. Diese müssen ggf. innerhalb der Routine angepasst werden.

## Installation
Dateien die ausgetauscht und/oder bearbeitet werden vorher sichern.  
Zur Nutzung der Vermessungsroutine wird nur die Datei "tool_touch_off.ngc" benötigt.  
Alle anderen Dateien sind optional.  
> [!WARNING]
> Es ist zu empfehlen die Routine "go_to_g30.ngc" auch zu ersetzen. Kollisionsgefahr!

Datei(en) in den Ordner kopieren der in der ".ini" unter [RS274NGS] "SUBROUTINE_PATH" eingetragen ist (subroutines).  
In die ".var" Datei, welche in der ".ini" unter "PARAMETER_FILE" hinterlegt ist, die folgenden Parameter eintragen:  
4000	0  
4001	0  
4002	0  
4003	0  
4004	0  
4005	0  
Alle Parameter (4000 5000 usw.) müssen in aufsteigender Reihenfolge in der Datei stehen.  
Werden die Parameter nicht oder in der falschen Reihenfolgen eingetragen, können die Parameter aus der Oberfläche nicht dauerhaft gespeichert werden.  
Sollten die oben aufgelisteten Parameter bereits vorhanden sein. Müssen sechs andere Parameter zwischen 31 und 5000 gewählt werden und die Routine umgeschrieben werden.

Optionale Subroutinen:
- go_to_g30.ngc -- Die original Routine fährt bis auf den Taster runter. ***Kollisionsgefahr!!*** Die neue Routine bleibt über dem Taster stehen (G53 Z0).
- M600.ngc -- Subroutine zum Aufruf der Werkzeugvermessung aus dem CNC Programm heraus.
	In der ".ini" unter [RS274NGS] folgendes eintragen:
	REMAP=M600 modalgroup=6 ngc=m600

- M300.ngc -- Subroutine zum Starten einer Werkzeugspindel ohne Rückmeldung. Das CNC Programm pausiert nach dem Start der Spindel für eine einstellbare Zeit (P4.0 = 4s).
	In der ".ini" unter [RS274NGS] folgendes eintragen:
	REMAP=M300 modalgroup=7 ngc=m300
- M500.ngc -- Subroutine zum Stoppen einer Werkzeugspindel ohne Rückmeldung. Wenn die Spindel an war, pausiert das CNC Programm für eine einstellbare Zeit (P4.0 = 4s).
	In der ".ini" unter [RS274NGS] folgendes eintragen:
	REMAP=M500 modalgroup=7 ngc=m500

## Einrichten
Das Werkzeug aus der Spindel nehmen und auf T0 umschalten.  
Die Verschiebung des Werkstückkoordinatensystems zurücksetzen (G5X = G53).  
Die Spindel zentrisch über dem Werkzeugtaster positionieren.  
Nun die Spindel auf den Werkzeugtaster fahren bis dieser auslöst. Es erscheint eine Meldung auf dem Monitor.  
Die Maschine an diesem Punkt stehen lassen und unter [OFFSETS] [SET TOOL TOUCH OFF POSITION] drücken. Die Koordinaten werden übernommen.  
Der Taster kann nun frei gefahren werden.

Unter [OFFSETS] die folgenden Parameter ausfüllen:
| Parameter | Beschreibung  |
| -------  | -----  |
| fast probe fr  | Geschwindigkeit in m/min für die erste Antastung. |
| slow probe fr  | Geschwindigkeit in m/min für die zweite Antastung. Ist der Wert 0 , wird nur die erste Antastung durchgeführt. |
| z max travel  | Maximale Strecke die die Z-Achse während der Vermessung eines bekannten Werkzeugs zurücklegt. Wert sollte größer als "#<tool_min_dis>" sein. |
| spindle zero  | Mindestabstand zwischen Spindel und Werkzeugtaster für neue Werkzeuge, siehe "Fall 2.1 neues Werkzeug (Länge <=0mm)". Der Wert darf maximal so groß sein wie der Z-Wert unter [OFFSETS]. |
| retract dist  | Strecke die die Z-Achse nach der ersten Antastung nach oben fährt bevor die zweite Antastung stattfindet. Es muss ein Wert eingetragen sein, egal ob die langsame Vermessung stattfindet oder nicht. |

Nachdem die Parameter ausgefüllt sind unter [TOOL] 1x [TOUCH OFF CURRENT TOOL] drücken um die Parameter in der Variablendatei zu speichern. Es wird keine Vermessung gestartet. Es erscheint nur eine Meldung.
Nach Änderungen an den Parametern muss erneut 1x [TOUCH OFF CURRENT TOOL] gedrückt werden.


In der Datei "tool_touch_off.ngc" die folgenden Parameter unter "-2- Fixed parameters" anpassen:
| Parameter | Beschreibung  |
| -------  | -----  |
| #<debug_mode>  | Hier wird der Debugmode zur Fehlersuche eingestellt. 0=AUS, 1=Logdatei . Datei "logfile.txt" im Konfigordner der Maschine. Die Datei wird jedes mal überschrieben. |
| #<use_tool_table>  | Bei "1" wird die Werkzeugtabelle genutzt und bei einem bekannten Werkzeug (Länge >0) das Werkzeug für die Vermessung tiefer positioniert. |
| #<tool_min_dis>  | Abstand zwischen Werkzeugtaster und alter Länge des Werkzeugs. Nur in Verbindung mit Werkzeugtabelle genutzt. |
| #<brake_after_M600>  | Bei ">0" warten auf Bestätigung, dass das Programm nach der Vermessung weiter arbeiten darf. 1 = M00, 2 = M01 . Siehe "Fall 1.2 und 2.2" |
| #<go_back_to_start_pos>  | Bei "1" fährt die Maschine, bei der Automatischen Vermessung, zur Position zurück an der die Routine gestartet wurde. |
| #<spindle_stop_m>  | M-Befehlnummer zum stoppen der Spindel. Standard 5 (M5), optional 500 (M500 / m500.ngc). |

> [!IMPORTANT]
> Bei den ersten Vermessungen sollte die Maschinengeschwindigkeit verringert werden um ggf. bei fehlerhaften Einstellungen nichts zu beschädigen.


## Ablauf der Routine
Ablauf der Subroutine bei manueller Vermessung über [TOUCH OFF CURRENT TOOL]:  
Die Subroutine unterscheidet beim Aufruf drei Fälle: neue Parameter, neues Werkzeug (Länge <=0mm), bekanntes Werkzeug (Länge >0mm)

### Fall 1.1 neue Parameter:
Wenn man unter [OFFSETS] einen Parameter für die Werkzeugvermessung geändert hat, muss man unter [TOOL] 1x auf [TOUCH OFF CURRENT TOOL] drücken. Dies speichert die aktuellen Parameter in der Variablendatei. Eine Vermessung wird nicht ausgeführt, statt dessen kommt die Meldung "New parameters saved!".  
So müssen die Parameter nicht nochmal händisch in die M600 Subroutine eingetragen werden.


### Fall 2.1 und 3.1:
Die Z-Achse fährt auf Maschinen Nullpunkt hoch, schaltet ggf. die Spindel aus (über "#<spindle_stop_m>" Stoppfunktion wählbar) und anschließend über den Werkzeugtaster.  
Über den festen Parameter "#<use_tool_table>" kann gewählt werden, ob die Werkzeugtabelle genutzt wird (1). Wird die Werkzeugtabelle nicht genutzt (0), macht die Maschine immer eine "Neuvermessung" (Fall 2.1).  
Fortfahrend mit Fall 2.1 oder 3.1 .


### Fall 2.1 neues Werkzeug (Länge <=0mm):
Die Z-Achse fährt mit G0 auf die Höhe über den Werkzeugtaster welche über "spindel zero" definiert ist.  
Dieser Wert muss größer sein, als die längste zu erwartende Werkzeuglänge.  
"Spindle zero" darf nicht zu groß gewählt werden.  
Beispiel: Z-Position(G53) -60mm , "spindle zero" = 70mm . Die Maschine würde versuchen auf Z(G53)= +10mm zu fahren.

Anschließend fährt die Z-Achse mit der Geschwindigkeit "fast probe fr" solange runter bis der Werkzeugtaster schaltet oder die Z-Achse die Strecke "spindel zero" abgefahren hat.  
Letzters führt zu einer Fehlermeldung: "G38.4: Bewegung ohne Kontaktschließung beendet."  
Wenn der Taster geschaltet hat, fährt die Z-Achse um den Wert "retract dist" nach oben.  
Ist eine Geschwindigkeit für "slow probe fr" (>0) definiert, fährt die Maschine den Taster nochmal mit dieser Geschwindigkeit an.  
Danach fährt sich die Z-Achse auf Maschinen Nullpunkt frei.  
Bei erfolgreicher Vermessung wird der Messwert angezeigt.  
Die Maschine bleibt bei manueller Vermessung jetzt stehen.


### Fall 3.1 bekanntes Werkzeug (Länge >0mm):
Wenn der Parameter "#<use_tool_table>" "1" ist, wird bei bekannten Werkzeugen (Länge >0mm) dieser Ablauf verwendet. Ansonsten wird der Fall 2.1 genutzt.  
Die Z-Achse fährt mit G0 das Werkzeug, ausgehend von der alten Werkzeuglänge, so hoch über den Taster wie es unter "#<tool_min_dis>" definiert ist.  
"#<tool_min_dis>" sollte nicht zu klein definiert werden, um Unterschiede beim einlegen des Werkzeugs abfangen zu können.  
Anschließend fährt die Z-Achse mit der Geschwindigkeit "fast probe fr" solange runter bis der Werkzeugtaster schaltet oder die Z-Achse die Strecke "z max travel" abgefahren hat.  
Letzteres führt zu einer Fehlermeldung: "G38.4: Bewegung ohne Kontaktschließung beendet."  
Wenn der Taster geschaltet hat, fährt die Z-Achse um den Wert "retract dist" nach oben. Ist eine Geschwindigkeit für "slow probe fr" (>0) definiert, fährt die Maschine den Taster
nochmal mit dieser Geschwindigkeit an.  
Danach fährt sich die Z-Achse auf Maschinen Nullpunkt frei.  
Bei erfolgreicher Vermessung wird der Messwert angezeigt.  
Die Maschine bleibt bei manueller Vermessung jetzt stehen.


Ablauf der Subroutine bei Vermessung aus dem CNC Programm heraus (M600):  
Die Subroutine unterscheidet beim Aufruf vier Fälle: neues Werkzeug (Länge <=0mm), bekanntes Werkzeug (Länge >0mm), gleiches Werkzeug und Wechsel auf T0 .


### Fall 1.2 und 2.2:
Die Vermessung von neuen und bekannten Werkzeugen funktioniert in der Vermessung die durch das CNC Programm gestartet wird gleich.  
Siehe dazu "Fall 2.1" und "Fall 3.1" oben.  
Jedoch wird bevor die Z-Achse runter fährt der Werkzeugwechsel verlangt.  
Zusätzlich kann in der Routine über den festen Parameter "#<go_back_to_start_pos>" (1) gewählt werden, dass die Maschine, nach der Vermessung, an den Punkt zurück 
fährt an dem die Routine aufgerufen wurde. So muss man den Rückweg vom Taster nicht im CNC Programm programmieren.  
Fährt die Maschine, bedingt durch "#<go_back_to_start_pos>" zurück. Kann über "#<brake_after_M600>" (0/1/2) gewählt werden ob die Maschine an der Stelle wartet bevor
das CNC Programm weiter läuft.   
"0" macht keine Pause.  
"1" macht eine Pause mittels "M00" Befehl. Weiter fahren durch betätigen von [CYCLE START]  
"2" macht eine Pause mittels "M01" Befehl wenn zusätzlich auf der Oberfläche [M01 BREAK] aktiv ist. Weiter fahren durch betätigen von [CYCLE START]


### Fall 3.2 gleiches Werkzeug:
Ist das gewählte Werkzeug bereits in der Maschine. Wird die Meldung "Same tool" ausgegeben.  
Über "#<brake_after_M600>" (0/1/2) kann gewählt werden ob die Maschine an der Stelle wartet bevor das CNC Programm weiter läuft.  
"0" macht keine Pause.  
"1" macht eine Pause mittels "M00" Befehl. Weiter fahren durch betätigen von [CYCLE START]  
"2" macht eine Pause mittels "M01" Befehl wenn zusätzlich auf der Oberfläche [M01 BREAK] aktiv ist. Weiter fahren durch betätigen von [CYCLE START]


### Fall 4.2 Wechsel auf T0 :
> [!WARNING]
> Ein Wechsel am Ende des CNC Programms mittels "M600 T0", kann bei Programmabbrüchen dazu führen, dass LinuxCNC von G43 auf G49 umschaltet!
> Wenn das Programm erneut gestartet wird, kann es sein, dass nicht wieder auf G43 umgeschaltet wird. Kollisionsgefahr!
> Der Fall dient nur dazu, dass nicht versehentlich mit Werkzeug 0 eine Vermessung gestartet wird.


## Weitere Informationen:
> [!NOTE]
> Der Parameter "xy max travel" wird in der Routine nicht verwendet.
