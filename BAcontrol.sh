#! /bin/bash
echo "==============================================Battery Control=================================================="
echo "usage: BAcontroll.sh <lvl. to poweroff> <start time> <end time>"
echo "default values: 15% from 00:00 till 06:00"
echo -e "examples: <BAcontrol.sh 15 01 13> <BAcontrol.sh 20> <BAcontrol.sh>"
echo "---------------------------------------------------------------------------------------------------------------"
CHARGE=$(acpi | cut -d " " -f4 | sed 's/%,//g')
TIME=$(date +"%H")
MIN=$(date +"%M")
ISCHARGING=$(acpi | cut -d " " -f3 | sed 's/,//g')

if [[ $(acpi | cut -d " " -f3 | sed 's/,//g') == "Charging" ]]
  then
    ISCHARGING=1
  else
    ISCHARGING=0
fi
if (( $(date +"%M") == 0 ))
  then
    _60MIN=0
  else
    _60MIN=60
fi

function checker {
  if (( $CHARGE <= $1 && $ISCHARGING == 0 ))
    then
      if (( $TIME > 9 || $TIME == 0 ))
        then
          echo "Critical level. Shutdown in 5 minutes." | $(festival --tts)
          echo "Critical level. Shutdown in 5 minutes."
        else
          echo "Critical level. Shutdown in 5 minutes."
      fi
      $(shutdown 5)
      echo "Turned of at $TIME hours and $MIN minutes plus 5min" > /home/oleskiy/turned_off.log
      while (( $CHARGE <= $1 && $CHARGE > 7 ))
        do
          if (( $ISCHARGING == 0 ))
            then
              if (( $TIME > 9 || $TIME == 0 ))
                then
                  echo "Please plug in power wire" | $(festival --tts)
                  echo "Please plug in power wire"
                else
                  echo "Please plug in power wire"
              fi
          fi
          sleep 15
          if (( $ISCHARGING ))
            then
              echo "Shutdown cancelled. Charging." | $(festival --tts)
              echo "Next check" | $(festival --tts)
              sleep 1
              echo "after 2 hours" | $(festival --tts)
              $(shutdown -c)
              echo "Shutdown cancelled. Charging."
              echo "Next check after 2 hours."
              sleep 7200
              /home/oleskiy/bin/BAcontrol.sh 15 00 23 &
              exit 0
          fi
        done
  elif (( $CHARGE <= 100 && $CHARGE >= 50 ))
    then
      if (( $TIME > 9 || $TIME == 0 ))
        then
          echo "Acceptable charge level" | $(festival --tts)
          echo "Next check" | $(festival --tts)
          echo "after 2 hours" | $(festival --tts)
          echo "Charge is between 50% and 100%. Acceptable charge."
          echo "Acceptable charge level"
          echo "Next check after 2 hours..."
        else
          echo "Charge is between 50% and 100%. Acceptable charge."
          echo "Acceptable charge level"
          echo "Next check after 2 hours..."
      fi
      echo "============================================================================================"
      sleep 7200
      /home/oleskiy/bin/BAcontrol.sh 15 00 23 &
      exit 0
  elif (( $CHARGE > 20 && $CHARGE < 50 ))
    then
      if (( $TIME > 9 || $TIME == 0 ))
        then
          echo "Normal charge level" | $(festival --tts)
          echo "Charge is between 20% and 50%. Middle charge."
          echo "Normal charge level"
          echo "Next check after 1 hour..."
        else
          echo "Charge is between 20% and 50%. Middle charge."
          echo "Normal charge level"
          echo "Next check after 1 hour..."
      fi
      echo "============================================================================================"
      sleep 3600
      /home/oleskiy/bin/BAcontrol.sh 15 00 23 &
      exit 0
  else
    echo "Low battery... Less than $1%. Weak charge."
    if (( $TIME > 9 || $TIME == 0 ))
      then
        echo "Weak charge level" | $(festival --tts)
        echo "Weak charge level"
        echo "Will double-check every 25 min..."
      else
        echo "Weak charge level"
        echo "Will double-check every 25 min..."
    fi
    echo "============================================================================================"
    sleep 1500
    /home/oleskiy/bin/BAcontrol.sh 15 00 23 &
    exit 0
  fi
}

function notifying {
  if (( $TIME > 9 || $TIME == 0 ))
    then
      echo "Checking the battery." | $(festival --tts)
      sleep 1
      echo "Battery has $CHARGE% charge level." | $(festival --tts)
      echo "$(date)"
      echo "Will check battery from $2:00 till $3:00"
      echo "Will turn off computer if battery level will be less then or equal to $1%"
      echo "$(acpi)"
    else
      echo "$(date)"
      echo "Will check battery from $2:00 till $3:00"
      echo "Will turn off computer if battery level will be less then or equal to $1%"
      echo "$(acpi)"
  fi
}

function BatCheck {
  if (( $2 > $3 ))
    then
      if (( $TIME >= $2 || $TIME < $3 ))
        then
          notifying $1 $2 $3
          checker $1
      fi
    else
      if (( $TIME >= $2 && $TIME <= $3 ))
        then
          notifying $1 $2 $3
          checker $1
      fi
  fi
  if (( $TIME < $2 ))
    then
      notifying $1 $2 $3
      REST=$((($2 - $TIME) * 3600 - ($MIN * 60) ))
      echo "Control scheduled from $2:00 till $3:00"
      echo "Estimating time: $((REST / 3600)) hours and $(($_60MIN - $MIN)) minutes"
      echo "============================================================================================"
      sleep $REST
      sleep 2
      /home/oleskiy/bin/BAcontrol.sh 15 00 23 &
      exit 0
  elif (( $TIME > $3 ))
    then
      notifying $1 $2 $3
      REST=$((($2 + 24 - $TIME) * 3600 - ($MIN * 60) ))
      echo "Control scheduled from $2:00 till $3:00"
      echo "Estimating time: $((REST / 3600)) hours and $(($_60MIN - $MIN)) minutes"
      echo "============================================================================================"
      sleep $REST
      sleep 2
      /home/oleskiy/bin/BAcontrol.sh 15 00 23 &
      exit 0
  fi
}

if (( $# != 3 ))
  then
    echo "Only 3 args"
    echo "Idiot, check out usage..."
    echo "============================================================================================="
    exit 0
  else
    BatCheck $1 $2 $3
fi

exit 0
