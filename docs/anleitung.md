# Erklärung zur Nutzung der Werkzeugvermessungsroutine für Probe Basic von TooTall18T .
Version 6.0.0 stand 23.02.2025  
https://github.com/TooTall18T/tool_length_probe

> [!IMPORTANT]  
> Die Anleitung aufmerksam durchlesen.

> [!IMPORTANT]  
> Die Benutzung der Subroutinen geschieht auf eigene Gefahr!

> [!NOTE]  
> Zum besseren lesen dieser Anleitung, wird ein Markdown Editor oder ein Plug-In empfohlen.


> [!NOTE]  
> Bis zur Probe Basic Version 0.5.4-stable muss die Version 4.0.1 dieser Routine genutzt werden.  
> Für Probe Basic 0.6.0, oder anderen GUIs, die Version 5.0.0 benutzen.  
> Ab Version 0.6.0-37.dev von Probe Basic, oder einer anderen GUI, wird die Version 6.0.0 oder höher dieser Routine benötigt.


---
## Inhalt
- Anmerkungen und Hinweise
- Installation
	- Installationsskript
	- Manuelle Installation
- Einrichten
	- Grundeinstellung
- Ablauf der Routine
	- Weitere Funktionen
- Weitere Informationen

---
## Anmerkungen und Hinweise
> [!NOTE]  
> Die Routinen wurden mit den Versionen LinuxCNC 2.9.3 und Probe Basic 0.6.0-37.dev getestet.
> Bei anderen Versionsständen können unter Umständen Unterschiede im Ablauf statt finden.

> [!IMPORTANT]  
> Die Funktionen der Routine sollten mit verminderter Geschwindigkeit getestet werden, bevor die Routine im Fertigungseinsatz genutzt wird.

> [!NOTE]  
> Bei Angaben wie "**{spindel zero}**" handelt es sich um Eingabefelder in Probe Basic.  
> Für andere GUIs sind diese als Variablen zusehen. Siehe unten.

> [!NOTE]  
> Bei Angaben wie "**[TOOL]**" handelt es sich um Schaltflächen oder Menüs in der Oberfläche von Probe Basic.  
> Für andere GUIs sind diese als Variablen zusehen. Siehe unten.

> [!NOTE]  
> Bei Angaben wie "**#<tool_min_dis>**" handelt es sich um Variablen aus der Routine. Diese müssen bei der Verwendung einer anderen GUI angepasst werden.

---
## Installation

### Installationsskript
> [!NOTE]  
> Das Installationsskript ist nur für die Installation der Routinen und des Benutzertabs für Probe Basic gemacht. Für andere GUIs, oder falls das Skript nicht genutzt werden möchte, bitte mit dem Teil "Manuelle Installation" weiter machen.

Das Skript erstellt Sicherungskopien von allen Dateien und Ordnern die ersetzt oder bearbeitet werden.  
Während des Prozesses werden Rückmeldung gegeben was abgeschlossen wurde oder nicht möglich war.  
Falls ein Schritt nicht durchgeführt werden konnte, diesen bitte händisch durchführen. Ein zweiter Durchlauf kommt zum gleichen Ergebnis.  
Das Installationsskript führt die selben Schritte aus wie sie unter "Manuelle installation" aufgeführt sind.  

Alle Dateien und Ordner im heruntergeladenen Ordner lassen.  
Die Rechte am Skript ändern mit: chmod 770 ./install.sh  
Die Installation start mit: ./install.sh  
Die installation bitte nicht mit "sh ./install.sh" starten. Das Skript ist ein bash-Skript, was auf den meisten Systemen der Standard ist.  

Als erstes benötigt das Skript den Pfad zur .ini-Datei der Maschine. Es prüft dann zunächst ob es alle Dateien und Ordner finden kann und prüft auch die Lese- und Schreibrechte.  
Sollten etwas nicht gefunden werden, wird das Skript abgebrochen. Wenn die Überprüfung erfolgreich war, wird man gefragt ob die Installation durchgeführt werden soll.  
Die Installation wird gestartet mit: YES  
Das Installationsskript copiert und bearbeitet alle Dateien mit allen Optionen.  


### Manuelle installation
> [!NOTE]  
> Ein paar punkte sind exclusiv für Probe Basic oder andere GUIs. Wenn nichts dabei steht gilt es für alle.

> [!IMPORTANT]  
> Von allen Dateien und Ordnern eine Sicherungskopie erstellen, die ersetzt und/oder bearbeitet werden.

Zur Nutzung der Vermessungsroutine wird nur die Datei "tool_touch_off.ngc" benötigt. Für Probe Basic wird zusätzlich noch der Ordner "(user_tab/)tool_length_probe" gebraucht.
Alle anderen Dateien sind optional.  


#### ini-Datei
Für Probe Basic:
In der ".ini" unter "[DISPLAY]" folgenden Eintrag ergänzen, wenn nicht vorhanden:  
USER_TABS_PATH = user_tabs/  
"user_tabs/" ist der Standardordner. Wird ein Anderer genutzt geht dies auch.

In der ".ini" unter "[EMCIO]" folgende Einträge ergänzen:  
TOOL_CHANGE_AT_G30 = 0			(Prevent the machine from moving to the G30-position when using the M6-command.)  
TOOL_CHANGE_QUILL_UP = 0		(Prevent the machine from moving the z-axis to G53 Z0-position when using the M6-command.)  

Die folgen Zeile in der ".ini" unter "[EMCIO]" löschen oder auskommentieren:  
TOOL_CHANGE_POSITION = ......  

Die Remaps der M-Befehle die genutzt werden sollen eintragen. Siehe unten "Optionale Subroutinen".

#### Subroutinen
Datei(en) in den Ordner kopieren der in der ".ini" unter "[RS274NGS]" "SUBROUTINE_PATH" eingetragen ist (subroutines).  
Wenn nicht vorhanden, unter "[RS274NGS]" folgendes eintragen:
SUBROUTINE_PATH = subroutines
Erklärung zu den optionalen Subroutinen, siehe unten.

#### var-Datei (für Probe Basic)
In der ".var" Datei, welche in der ".ini" unter "[RS274NGS]" "PARAMETER_FILE" hinterlegt ist, die folgenden Parameter eintragen:  
2949    0.000000  
2951    0.000000  
2952    0.000000  
2953    0.000000  
2954    0.000000  
2955    0.000000  
2956    0.000000  
2957    0.000000  
2958    0.000000  
2959    0.000000  
2960    0.000000  
2961    0.000000  
2962    0.000000  

> [!IMPORTANT]  
> Alle parameter müssen in aufsteigender Reihenfolge in der Datei stehen.
> Wenn die Parameter nicht oder in der falschen Reihenfolge eingetragen sind, kann die Backup-Funktion nicht genutzt werden.
> Sollten die Parameter bereits vorhanden sein und für andere Routinen genutzt werden, muss eine angepasste Version von "tool_length_probe" erstellt werden. Dafür bitte bei mir melden.


#### yml-Datei (für Probe Basic)
Die ".yml" Datei öffnen die in der ".ini" unter "[DISPLAY]" "CONFIG_FILE" eingetragen ist. Unter "settings" folgendes, mit einem Tab davor, einfügen:  
{% include "user_tabs/tool_length_probe/tool_length_probe.yml" %}  
Ggf. den Pfad von der ".ini" zur "tool_length_probe.yml" Datei anpassen.

Nach "provider: qtpyvcp.plugins.tool_table:ToolTable" suchen und in der "columns" Zeile darunter ein "I" einfügen:
>provider: qtpyvcp.plugins.tool_table:ToolTable  
>kwargs:  
>columns: TZDIR

### Optionale Subroutinen

- go_to_g30.ngc -- Probe Basic: Die original Routine fährt alle Achsen gleichzeitig auf die G30-Position. Diese Routine fährt die Z-Achse frei und danach zunächst die X- und Y-Achse an die G30-Position. Dort angekommen wird auch die Z-Achse auf die G30-Position gefahren.
> [!NOTE]  
> Die G30-Position kann als Werkzeugwechselposition genutzt werden. Sollte dies nicht gewünscht sein, **[DISABLE CHANGE POS]** einschalten.
  
- M600.ngc -- Subroutine zum Aufruf der Werkzeugvermessung im Automatikmodus (mit Werkzeugwechsel) aus dem CNC Programm heraus.  
	In der ".ini" unter "[RS274NGS]" folgendes eintragen:  
	REMAP=M600 modalgroup=6 ngc=m600
> [!IMPORTANT]  
> Ein remap auf "M6" ist nicht zu empfehlen, da der M6-Befehl an verschiedenen Stellen in Probe Basic und evtl. anderen GUIs genutzt wird und es so zu nicht vorhersehbaren Ereignissen führen kann.

- M601.ngc -- Subroutine zum Aufruf der Werkzeugvermessung im Manuellermodus (ohne Werkzeugwechsel) aus dem CNC Programm heraus oder für die Verwendung bei anderen GUIs.  
	In der ".ini" unter "[RS274NGS]" folgendes eintragen:  
	REMAP=M601 modalgroup=6 ngc=m601
> [!IMPORTANT]  
> Ein remap auf "M6" ist nicht zu empfehlen, da der M6-Befehl an verschiedenen Stellen in Probe Basic und evtl. anderen GUIs genutzt wird und es so zu nicht vorhersehbaren Ereignissen führen kann.

- M300.ngc -- Subroutine zum Starten einer Werkzeugspindel ohne Rückmeldung. Das CNC Programm pausiert nach dem Start der Spindel für eine einstellbare Zeit (P4.0 = 4s). Die Zeit wird in der Routine eingetragen.    
	In der ".ini" unter "[RS274NGS]" folgendes eintragen:  
	REMAP=M300 modalgroup=7 ngc=m300

- M500.ngc -- Subroutine zum Stoppen einer Werkzeugspindel ohne Rückmeldung. Wenn die Spindel an war, pausiert das CNC Programm für eine einstellbare Zeit (P4.0 = 4s). Die Zeit wird in der Routine eingetragen.  
	In der ".ini" unter "[RS274NGS]" folgendes eintragen:  
	REMAP=M500 modalgroup=7 ngc=m500
	
---
## Einrichten

### Grundeinstellung
> [!IMPORTANT]  
> Bei anderen GUIs als Probe Basic müssen die Parameter in die Routine eingetragen werden. **Alle** HAL-Pins (#<_hal[qtpyvcp.tlp.*****]>) müssen überschrieben werden.

0. Andere GUI: Die Subroutine "tool_touch_off.ngc" mit einem Editor öffnen.
1. LinuxCNC starten und eine Referenzfahrt durchführen.
2. Werkzeug aus der Spindel entfernen.
3. Werkzeug auf "0" umschalten.
4. Verschiebung des Werkstückkoordinatensystems zurücksetzen (G5X = G53). 
5. Die Spindel zentrisch über dem Werkzeugtaster positionieren.  
6. Die Spindel knapp über dem Schaltpunkt des Werkzeugtasters positionieren.  
![Z-Position](./images/z-position.jpg)  
7. Probe Basic: Unter **[TOOL SETTER]** **[SET TOOL SETTER POS]** drücken. Die Koordinaten stehen dann darüber.  
	Andere GUI: Die aktuellen Koordinaten in die drei "**#<tool_setter_?_coords>**" Parameter eintragen.  
8. Z-Achse nullen.
9. Z-Achse hoch fahren. Abstand zwischen Werkzeugtaster und Spindel so groß wählen, dass das längste Werkzeug mit Abstand dazwischen passt. Diese Position dient als Startpunkt für die Vermessung von neuen Werkzeugen.  
Die Z-Position aus dem akuellen Koordinatensystem unter  
(Probe Basic) **[TOOL SETTER]** **{spindle zero}** eintragen oder **[SET SPINDLE ZERO]** drücken.  
(andere GUI) **#<spindle_zero_height>** eintragen.  
![Position neue Werkzeuge](./images/new_tool_position.jpg)  
![Spindle zero](./images/spindle_zero.jpg)  


Für Probe Basic unter **[TOOL SETTER]** die folgenden Parameter ausfüllen:
Bei anderen GUIs als Probe Basic müssen die Parameter in die Routine eingetragen werden.  
**Alle** HAL-Pins (#<_hal[qtpyvcp.tlp.*****]>) müssen überschrieben werden:  
| Parameter | Beschreibung  |
| -------  | -----  |
| `ALLGEMEIN` | |
| spindle zero  | Abstand zwischen Spindel und Werkzeugtaster für Neuvermessungen. |
| z max travel  | Maximale Strecke die die Z-Achse während der Vermessung eines bekannten Werkzeugs zurücklegt. Wert sollte größer als **{tool min dis}** sein. Siehe Bild unten. |
| tool min dis  | Abstand zwischen Werkzeugtaster und alter Länge des Werkzeugs. Nur in Verbindung mit Werkzeugtabelle genutzt. Wert sollte kleiner als **{z max travel}** sein. |
| retract dist  | Strecke die die Z-Achse nach der ersten Antastung nach oben fährt bevor die zweite Antastung stattfindet. Es muss ein Wert eingetragen sein, egal ob die langsame Vermessung stattfindet oder nicht. |
| xy max travel | Wird nicht genutzt. |
| fast probe fr  | Geschwindigkeit in Maschineneinheit/min für die erste Antastung (schnelle Vermessung). |
| slow probe fr  | Geschwindigkeit in Maschineneinheit/min für die zweite Antastung. Ist der Wert 0 , wird nur die erste Antastung durchgeführt. |
| traverse fr | Geschwindigkeit in Maschineneinheit/min für schnelle Bewegungen wärend des Prozesses. |
|  `OPTIONEN` | |
| USE TOOL TABLE  | Wird die Werkzeugtabelle genutzt und ein bekannten Werkzeug (Länge >0) vermessen, wird das Werkzeug für die Vermessung tiefer positioniert. |
| GO BACK TO START POS  | Wenn "AN" fährt die Maschine, bei der Automatischen Vermessung, zur Position zurück an der die Routine gestartet wurde. |
| BRAKE AFTER SAME TOOL  | Nach dem wechsel zum selben Werkzeug, kann das Programm mit "M00"(1) oder "M01"(2) pausiert werden. Siehe "Fall 2.1 und 2.2" |
| BRAKE AFTER CHANGE TOOL  | Nach dem wechsel zu einem anderen Werkzeug, kann das Programm mit "M00"(1) oder "M01"(2) pausiert werden. Siehe "Fall 2.1 und 2.2" |
| add reps | Anzahl zusätzlicher Vermessungsversuche. Bei fehlerhafter schneller Vermessung fährt die Maschine wieder an die Werkzeugwechselposition und das Werkzeug kann neu eingestellt werden. |
| LAST TRY | Wenn die letzte Vermessung fehlgeschlagen ist, macht die Maschine eine Vermessung ohne Werkzeugtabelle. |
| spindle stop m  | M-Befehlnummer zum stoppen der Spindel. Standard 5 (M5), optional 500 (M500 / m500.ngc). |
| TOOL DIAM PROBE | Wird nicht genutzt. |
| DEBUG MODE  | Hier wird der Debugmode zur Fehlersuche eingeschaltet. Datei "logfile.txt" im Konfigurationsordner der Maschine. Die Datei wird jedes mal überschrieben. |
| DISABLE CHANGE POS | Deaktiviert die Werkzeugwechselposition an der G30-Koordinaten. Werkzeug wird über Werkzeugtaster gewechselt. |
| SET TOOL CHANGE POS | Für Probe Basic: Die Maschine an die gewünschte Position fahren, an der das Werkzeug gewechselt werden soll. Danach die Taste drücke um die Position (G30) zu speichern. |
|  | Andere GUI: Die Maschine an die gewünschte Position fahren, an der das Werkzeug gewechselt werden soll. Danach "G30.1" als MDI Befehl ausführen. |
| tool offset direction | Zur Vermessung von Werkzeugen mit großen Durchmessern. Die Richtung für den Werkzeugversatz auswählen. "fnt angle" in der Werkzeugtabelle wird als Versatz in Prozent genutzt. |
|  | Andere GUI: Einer der "**#<tool_offset_XXXX>**" Parameter muss "1" sein, die Anderen "0". |
|  `OPTION: 3D-TASTER` | Alternative Vermessungsposition für 3D-/Kantentaster. |
| T no. (#<finder_number>) | Werkzeugnummer des Tasters. Wird dieses Werkzeug vermessen, vermisst es sich selber an der Referenzfläche. |
| z offset | Differenz zwischen Werkzeugtaster und Referenzoberfläche. Das Vorzeichen gibt die Differenz in Achsrichtung an. "-" = tiefer als Werkzeugtaster, "+" = höher als Werkzeugtaster. |
| SET 3D PROBE POS | Für Probe Basic: Die Maschine in X und Y an die Referenzfläche fahren und Taste drücken um die Koordinaten zu speichern. |
|  | Andere GUI: Die Maschine in X und Y an die Referenzfläche fahren und die Maschinenkoordinaten in **#<finder_touch_x_coords>** und **#<finder_touch_y_coords>** eintragen. |


![Position bekannte Werkzeuge](./images/old_tool_position.jpg)  


> [!IMPORTANT]  
> Bei den ersten Vermessungen sollte die Maschinengeschwindigkeit verringert werden um ggf. bei fehlerhaften Einstellungen nichts zu beschädigen.

> [!NOTE]  
> Die Texte der Melde- und Warnfenster, die durch die Routine erzeugt werden, können in der "tool_touch_off.ngc" auf Deutsch umgestellt werden.
> Hierzu in der Routine nach "(DEBUG", und "(ABORT" suchen und das Semikolon ";" versetzen. ))

---
## Ablauf der Routine

### 1 Ablauf der Subroutine bei manueller Vermessung über **[TOUCH OFF CURRENT TOOL]** oder M601
Die Subroutine unterscheidet beim Aufruf zwei Fälle: neues Werkzeug (Länge <=0mm), bekanntes Werkzeug (Länge >0mm).

#### Fall 1.1 und 1.2:
Die Z-Achse fährt auf Maschinen Nullpunkt hoch und schaltet ggf. die Spindel aus (über **{spindle stop m}** Stoppfunktion wählbar). Anschließend fährt die Maschine zum Werkzeugtaster.
Über die Option **[USE TOOL TABLE]** kann gewählt werden, ob die Werkzeugtabelle genutzt wird (Fall 1.2). Dies macht die Vermessung von kurzen Werkzeugen schneller, da diese tiefer positioniert werden. Wird die Werkzeugtabelle nicht genutzt, macht die Maschine immer eine "Neuvermessung" (Fall 1.1).  
Fortfahrend mit Fall 1.1 oder 1.2 .


#### Fall 1.1 neues Werkzeug (Länge <=0mm):
Die Z-Achse fährt mit der Geschwindigkeit **{traverse fr}** auf die Höhe von **{spindle zero}** über den Werkzeugtaster.  
Dieser Wert muss größer sein als das längste zuerwartende Werkzeug, darf aber nicht länger sein als der Weg zwischen Werkzeugtaster und Z-Null.
Anschließend fährt die Z-Achse mit der Geschwindigkeit **{fast probe fr}** solange runter bis der Werkzeugtaster schaltet oder die Z-Achse die Strecke **{spindel zero}** abgefahren hat.  
Letzteres führt zu einer Fehlermeldung: "Tool length offset probe failed!" / "Werkzeugvermessung fehlgeschlagen!"  
Wenn der Taster geschaltet hat, fährt die Z-Achse um den Wert **{retract dist}** nach oben.  
Ist eine Geschwindigkeit für **{slow probe fr}** (>0) definiert, fährt die Maschine den Taster nochmal mit dieser Geschwindigkeit an. Sollte keine Geschwindigkeit definiert sein, wird dieser Schritt übersprungen.  
Danach fährt sich die Z-Achse auf Maschinen Nullpunkt frei.  
Die Maschine bleibt bei manueller Vermessung jetzt stehen.


#### Fall 1.2 bekanntes Werkzeug (Länge >0mm):
Wenn die Option **[USE TOOL TABLE]** "AN" ist, wird bei bekannten Werkzeugen (Länge >0mm) dieser Ablauf verwendet. Ansonsten wird der Fall 1.1 genutzt.  
Die Z-Achse fährt mit der Geschwindigkeit **{traverse fr}** das Werkzeug, ausgehend von der alten Werkzeuglänge, so hoch über den Taster wie es unter **{tool min dis}** definiert ist.  
**{tool min dis}** sollte nicht zu klein definiert werden, um Unterschiede beim Einlegen des Werkzeugs abfangen zu können.  
Anschließend fährt die Z-Achse mit der Geschwindigkeit **{fast probe fr}** solange runter bis der Werkzeugtaster schaltet oder die Z-Achse die Strecke **{z max travel}** abgefahren hat.  
Letzteres führt zu einer Fehlermeldung: "Tool length offset probe failed!" / "Werkzeugvermessung fehlgeschlagen!".  
**{z max travel}** sollte nicht zu groß gewählt werden, da sonst die Spindel auf den Taster fahren kann.  
Wenn der Taster geschaltet hat, fährt die Z-Achse um den Wert **{retract dist}** nach oben.  
Ist eine Geschwindigkeit für **{slow probe fr}** (>0) definiert, fährt die Maschine den Taster
nochmal mit dieser Geschwindigkeit an. Sollte keine Geschwindigkeit definiert sein, wird dieser Schritt übersprungen.  
Danach fährt sich die Z-Achse auf Maschinen Nullpunkt frei.  
Die Maschine bleibt bei manueller Vermessung jetzt stehen.


### 2 Ablauf der Subroutine bei Vermessung aus dem CNC Programm heraus (M600)  
Die Subroutine unterscheidet beim Aufruf vier Fälle: neues Werkzeug (Länge <=0mm), bekanntes Werkzeug (Länge >0mm), gleiches Werkzeug und Wechsel auf "T0" .


#### Fall 2.1 und 2.2:
Die Vermessung von neuen und bekannten Werkzeugen funktioniert in der Vermessung, die durch das CNC Programm gestartet wird, gleich. Siehe dazu "Fall 1.1" und "Fall 1.2" oben.  
Jedoch fährt die Maschine an die Werkzeugwechselposition (G30 oder über den Werkzeugtaster) und verlangt dort den Werkzeugwechsel bevor die Maschine zum Werkzeugtaster fährt. Siehe dazu "Werkzeugwechselposition".  
Zusätzlich kann mit der Option **[GO BACK TO START POS]** gewählt werden, dass die Maschine nach der Vermessung an den Punkt zurück fährt an dem die Routine aufgerufen wurde. So muss man den Rückweg vom Taster nicht im CNC Programm programmieren.  
Mit **[BRAKE AFTER TOOL CHANGE]** kann man das CNC Programm nach der Vermessung pausieren lassen. In Verbindung mit **[GO BACK TO START POS]** wird die Pause an der Aufrufposition gemacht. Andernfalls über dem Werkzeugtaster.  
"no"(0) macht keine Pause.  
"M00"(1) macht eine Pause mittels "M00" Befehl. Weiter fahren durch betätigen von **[CYCLE START]**  
"M01"(2) macht eine Pause mittels "M01" Befehl, wenn zusätzlich auf der Oberfläche **[M01 BREAK]** aktiv ist. Weiter fahren durch betätigen von **[CYCLE START]**.

> [!WARNING]  
> Die Subroutine startet die Spindel nicht neu!


#### Fall 2.3 gleiches Werkzeug:
Ist das gewählte Werkzeug bereits in der Maschine. Wird die Meldung "Same tool" / "Selbes Werkzeug" ausgegeben. Die Spindel wird nicht gestoppt.  
Über **[BRAKE AFTER SAME TOOL]** kann gewählt werden, ob die Maschine an der Stelle wartet bevor das CNC Programm weiter läuft.  
"no"(0) macht keine Pause.  
"M00"(1) macht eine Pause mittels "M00" Befehl. Weiter fahren durch betätigen von **[CYCLE START]**  
"M01"(2) macht eine Pause mittels "M01" Befehl, wenn zusätzlich auf der Oberfläche **[M01 BREAK]** aktiv ist. Weiter fahren durch betätigen von **[CYCLE START]**.


#### Fall 2.4 Wechsel auf T0 :
> [!WARNING]  
> Ein Wechsel am Ende des CNC Programms mittels "M600 T0", kann bei Programmabbrüchen dazu führen, dass LinuxCNC von G43 auf G49 umschaltet!  
> Wenn das Programm erneut gestartet wird, kann es sein, dass nicht wieder auf G43 umgeschaltet wird. Kollisionsgefahr!  
> Der Fall dient nur dazu, dass nicht versehentlich mit Werkzeug "0" eine Vermessung gestartet wird.

### Weitere Funktionen

#### Debug Mode
Der Debug Mode erzeugt im Konfigurationsordner eine "logfile.txt" Datei. In dieser werden einige Parameter der Maschine und der Routine gespeichert um ggf. bei einem Fehler den Grund dafür zu finden. Die Datei wird bei jedem Aufruf der Routine überschrieben.

#### Werkzeugwechselposition
Die Werkzeugwechselposition (G30) kann über **[TOOL SETTER]** **[SET TOOL CHANGE POS]** / "G30.1" festgelegt werden.  
Dazu die Maschine an die gewünschte Position fahren und **[SET TOOL CHANGE POS]** drücken / "G30.1" eingeben. Die Position kann jederzeit wenn nötig geändert werden. Um die Position für die Subroutine frei zugeben, **[DISABLE CHANGE POS]** ausschalten.  
Wird die Funktion genutzt, fährt die Maschine vor der Vermessung über "M600" zunächst an die X-, Y- und Z-Koordinate (G30) und verlangt den Werkzeugwechsel. Danach positioniert sich die Maschine erst über dem Werkzeugtaster.  
Wird bei genutzter Werkzeugtabelle die Anzahl zusätzlicher Vermessungsversuche (**{add reps}**) auf min. "1" gesetzt, fährt die Maschine, sowohl bei der manuellen als auch automatischen Vermessung, nach einem Fehlversuch der schnellen Vermessung, an diese Position und verlangt erneut nach dem Werkzeug.  
So kann das Werkzeug nach justiert werden.  
Wird die Option "Letzter Versuch (last try)" genutzt, fährt die Maschine beim letzten Vermessungsversuch nicht mehr die Werkzeugwechselposition an, sondern vermisst direkt das Werkzeug neu.

#### Zusätzliche Versuche
Sollte die Vermessung mit aktiver Werkzeugtabelle, Aufgrund eines kürzer eingesetzten Werkzeugs, bei der schnellen Vermessung fehlschlagen. Können über diesen Parameter zusätzliche Versuche hinzugefügt werden. So kann nach einem Fehlschlag ggf. das Werkzeug nach justiert werden.

#### Letzter Versuch
Sollten bis auf den letzten Versuch die Vermessungen, mit Werkzeugtabelle, fehlgeschlagen sein, kann über diese Funktion eine Neuvermessung statt finden.  

#### Werkzeugversatz
Für Werkzeuge mit größerem Durchmesser kann über diese Funktion ein Mittenversatz erzeugt werden. Die Richtung in der dieser Versatz gefahren wird, wird über **[TOOL SETTER]** "tool offset direction" / **#<tool_offset_XXXX>** festgelegt.  
Die größe des Versatzes wird über den Wert "fnt angle" in der Werkzeugtabelle definiert. Ein 10mm Werkzeug mit einem "fnt angle"-Wert von "50" wird um 5mm versetzt.

#### 3D-Taster
Sollte es nicht möglich sein einen 3D-/Kantentaster über den Werkzeugtaster zu vermessen. Kann eine alternative Vermessungsposition für diesen definiert werden. Die Höhendifferenz zwischen Vermessungsposition und Werkzeugtaster muss ermittelt werden und in **{z offset}** / **#<finder_z_offset>** eingetragen werden. Das Vorzeichen gibt die Differenz in Achsrichtung an. "-" = tiefer als Werkzeugtaster, "+" = höher als Werkzeugtaster.

---
## Weitere Informationen:
> [!NOTE]  
> die Parameter "xy max travel" und "tool diam probe" werden in der Routine nicht verwendet.
