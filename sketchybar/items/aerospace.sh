sketchybar --add event aerospace_workspace_change

# --------------------------------------------------------------------------------
# Aerospace Workspaces - MODIFIED SECTION
# --------------------------------------------------------------------------------

# Define your icons here.
# Paste your Nerd Font icons between the quotes.
# The *) is a wildcard that will be used for any workspace number not explicitly listed.
get_icon_for_workspace() {
    case "$1" in
        1) echo "" ;;  # Paste your icon for workspace 1 here
        2) echo "" ;;  # Paste your icon for workspace 2 here
        3) echo "󱜅" ;;  # Paste your icon for workspace 3 here
        4) echo "" ;;  # Paste your icon for workspace 4 here (same as 3, as you requested)
        5) echo "" ;;  # Paste your icon for workspace 5 here
        6) echo "󰸻" ;;  # Paste your icon for workspace 6 here
        *) echo "$1" ;;   # Fallback to the workspace number if no icon is defined
    esac
}

for sid in $(aerospace list-workspaces --all); do
    ICON=$(get_icon_for_workspace "$sid") # Get the icon for the current workspace

    sketchybar --add item space.$sid left \
        --subscribe space.$sid aerospace_workspace_change \
        --set space.$sid \
            padding.left=8 \
            background.color=0x44ffffff \
            background.corner_radius=5 \
            background.height=20 \
            background.drawing=off \
            \
            icon.drawing=on \
            icon="$ICON" \
            \
            label.drawing=off \
            \
            click_script="aerospace workspace $sid" \
            script="$CONFIG_DIR/plugins/aerospace.sh $sid"
done
