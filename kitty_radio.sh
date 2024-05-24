#!/bin/bash

# kitty --class=radio --title=radio --hold ~/.config/waybar/scripts/radio.sh & kitty  --class=visualizer --title=visualizer cava


# Start the visualizer window
kitty --class=visualizer --title=visualizer cava &
visualizer_pid=$!

sleep 0.04
# Start the radio window
kitty --class=radio --title=radio --hold ~/.config/waybar/scripts/radio.sh &
radio_pid=$!

# Bring the radio window to the front using wmctrl
wmctrl -r radio -b toggle,above

# Function to clean up both processes
cleanup() {
    kill $radio_pid 2>/dev/null
    kill $visualizer_pid 2>/dev/null
    echo "Both windows closed."
    exit 0
}

# Trap the exit signal to clean up
trap cleanup EXIT

# Wait for the windows to appear
# sleep 2


# Wait for either process to exit
wait -n $radio_pid $visualizer_pid

# If one process exits, cleanup the other
cleanup
