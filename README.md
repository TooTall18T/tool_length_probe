# Explanation of using the tool length probe subroutine for Probe Basic from TooTall18T .
Version 3.0.1 as of 29.10.2023<br>
https://github.com/TooTall18T/tool_length_probe

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


***Use the subroutines at your own risk!***
***The routines "tool_touch_off.ngc" and "go_to_g30.ngc" are based on the routines of the same name that came with Probe Basic.***
***The German version of this document is called "lies_mich.md" and it is in the same folder.***

## Contents
- Last changes
- Notes and Notices
- Installation
- Set up
- Flow of the routine
- Further information



## Last change:
V3.0.1
- tool_touch_off.ngc
  - Delete if statments for log commands.
  - Added Logclose commands
  - Change "o<tool_touch_off.ngc> endsub" to "o<tool_touch_off.ngc> return" and delete M2.
  - 
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

## Notes and Notices
The routines were tested with LinuxCNC 2.8 and Probe Basic 0.3.8 .
With other versions, there may be differences in the process.
The functions of the routine should be tested at reduced speed before using the routine in production.

Specifications such as "#<tool_min_dis>" are variables from the routine. These may have to be adjusted within the routine.

## Installation
Back up files that are exchanged and/or edited beforehand.
Only the "tool_touch_off.ngc" file is required to use the measurement routine.
All other files are optional.
***It is recommended to replace the "go_to_g30.ngc" routine as well. Danger of collision!***

Copy file(s) into the folder that is entered in the ".ini" under [RS274NGS] "SUBROUTINE_PATH" (subroutines).  
Enter the following parameters in the ".var" file, which is stored in the ".ini" under "PARAMETER_FILE":  
4000 0  
4001 0  
4002 0  
4003 0  
4004 0  
4005 0  
All parameters (4000 5000 etc.) must be in ascending order in the file.
If the parameters are not entered or entered in the wrong order, the parameters from the user interface cannot be saved permanently.
Should the parameters listed above already exist. Six other parameters must be chosen between 31 and 5000 and the routine rewritten.

Optional subroutines:
- go_to_g30.ngc -- The original routine moves down to the button. ***Danger of collision!!*** The new routine remains above the probe (G53 Z0).
- M600.ngc -- Subroutine for calling tool measurement from the CNC program.
Enter the following in the ".ini" under [RS274NGS]:
REMAP=M600 modalgroup=6 ngc=m600

- M300.ngc -- Subroutine to start a tool spindle without feedback. After the spindle has started, the CNC program pauses for an adjustable time (P4.0 = 4s).
Enter the following in the ".ini" under [RS274NGS]:
REMAP=M300 modalgroup=7 ngc=m300
- M500.ngc -- Subroutine to stop a tool spindle without feedback. If the spindle was on, the CNC program pauses for an adjustable time (P4.0 = 4s).
Enter the following in the ".ini" under [RS274NGS]:
REMAP=M500 modalgroup=7 ngc=m500

## Set up
Remove the tool from the spindle and switch to T0.  
Reset the offset of the work coordinate system (G5X = G53).  
Center the spindle over the tool probe.  
Now move the spindle to the tool probe until it triggers. A message appears on the monitor.  
Leave the machine at this point and under [OFFSETS] press [SET TOOL TOUCH OFF POSITION]. The coordinates are accepted.  
The probe can now be moved freely.  

Under [OFFSETS] fill in the following parameters:  
| Parameter | Discription  |
| -------  | -----  |
| fast probe fr  | Speed in m/min for the first probe.  |
| slow probe fr  | Speed in m/min for the second probing. If the value is 0, only the first probing is carried out.  |
| z max travel  | Maximum distance traveled by the Z-axis during the measurement of a known tool. Value should be greater than "#<tool_min_dis>". |
| spindle zero  | Minimum distance between spindle and tool probe for new tools, see "Case 2.1 new tool (length <=0mm)". The maximum value may be as large as the Z value under [OFFSETS]. |
| retract dist  | Distance that the Z-axis moves up after the first touch before the second touch takes place. A value must be entered, regardless of whether the slow measurement takes place or not. |

After the parameters are filled in press 1x [TOUCH OFF CURRENT TOOL] under [TOOL] to save the parameters in the variable file. No measurement is started. Only one message appears.  
After changing the parameters, [TOUCH OFF CURRENT TOOL] must be pressed once again.  


Adjust the following parameters under "-2- Fixed parameters" in the "tool_touch_off.ngc" file:  
| Parameter | Discription  |
| -------  | -----  |
| #<debug_mode>  | The debug mode for troubleshooting is set here. 0=OFF, 1=log file . File "logfile.txt" in the config folder of the machine. The file is overwritten each time. |
| #<use_tool_table>  | With "1" the tool table is used and with a known tool (length >0) the tool for the measurement is positioned lower.|
| #<tool_min_dis>  | Distance between tool probe and old tool length. Only used in connection with tool table.|
| #<brake_after_M600>  | If ">0" wait for confirmation that the program may continue to work after the measurement. 1 = M00, 2 = M01 . See "Case 1.2 and 2.2"|
| #<go_back_to_start_pos>  | With "1" the machine drives back to the position where the routine was started during automatic measurement.|
| #<spindle_stop_m>  | M-code number to stop the spindle. Default 5 (M5), optional 500 (M500/m500.ngc).|


During the first measurements, the machine speed should be reduced in order not to damage anything in the event of incorrect settings.


## Flow of the routine
Sequence of the sub-routine for manual measurement via [TOUCH OFF CURRENT TOOL]:  
When called, the subroutine differentiates between three cases: new parameters, new tool (length <=0mm), known tool (length >0mm) .  

### Case 1.1 new parameters:  
If you have changed a parameter for tool measurement under [OFFSETS], you must press [TOUCH OFF CURRENT TOOL] once under [TOOL]. This saves the
current parameters in the variable file. A measurement is not carried out, instead the message "New parameters saved!" appears.
In this way, the parameters do not have to be entered again manually in the M600 subroutine.


### Case 2.1 and 3.1:  
The Z-axis moves up to the machine zero point, if necessary switches off the spindle (stop function selectable via "#<spindle_stop_m>") and then moves to the tool probe.  
The fixed parameter "#<use_tool_table> can be used to select whether the tool table is to be used (1). If the tool table is not used (0), the machine always makes one "Remeasurement" (Case 2.1).
Proceeding to case 2.1 or 3.1.


### Case 2.1 new tool (length <=0mm):  
The Z-axis moves with G0 to the height above the tool probe, which is defined via "spindle zero".  
This value must be greater than the longest tool length to be expected.  
"Spindle zero" must not be too large.  
Example: Z position (G53) -60mm, "spindle zero" = 70mm. The machine would try to move to Z(G53)= +10mm.

The Z-axis then moves down at the "fast probe fr" speed until the tool probe switches or the Z-axis has covered the "spindle zero" distance.  
The latter leads to an error message: "G38.4: Movement completed without contact closure."  
When the button has switched, the Z-axis moves up by the "retract dist" value.  
If a speed is defined for "slow probe fr" (>0), the machine approaches the probe again at this speed.  
The Z-axis then moves to the machine zero point. 
If the measurement is successful, the measured value is displayed.  
The machine now stops during manual measurement.


### Case 3.1 known tool (length >0mm):  
If the "#<use_tool_table>" parameter is "1", this sequence is used for known tools (length >0mm). Otherwise case 2.1 is used.  
Starting from the old tool length, the Z axis moves the tool with G0 as high over the probe as defined under "#<tool_min_dis>".  
"#<tool_min_dis>" should not be defined too small in order to be able to absorb differences when inserting the tool.  
The Z-axis then moves down at the "fast probe fr" speed until the tool probe switches or the Z-axis has covered the "z max travel" distance.  
The latter leads to an error message: "G38.4: Movement completed without contact closure."  
When the button has switched, the Z-axis moves up by the "retract dist" value. If a speed is defined for "slow probe fr" (>0), the machine moves the probe
again at this speed.  
The Z-axis then moves to the machine zero point.  
If the measurement is successful, the measured value is displayed.  
The machine now stops during manual measurement.  


Sequence of the subroutine when measuring from the CNC program (M600):
When called, the subroutine differentiates between four cases: new tool (length <=0mm), known tool (length >0mm), same tool and change to T0 .


### Case 1.2 and 2.2:  
The measurement of new and known tools works the same way in the measurement that is started by the CNC program.  
See "Case 2.1" and "Case 3.1" above.  
However, before the Z-axis moves down, the tool change is required.  
In addition, you can use the fixed parameter "#<go_back_to_start_pos>" (1) in the routine to select that the machine, after the measurement, returns to the point where the routine was called. So you don't have to program the return path from the tool probe in the CNC program.  
Drives the machine back due to "#<go_back_to_start_pos>". Can be selected via "#<brake_after_M600>" (0/1/2) whether the machine waits at the point before
the CNC program continues to run.  
"0" does not pause.  
"1" pauses using "M00" command. Continue driving by pressing [CYCLE START]  
"2" makes a break using the "M01" command if [M01 BREAK] is also active in Probe Basic. Continue driving by pressing [CYCLE START]


### Case 3.2 same tool:  
Is the selected tool already in the machine? The message "Same tool" is output.  
"#<brake_after_M600>" (0/1/2) can be used to select whether the machine waits at this point before the CNC program continues to run.  
"0" does not pause.  
"1" pauses using "M00" command. Continue driving by pressing [CYCLE START]  
"2" makes a break using the "M01" command if [M01 BREAK] is also active in Probe Basic. Continue driving by pressing [CYCLE START]


### Case 4.2 Change to T0:  
***A change at the end of the CNC program using "M600 T0" can cause LinuxCNC to switch from G43 to G49 if the program aborts!  
If the program is restarted, it may not switch back to G43. Danger of collision!  
The case only serves to ensure that a measurement is not accidentally started with tool 0.***


## Further information:  
The "xy max travel" parameter is not used in the routine.
