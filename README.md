# Explanation of using the tool length probe subroutine for Probe Basic from TooTall18T .  
Version 4.0.1 as of 07.12.2024  
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

The routines were tested with LinuxCNC 2.8 and Probe Basic 0.3.8 .
With other versions, there may be differences in the process.
The functions of the routine should be tested at reduced speed before using the routine in production.

> [!IMPORTANT]
> Versions up to 4.0.1 are only compatible with Probe Basic up to version 0.5.4-stable.

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
The subroutine is used to measure tools on a stationary tool length probe in LinuxCNC with the Probe Basic interface.
It doesn't matter whether the measurement is started manually from Probe Basic or automatically from the milling program. There are optional settings for the process that extend the functionality of the original subroutine.  
  
The machine is automatically freed and moves to the tool change point. After confirming that the tool has been changed, the machine measures the tool and, if necessary, automatically returns to the starting point.  
  
Things like the use of the tool table, the frequency of measurement attempts in the event of incorrect measurements or the position at which the tool is changed can be set individually.  
  
An overview of the extensions compared to the original subroutine:
- Call using M command (M600)
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

---
## Last change:
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
    
V3.0 
- tool_touch_prog.ngc - Routine moved to "tool_touch_off.ngc" routine.
- tool_touch_off.ngc - save the required parameters from the interface to the variable file (4000-4005). Parameters no longer need to be written to the files.
- Added debug mode with file output. File is saved in the machine folder as "logfile.txt".
- Fixed parameter "#<brake_after_M600>" extended. "1" the machine pauses with M0 at the position
at which the tool change was called. "2" the machine pauses with M1 if [M01 BREAK] is enabled. 
There is also a pause when changing to the same tool.
- Added the fixed parameter "#<use_tool_table>". With "0" a "remeasurement" is always carried out.
- Moved #<go_back_to_start_pos> to "Fixed parameters".
- #<spindle_stop_m> to select the M command to stop the spindle (5 / 500).

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




