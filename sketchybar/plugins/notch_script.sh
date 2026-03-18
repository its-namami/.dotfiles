#!/bin/bash

# A state file to store the name of the frontmost application
STATE_FILE="$HOME/.config/sketchybar/app_name.state"

# The `front_app_switched` event sends the app name in the $INFO variable.
# If $INFO is not empty, it means the app has switched. We save the new name.
if [ -n "$INFO" ]; then
  echo "$INFO" > "$STATE_FILE"
fi

# Read the last known app name from our state file.
# If the file doesn't exist yet, default to "Desktop".
CURRENT_APP=$(cat "$STATE_FILE" 2>/dev/null || echo "Desktop")

# Get the time in your desired format: Day||Hour:Minute
TIME=$(date '+%a||%H:%M')

# --- THIS IS THE FIX ---
# Use printf to correctly interpret the newline character.
# This creates a true multi-line string to pass to the label.
sketchybar --set notch_content label="$(printf "%s\n%s" "$CURRENT_APP" "$TIME")"
