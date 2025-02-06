# Explanation of using the tool length probe subroutine for Probe Basic and other GUIs from TooTall18T .  
Version 5.0.0 as of 06.02.2025  
https://github.com/TooTall18T/tool_length_probe

---
## Contents
- Notes and notices
- Instructions and functional sequence
- Range of function
- Last changes
- License

---
## Notes and notices
> [!IMPORTANT]
> Use the subroutines at your own risk!

The routines were tested with LinuxCNC 2.9.3 and Probe Basic 0.6.0-018 .
With other versions, there may be differences in the process.
The functions of the routine should be tested at reduced speed before using the routine in production.

> [!NOTE]
> This version (5) of the routine is for Probe Basic 0.6.0 and higher.  
> For Probe Basic up to version 0.5.4-stable use tool_length_probe 4.0.1 : https://github.com/TooTall18T/tool_length_probe/releases/tag/4.0.1

> [!NOTE]
> With small changes this routine can be used with every GUI.

The routines "tool_touch_off.ngc" and "go_to_g30.ngc" are based on the routines of the same name that came with Probe Basic.

> [!NOTE]
> The German version of this document is called "[lies_mich.md](lies_mich.md)" and it is in the same folder.

---
## Instructions and functional sequence
The instructions in English and German can be found in the “docs” folder.  
[Manual](./docs/manual.md) / [Anleitung](./docs/anleitung.md)  
A sequence of functions is also described there.

---
## Range of function
The subroutine is used to measure tools on a stationary tool length probe in LinuxCNC with the GUI Probe Basic or other GUIs.
It doesn't matter whether the measurement is started manually or automatically from the milling program. There are optional settings for the process that extend the functionality of the original subroutine.  
  
The machine is automatically freed and moves to the tool change point. After confirming that the tool has been changed, the machine measures the tool and, if necessary, automatically returns to the starting point.  
  
Things like the use of the tool table, the frequency of measurement attempts in the event of incorrect measurements or the position at which the tool is changed can be set individually.  
  
An overview of the extensions compared to the original subroutine:
- Call using M command (M600 / M601)
- Use tool table
- Return to the starting point
- Pause at the starting point
- Switching off the tool spindle with selectable M command
- Additional repetitions in case of failed measurement attempts
- Last measurement without tool table
- Tool offset for larger diameters
- Alternative position for changing tools
- Alternative measurement position for 3D probes
  
The settings in Probe Basic can still be made there, the additional ones are made at the beginning of the subroutine.  
By using other GUIs all settings need to be made in the subroutine.

---
## Last change:
V5.0.0
- readme.md / lies_mich.md - Added information about possible use with other GUIs
- manual.md / anleitung.md - Adapted the configuration process to Probe Basic 0.6.0 and for general use
- tool_touch_off.ngc:
    - Update the parameter numbers for Probe Basic 0.6.0
    - Deleted the direct parameter handover
    - Added the parameter "traverse fr" for the speed of fast movements
    - Added "M50 feed override control" to prevent manipulation of the feed rate during the process
    - Updated the directions for tool offset at larger diameters
- M600 - Added mode parameter "#2000"
- M601 - Added to start the subroutine in manual mode

V4.0.1
- Added compatibility notes and corrected typos.

V4.0.0
- readme.md / lies_mich.md - Revised, now serves as an overview.
- manual.md / anleitung.md - Updated the manual and moved to its own files.
- tool_touch_off.ngc:
    - Changed the positioning above the tool probe. Safe use of the G30 command possible. Use G30-position as tool change position.
    - Moved the parameters of the .var-file from 4000-4005 to 3000-3005.
    - Added tool diameter offset. From a set diameter, the machine offsets by a percentage value in order to be able to measure the length of cutters with larger diameters.
    - Added tool edge-finder. A tool can be set as a 3D/edge finder to be measured at an alternative position.
    - Added additional attempts. If the fast measurment failed, an additianal attempts to measure the tool can be set. Inbetween the tool position can be changed.
    - Added last try. As a last try, a probing without the tool table can be done.
    - Added German messages. To change, the semicolon in front of "(DEBUG," and "(ABORT," must be moved.

V3.0.1
- tool_touch_off.ngc
    - Delete if statments for log commands.
    - Added Logclose commands
    - Added log END markings
    - Change "o<tool_touch_off.ngc> endsub" to "o<tool_touch_off.ngc> return" and delete M2.
- readme.md / lies_mich.md
    - Update Notes/Warning/Important block style.
    

---
## License
Copyright (C) 2022 TooTall18T

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see <http://www.gnu.org/licenses/>.
