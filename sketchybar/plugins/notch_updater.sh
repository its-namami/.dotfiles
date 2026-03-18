#!/bin/bash

# A state file to store the name of the frontmost application
STATE_FILE="$HOME/.config/sketchybar/app_name.state"

# If the script is triggered by an app switch, $INFO will contain the app name.
# We save it to the state file for later.
if [ -n "$INFO" ]; then
  echo "$INFO" > "$STATE_FILE"
fi

# Read the last known app name from our state file. Default to "Desktop".
APP_NAME=$(cat "$STATE_FILE" 2>/dev/null || echo "Desktop")

# Get the time in your desired format.
TIME=$(date '+%a||%H:%M')

# Set BOTH the icon and the label of our single 'notch' item.
sketchybar --set notch icon="$APP_NAME" label="$TIME"
