#!/bin/bash
#Version date: 2025-02-24
#Version: 6.0.0

## TODO

# 
tabname="tool_length_probe"
backup="backup"
remaps=("REMAP=M600 modalgroup=6 ngc=m600" "REMAP=M601 modalgroup=6 ngc=m601" "REMAP=M300 modalgroup=7 ngc=m300" "REMAP=M500 modalgroup=7 ngc=m500")
emcio=("TOOL_CHANGE_AT_G30 = 0" "TOOL_CHANGE_QUILL_UP = 0")
parms=(2949 2951 2952 2953 2954 2955 2956 2957 2958 2959 2960 2961 2962)
pbminversion="0.6.0-37"
qtminversion="5.0.2-5"

# Stores the date and time when the script is started
printf -v date '%(%Y-%m-%d_%H-%M)T' -1

# Colors for massages
NC='\033[0m'
Red='\033[1;31m'
Green='\033[1;32m'
Yellow='\033[1;33m'

# Get version number from the subroutine.
tlpversion=$(grep -i "^;Version: " "./subroutines/tool_touch_off.ngc")
tlpversion=${tlpversion##*;Version: }

# Check Probe Basic version
instpbversion=$(dpkg-query -W  --showformat="\${Version}" "*probe-basic" 2>/dev/null)
$(dpkg --compare-versions "$pbminversion" "le" "$instpbversion")
if [ $? = 0 ]; then
    echo -e "Probe Basic V$instpbversion [${Green}INSTALLED${NC}]"
else
    echo -e "tool_length_probe V6 required as a minimum Probe Basic ${Yellow}$pbminversion${NC} ."
    echo "Please install that or a higher version before."
    echo ""
    echo -e "If you want to use Probe Basic ${Yellow}$tlpversion${NC}, tool_length_probe V5 is your target version."
    echo -e "If you use Probe Basic ${Yellow}0.5.4-stable${NC} or below, you need to use tool_lenght_probe V4.0.1 ."
    echo "You can find all releases here:"
    echo "https://github.com/TooTall18T/tool_length_probe/releases"
    exit 1
fi

# Check QTPYVCP version
instqtversion=$(dpkg-query -W  --showformat="\${Version}" "*qtpyvcp" 2>/dev/null)
$(dpkg --compare-versions "$qtminversion" "le" "$instqtversion")
if [ $? = 0 ]; then
    echo -e "QTPYVCP V$instqtversion [${Green}INSTALLED${NC}]"
else
    echo -e "tool_length_probe V6 required as a minimum QTPYVCP ${Yellow}$qtminversion${NC} ."
    echo "Please install that or a higher version before."
    exit 1
fi


# Print a message
echo "This installation script is intended to simplify the installation of \"tool_length_probe\" V$tlpversion (by TooTall18T for Probe Basic)."
echo ""
echo "The script will create a backup directory and will copy all files into it that will be exchanged or modified."
echo "If it is not possible to copy a file, it will not be modified and you get a message for that."
echo "When this happened. Please make the modification by hand. You can see all steps in the manual."
echo ""
echo "The script is limited in what it can do. If your machine configuration deviates too much from the standard,"
echo "it may not be possible to carry out individual steps or even all of them."
echo "In this case, it is also necessary to carry out the steps manually."
echo ""
echo "In the first step the script need to check if it can find all nessessory files and directories."
echo ""
echo "Enter your machine .ini-file (absolute path):"

read inifile

# Creates two variables from the input
inifile=${inifile/\~/$HOME}
ininame=${inifile##*\/}
echo ".ini name: $ininame"
inipath=${inifile/$ininame/""}
echo ".ini path: $inipath"

# Check if .ini-file is at given directory
if [ -f "$inifile" ]; then
    found=true
    echo -e "ini-file: $ininame [${Green}FOUND${NC}]."

    # Check for "SUBROUTINE_PATH" in .ini-file
    sub_path=$(grep -i ^[[:blank:]]*SUBROUTINE_PATH "$inifile")
    if [ $? = 0 ]; then
        sub_path=${sub_path%%:*}
        sub_path=${sub_path##*=}
        sub_path=${sub_path//" "/""}
        sub_path=${sub_path/%\//""}
        if [ -d "$inipath$sub_path" ]; then
            echo -e "SUBROUTINE_PATH: $sub_path [${Green}FOUND${NC}]."
            # Check for read and write permission 
            if [ -r "$inipath$sub_path" ] && [ -w "$inipath$sub_path" ];then
                echo -e "\"$sub_path\" read write [${Green}ALLOWED${NC}]."
            else
                echo -e "\"$sub_path\" read write [${Red}NOT ALLOWED${NC}]."
                found=false
            fi
        else
            echo -e "SUBROUTINE_PATH: $sub_path [${Red}NOT FOUND${NC}]"
            found=false
        fi
    else
        echo -e "\"SUBROUTINE_PATH\" [${Red}NO ENTRY${NC}]"
        found=false
    fi
    

    # Check for "USER_TABS_PATH" in .ini-file
    nousertabpath=false
    tabs_path=$(grep -i ^[[:blank:]]*USER_TABS_PATH "$inifile")
    if [ $? = 0 ]; then
        tabs_path=${tabs_path/"USER_TABS_PATH"/""}
        tabs_path=${tabs_path/"="/""}
        tabs_path=${tabs_path//" "/""}
        tabs_path=${tabs_path/%\//""}
        # Check if user tabs folder is at given directory
        if [ -d "$inipath$tabs_path" ]; then
            echo -e "USER_TABS_PATH: $tabs_path [${Green}FOUND${NC}]"
            # Check for read and write permission 
            if [ -r "$inipath$tabs_path" ] && [ -w "$inipath$tabs_path" ];then
                echo -e "\"$tabs_path\" read write [${Green}ALLOWED${NC}]."
            else
                echo -e "\"$tabs_path\" read write [${Red}NOT ALLOWED${NC}]."
                found=false
            fi
        else
            echo -e "USER_TABS_PATH: $tabs_path [${Red}NOT FOUND${NC}]"
            found=false
        fi
    else
        echo -e "\"USER_TABS_PATH\" [${Yellow}NO ENTRY${NC}]"
        echo "Default \"USER_TABS_PATH = user_tabs/\" will be created."
        nousertabpath=true
    fi


    # Check for "CONFIG_FILE" in .ini-file
    conf_file=$(grep -i ^[[:blank:]]*CONFIG_FILE "$inifile")
    if [ $? = 0 ]; then
        conf_file=${conf_file/"CONFIG_FILE"/""}
        conf_file=${conf_file/"="/""}
        conf_file=${conf_file//" "/""}
        # Check if .yml-file is at given directory
        if [ -f "$inipath$conf_file" ]; then
            echo -e "CONFIG_FILE: $conf_file [${Green}FOUND${NC}]"
            # Check for read and write permission 
            if [ -r "$inipath$conf_file" ] && [ -w "$inipath$conf_file" ];then
                echo -e "\"$conf_file\" read write [${Green}ALLOWED${NC}]."
            else
                echo -e "\"$conf_file\" read write [${Red}NOT ALLOWED${NC}]."
                found=false
            fi
        else
            echo -e "CONFIG_FILE: $conf_file [${Red}NOT FOUND${NC}]"
            found=false
        fi
    else
        echo -e "\"CONFIG_FILE\" [${Red}NO ENTRY${NC}]"
        found=false
    fi
    

    # Check for "PARAMETER_FILE" in .ini-file
    parms_file=$(grep -i ^[[:blank:]]*PARAMETER_FILE "$inifile")
    if [ $? = 0 ]; then
        parms_file=${parms_file/"PARAMETER_FILE"/""}
        parms_file=${parms_file/"="/""}
        parms_file=${parms_file//" "/""}
        # Check if .var-file is at given directory
        if [ -f "$inipath$parms_file" ]; then
            echo -e "PARAMETER_FILE: $parms_file [${Green}FOUND${NC}]"
            # Check for read and write permission 
            if [ -r "$inipath$parms_file" ] && [ -w "$inipath$parms_file" ];then
                echo -e "\"$parms_file\" read write [${Green}ALLOWED${NC}]."
            else
                echo -e "\"$parms_file\" read write [${Red}NOT ALLOWED${NC}]."
                found=false
            fi
        else
            echo -e "PARAMETER_FILE: $parms_file [${Red}NOT FOUND${NC}]"
            found=false
        fi
    else
        echo -e "\"PARAMETER_FILE\" [${Red}NO ENTRY${NC}]"
        found=false
    fi


    # Check for "TOOL_TABLE" in .ini-file
    tool_table=$(grep -i ^[[:blank:]]*TOOL_TABLE "$inifile")
    if [ $? = 0 ]; then
        tool_table=${tool_table/"TOOL_TABLE"/""}
        tool_table=${tool_table/"="/""}
        tool_table=${tool_table//" "/""}
        # Check if .tbl-file is at given directory
        if [ -f "$inipath$tool_table" ]; then
            echo -e "TOOL_TABLE: $tool_table [${Green}FOUND${NC}]"
            # Check for read and write permission 
            if [ -r "$inipath$tool_table" ] ;then
                echo -e "\"$tool_table\" read [${Green}ALLOWED${NC}]."
            else
                echo -e "\"$tool_table\" read [${Yellow}NOT ALLOWED${NC}]."
            fi
        else
            echo -e "TOOL_TABLE: $tool_table [${Yellow}NOT FOUND${NC}]"
        fi
    else
        echo -e "\"TOOL_TABLE\" [${Yellow}NO ENTRY${NC}]"
    fi

    

    abortcom=$(grep -i ^[[:blank:]]*ON_ABORT_COMMAND "$inifile")
    if ! [ $? = 0 ]; then
        echo -e "${Yellow}The parameter \"ON_ABORT_COMMAND\" could not be found but would be recommanded under \"[RS274NGC]\".${NC}"
    else
        echo -e "The parameter \"ON_ABORT_COMMAND\" [${Green}FOUND${NC}]"
    fi



    #if [ 1 = 0 ]; then
    if [ $found = true ]; then
        echo "All files and directories were found. Should the installation be carried out now? (YES/no)"
        read answer
        #answer="NO"
        if [ $answer = "YES" ]; then
            # Creates backup directory
            if ! [ -d "$inipath$backup" ]; then
                $(mkdir "$inipath$backup"  &>/dev/null)
            fi
            # Creates a directory in "backup" with date and time (YYYY-MM-DD_HH-MM)
            if [ $? = 0 ]; then 
                $(mkdir  "$inipath$backup/$date" &>/dev/null)
            fi
            # Checks if the backup directory is created
            if [ -d "$inipath$backup/$date" ]; then
                echo -e "\"$backup/$date/\" directory [${Green}CREATED${NC}]"

                # Copies the tool table .tbl-file to the backup directory
                echo -e "${Yellow}[Tool table file]${NC}"
                $(cp -np "$inipath$tool_table" "$inipath$backup/$date/")
                if [ $? = 0 ]; then
                    echo -e "\"$tool_table\" [${Green}SAVED${NC}]"
                else
                    echo -e "\"$tool_table\" [${Yellow}NOT SAVED${NC}]"
                fi

                echo -e "${Yellow}[Machine config file]${NC}"
                # Copies the machine .ini-file to the backup directory
                $(cp -np "$inifile" "$inipath$backup/$date/")
                state1=$?
                $(cmp -s "$inifile" "$inipath$backup/$date/$ininame")
                state2=$?
                if [ $state1 = 0 ] && [ $state2 = 0 ]; then
                    echo -e "\"$ininame\" [${Green}SAVED${NC}]"
                
                    # Adds "USER_TABS_PATH" parameter to .ini-file
                    if [ $nousertabpath = true ]; then
                        line=$(grep -n "^[[:blank:]]*\[DISPLAY\]"  "$inifile")
                        line=$[${line%%:*}+1]
                        sed -i -e "$line i USER_TABS_PATH = user_tabs\/" "$inifile"
                        echo -e "\"USER_TABS_PATH\" [${Green}ADDED${NC}]"
                    fi


                    # Determines the line number of "[RS274NGC\]" in the .ini-file
                    line=$(grep -n "^[[:blank:]]*\[RS274NGC\]"  "$inifile")
                    line=$[${line%%:*}+1]
                    # Adds the remap parameters into the machine .ini-file below "[RS274NGC]"
                    for((i=0;i<${#remaps[*]};i++)); do
                        var=$(grep -i "^[[:blank:]]*${remaps[i]%% *}" "$inifile")
                        if [ $? = 0 ]; then
                            var="${var#"${var%%[![:blank:]]*}"}"
                            if [ "$var" = "${remaps[i]}" ]; then
                                echo -e "\"${remaps[i]}\" [${Green}PRESENT${NC}]"
                            else
                                echo -e "\"${remaps[i]%% *}\" [${Red}DUPLICATE${NC}]"
                                echo "Check in [RS274NGC] for a duplicate of \"${remaps[i]%% *}\""
                                echo "The needed remap need to look like this: ${remaps[i]}"
                                sed -i -e "$line i ${remaps[i]}" "$inifile"
                                line=$[$line+1]
                                echo -e "\"${remaps[i]}\" [${Yellow}ADDED${NC}]."
                            fi                            
                        else
                            sed -i -e "$line i ${remaps[i]}" "$inifile"
                            line=$[$line+1]
                            echo -e "\"${remaps[i]}\" [${Green}ADDED${NC}]."
                        fi
                    done


                    # Determines the line number of "[EMCIO]" in the .ini-file
                    line=$(grep -n "^[[:blank:]]*\[EMCIO\]"  "$inifile")
                    line=$[${line%%:*}+1]
                    # Adds the emcio parameters into the machine .ini-file below "[EMCIO]"
                    for((i=0;i<${#emcio[*]};i++)); do
                        var=$(grep -i "^[[:blank:]]*${emcio[i]%% *}" "$inifile")
                        if [ $? = 0 ]; then
                            var="${var#"${var%%[![:blank:]]*}"}"
                            if [ "$var" = "${emcio[i]}" ]; then
                                echo -e "\"${emcio[i]}\" [${Green}PRESENT${NC}]"
                                continue
                            else
                                $(sed -r -i -e "s/^([[:blank:]])*${emcio[i]%% *}/\1###${emcio[i]%% *}/1" "$inifile")
                                if [ $? = 0 ]; then
                                    echo -e "Inappropriate parameter found \"$var\" [${Green}COMMENTED OUT${NC}]"
                                fi
                            fi
                        fi
                        sed -i -e "$line i ${emcio[i]}" "$inifile"
                        line=$[$line+1]
                        echo -e "\"${emcio[i]}\" [${Green}ADDED${NC}]."
                        
                    done


                    # Comment out the line "TOOL_CHANGE_POSITION" in .ini-file
                    $(grep -i -q "^[[:blank:]]*TOOL_CHANGE_POSITION" "$inifile")
                    if [ $? = 0 ]; then
                        $(sed -r -i -e "s/^([[:blank:]])*TOOL_CHANGE_POSITION/\1###TOOL_CHANGE_POSITION/1" "$inifile")
                        if [ $? = 0 ]; then 
                            echo -e "\"TOOL_CHANGE_POSITION\" [${Green}COMMENTED OUT${NC}]"
                        fi
                    else
                        echo -e "\"TOOL_CHANGE_POSITION\" [${Green}NOT PRESENT${NC}]"
                    fi

                    echo -e "${Yellow}[User tab]${NC}"
                    if [ $nousertabpath = true ]; then
                        # Creates the user tap directory
                        tabs_path="user_tabs"
                        if ! [ -d "$inipath$tabs_path" ]; then
                            $(mkdir "$inipath$tabs_path" &>/dev/null)
                            if [ $? = 0 ]; then 
                                echo -e "\"user_tabs\" directory [${Green}CREATED${NC}]"
                            else 
                                echo -e "\"user_tabs\" directory [${Red}NOT CREATED${NC}]"
                            fi
                        fi
                    else
                        # Moves the tab directory to "backup" if it exsists
                        if [ -d "$inipath$tabs_path/$tabname" ]; then
                            $(mv  "$inipath$tabs_path/$tabname" "$inipath$backup/$date/" &>/dev/null)
                            if [ $? = 0 ]; then
                                echo -e "\"$tabname\" [${Green}SAVED${NC}]"
                            else
                                echo -e "\"$tabname\" [${Red}NOT SAVED${NC}]"
                            fi
                        fi
                    fi
                    # Copies the tab directory into the machine "user_tabs" directory
                    $(cp -np -r "./user_tabs/$tabname" "$inipath$tabs_path/" &>/dev/null)
                    if [ $? = 0 ]; then
                        echo -e "New \"$tabname\" [${Green}COPIED${NC}]"
                    else
                        echo -e "New \"$tabname\" [${Red}NOT COPIED${NC}]"
                        echo "Please copie the \"$tabname\" folder into the user tab directory by hand."
                    fi


                    echo -e "${Yellow}[Subroutines]${NC}"
                    $(mkdir  "$inipath$backup/$date/$sub_path")
                    if [ $? = 0 ]; then
                        echo -e "\"$backup/$date/$sub_path/\" directory [${Green}CREATED${NC}]"
                        # Copies all subroutines into the machine "subroutines" directory
                        array=($(ls ./subroutines))
                        for((i=0;i<${#array[*]};i++)); do
                            if [ -f "$inipath$sub_path/${array[i]}" ]; then
                                $(mv  "$inipath$sub_path/${array[i]}" "$inipath$backup/$date/$sub_path" &>/dev/null)
                                if [ $? = 0 ]; then
                                    echo -e "Old \"${array[i]}\" [${Green}SAVED${NC}]"
                                else
                                    echo -e "Old \"${array[i]}\" [${Red}NOT SAVED${NC}]"
                                    echo "The new subroutine \"${array[i]}\" is not copied to protect the old one."
                                    echo "Please do it by hand."
                                    continue
                                fi
                            fi
                            $(cp -np  "./subroutines/${array[i]}" "$inipath$sub_path/"  &>/dev/null)
                            if [ $? = 0 ]; then
                                echo -e "New \"${array[i]}\" [${Green}COPIED${NC}]"
                            else
                                echo -e "New \"${array[i]}\" [${Red}NOT COPIED${NC}]"
                            fi
                        done
                    else
                        echo -e "\"$backup/$date/$sub_path/\" directory [${Red}NOT CREATED${NC}]"
                        echo "Old subroutines were not saved and new ones were not copied!"
                        echo "Please do it by hand."
                    fi  

                    echo -e "${Yellow}[GUI config file]${NC}"
                    # Copies the machine .yml-file to the backup directory
                    $(cp -np "$inipath$conf_file" "$inipath$backup/$date/"  &>/dev/null)
                    state1=$?
                    $(cmp -s "$inipath$conf_file" "$inipath$backup/$date/$conf_file")
                    state2=$?
                    if [ $state1 = 0 ] && [ $state2 = 0 ]; then
                        echo -e "\"$conf_file\" ${Green}[SAVED]${NC}"

                        prov=false
                        while read line 
                        do 
                            if [ $prov = false ] && [[ "$line" == *"qtpyvcp.plugins.tool_table:ToolTable"* ]]; then
                            prov=true
                            continue
                            fi
                            if [ $prov = true ]; then
                                if [[ "$line" =~ (^ *columns:) ]]; then
                                    prov=false
                                    cpline=${line/"columns:"/""}
                                    cpline=${cpline//" "/""}
                                    if ! [[ $cpline = *"I"* ]]; then
                                        if ! [[ $cpline = *"R"* ]]; then
                                            cpline=$line"I"
                                            $(sed -r -i -e "s/^(([[:blank:]])*)$line/\1$cpline\2/" "$inipath$conf_file")
                                                if [ $? = 0 ]; then
                                                    echo -e "\"I\" parameter for tool table [${Green}SET${NC}]"
                                                fi
                                        else
                                            cpline=${line//"R"/"IR"}
                                            $(sed -r -i -e "s/^(([[:blank:]])*)$line/\1$cpline\2/" "$inipath$conf_file")
                                            if [ $? = 0 ]; then
                                                echo -e "\"I\" parameter for tool table [${Green}SET${NC}]"
                                            fi
                                        fi
                                        break
                                    else
                                        echo -e "\"I\" parameter for tool table [${Green}PRESENT${NC}]"
                                        break
                                    fi
                                fi
                            fi
                        done < "$inipath$conf_file"



                        # Adds the "include" to the .yml-file
                        $(grep -q -i "^[[:blank:]]*{% include \"$tabs_path/$tabname/$tabname.yml\" %}" "$inipath$conf_file")
                        if ! [ $? = 0 ]; then
                            $(sed -i -e '/^settings:/a\' -e  '  \{\% include \"'$tabs_path/$tabname/$tabname'.yml\" \%\}' "$inipath$conf_file")
                            if [ $? = 0 ]; then
                                echo -e "\"INCLUDE\" [${Green}ADDED${NC}]"
                            else
                                echo -e "\"INCLUDE\" [${Red}NOT ADDED${NC}]"
                                echo "It was not possible to made the \"include\"."
                                echo "Please do it by hand."
                                echo "Insert below \"settings:\":"
                                echo "  \{\% include \"'$tabs_path/$tabname/$tabname'.yml\" \%\}"
                            fi
                        else
                            echo -e "\"INCLUDE\" [${Green}PRESENT${NC}]"
                        fi

                    else
                        echo -e "\"$conf_file\" ${Red}[NOT SAVED]${NC}"
                        echo "To prevent the old file, the \"include\" was not made."
                        echo "Please do it by hand."
                        echo "Insert below \"settings:\":"
                        echo "  \{\% include \"'$tabs_path/$tabname/$tabname'.yml\" \%\}"
                    fi

                    echo -e "${Yellow}[Parameter file]${NC}"
                    # Copies the .var-file to the backup directory
                    $(cp -np "$inipath$parms_file" "$inipath$backup/$date/"  &>/dev/null)
                    state1=$?
                    state2=$(cmp -s "$inipath$parms_file" "$inipath$backup/$date/$parms_file")
                    state2=$?
                    if [ $state1 = 0 ] && [ $state2 = 0 ]; then
                        echo -e "\"$parms_file\" [${Green}SAVED${NC}]"
                        # Adds the parameter 2950 till 2962 to the .var-file
                        for((i=0;i<${#parms[*]};i++)); do
                            $(grep -q -i "^${parms[i]}" "$inipath$parms_file")
                            if [ $? = 0 ]; then
                                echo -e "\"${parms[i]}\" [${Green}PRESENT${NC}]"
                                parms[i]="-"${parms[i]}
                            else
                                n=1
                                while read line 
                                do 
                                    if [ ${line%%[[:blank:]]*} -gt ${parms[i]} ]; then
                                    sed -i -e "$n i ${parms[i]}\t0.000000" "$inipath$parms_file"
                                    echo -e "\"${parms[i]}\t0.000000\" [${Green}ADDED${NC}]"
                                    break
                                fi  
                                n=$(($n+1))
                                done < "$inipath$parms_file"
                            fi
                        done
                    else
                        echo -e "\"$parms_file\" ${Red}[NOT SAVED]${NC}"
                        echo "To prevent the old file, the \"include\" was not made."
                        echo "Please do it by hand."
                    fi
                    echo -e "${Green}FINISH${NC}"
                else
                    echo -e "Installation ${Red}ABORT${NC}!"
                    echo "Not able to create backup of $inifile!"
                    exit 1
                fi

            else
                echo -e "Installation ${Red}ABORT${NC}!"
                echo "Not able to create "backup" directory!"
                exit 1
            fi
        else
            echo ""
            echo -e "${Red}CANCELED!${NC}"    
            exit 1
        fi
    else
        echo ""
        echo -e "${Red}ERROR IN INI-FILE${NC}"
        exit 1
    fi

else
    echo -e "ini-file: $inifile ${Red}NOT FOUND${NC}"
    exit 1
fi
exit 0
