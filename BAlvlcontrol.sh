#! /bin/bash -x

while (( 1 > 0 ))
	do
		CHARGE=$(acpi | cut -d " " -f4 | sed 's/%,//g')
		if (( $(date +"%H") == 00 ))
			then
				TIME=23
			else
				TIME=$(date +"%H")
		fi
		MIN=$(date +"%M")
		if (( $MIN == 0 ))
			then
				_60MIN=0
			else
				_60MIN=60
		fi
		if [[ $(acpi | cut -d " " -f3 | sed 's/,//g') == "Charging" ]]
			then
				ISCHARGING=1
			else
				ISCHARGING=0
		fi
		if (( $ISCHARGING && $CHARGE >= 90 && $TIME > 9  ))
			then
				echo "Battery almost full." | festival --tts
				sleep 1
				echo "$CHARGE%" | festival --tts
				sleep 1
				while (( $CHARGE >= 90 ))
					do
						if [[ $(acpi | cut -d " " -f3 | sed 's/,//g') == "Charging" ]]
							then
								echo "Disable wire please" | festival --tts
								sleep 10
							else
								echo "Wire disabled" | festival --tts
								sleep 1
								echo "Next check" | festival --tts
								sleep 1
								echo  "after 4 hours" | festival --tts
								sleep 13200
						fi
					done
		elif (( $TIME < 9 ))
			then
				REST=$(((9 - $TIME) * 3600 - ($MIN * 60) ))
				echo "It is late hour. Will not disturb you till morning."
	                       	echo "Sleeping $((REST / 3600)) hours and $(($_60MIN - $MIN)) min"
        	               	sleep $REST
		fi
		sleep 1200
	done
exit 0
