#!/bin/bash


# color codes

BLACK='\033[38;2;30;29;25m'
YELLOW='\033[38;2;255;210;0m'
WHITE='\033[38;2;238;238;238m'
RED='\033[38;2;158;3;0m'
RESET='\033[0m'
BOLD='\033[1m'
FRAMED='\033[51m'

SCRIPT_DIR=$(dirname "$(realpath "$0")")
LOG_FILE="$SCRIPT_DIR/radio_song.log"

if [ ! -w "$LOG_FILE" ]; then
    touch "$LOG_FILE"
fi

ascii_logo=$(cat << "EOF"
                         ++-------------++#                        
                    +-......................--+#                   
                +-...............................-+#               
              --....................................-+             
           +-.........................................--#          
         +-..............................................+         
        -.................................................-+       
      -.....................................................-#     
     -.......-#####+-....-+######+-..-#-..-+#####+-..........-#    
    -........+#-..-##-..-###+...-+#+.-#+.+#+....-+#+..........-#   
   -.........-#-..-+#-.-#+-#+-....+#--#--#+.......+#-..........-+  
  -..........+#+###+-.+#+++#+-....-#+-#--#+.......+#-...........-# 
 --..........+#-+#+.-##+---#+-...-##--#+-##-.....-#+-............- 
 -........-++##-.-####.....##+++##+..-#+.-+##+++##+..............-+
 -.........-----...--......------....---....-----.................+
-.......-####+-###+-###+-+#-+#####+-.-+#####--#+-.+###++###+......-
-......-##-.-#+.-#+-#-...+#-+#-...-##-+#.....+###-..-#++#-........-
........+##+--..-#+-#-...+#-+#-....-#++#-----+#-+#-.-#++#-.........
.........--+##+.-#+-#-...+#-+#-.....##+#++++-+#-.+#+-#++#-.........
-......-#+..-##--#+-#+...+#-+#-....+#++#.....+#-..-###++#-........-
-.......+##+##-.-#+-+##+##+-+######+--+#####-+#-...-##++#-........-
+.........---....--...---...-----.....------.--......--.-.........+
 -...........-########-....-+##--+###+--+####+.-####+............-+
 -...........+#-..-+###-...+#+#-+#-.-#+#+...-#+++..+#-...........-#
  -..........+#+---+#-#+..-#++#--##+##-#+...-#+..-+#+-..........-+ 
   -.........-#+++-+#--#+-#+.+#-+#+-+#+-##+##+-..--+#-.........-+  
   +-........+#-..-+#-.+###-.+#-#+..-+#-.-+#+-++-..-#+.........+   
     -.......+#-..-+#-.-+#-..+#-+##+##-..+#+##-+#++##-........+    
      -.......-.....-.........-...---....-...-...--.........-+     
       +...................................................-#      
         -...............................................-#        
          #-...........................................-+#         
            #--.....................................--+            
               +-.................................-+#              
                  #+-.........................-+#                  
                      #++-----.......-----++##                     
					  
EOF
)

echo "$ascii_logo"

# Start mpv in the background
mpv --ao=pipewire https://www.radiostudent.si/sites/all/libraries/rsplayer/player2.html > /dev/null 2>&1 &

#datestamp for .log file on startup
init_date=$(date)
echo -e "                                     " >> "$LOG_FILE"
echo -e "####################################" >> "$LOG_FILE"
echo -e "  $init_date" >> "$LOG_FILE"
echo -e "####################################" >> "$LOG_FILE"
echo -e "                                     " >> "$LOG_FILE"



# Initialize a variable to store the previous song information
previous_song=""
previous_song_info=""

# Function to fetch and display the latest song
fetch_latest_song() {
    while true; do
        current_song=$(curl -s https://dev.radiostudent.si/latest_song)
		current_song_info=$(echo "$current_song" | awk 'BEGIN {FS = ":"} {print $2}')
		if [[ "$current_song" == "Ni komada" && "$current_song" != "$previous_song" ]]; then
			clear
			echo -e "${RED}$ascii_logo${RESET}"
            echo -e "${WHITE}${FRAMED}Now Playing:${RESET}"
			echo -e "${RED}$current_song${RESET}"
			current_song_info="$current_song"
			previous_song="$current_song"
			previous_song_info="$current_song"
		elif [[ "$current_song_info" != "$previous_song_info" && "$current_song" != "Ni komada" ]]; then
            clear  
            echo -e "${YELLOW}$ascii_logo${RESET}"
            echo -e "${WHITE}Now Playing:${RESET}"
            echo -e "${YELLOW}$current_song${RESET}"
			echo -e "_______________________________________" >> "$LOG_FILE"
			echo -e "$current_song" | awk 'BEGIN {FS = "\""} { print $(NF -1) }' | awk ' { print "day:"$2" time:"$1}' >> "$LOG_FILE"
			echo -e "$current_song" | awk 'BEGIN {FS = "\""} {var=""; for (i = 2; i < (NF - 4); i++) var = var $i " "} END {print var}' >> "$LOG_FILE"
            previous_song="$current_song"
			previous_song_info=$(echo "$previous_song" | awk 'BEGIN {FS = ":"} {print $2}')
        fi
        sleep 4  # Fetch every 30 seconds
    done
}

# Run the fetch_latest_song function
fetch_latest_song
