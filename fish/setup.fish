#!/usr/bin/env fish

# XDG Base Directories
set -Ux XDG_CONFIG_HOME $HOME/.config
set -Ux XDG_DATA_HOME $HOME/.local/share
set -Ux XDG_STATE_HOME $HOME/.local/state
set -Ux XDG_CACHE_HOME $HOME/.cache

# Create the directories if they don't exist
mkdir -p $XDG_CONFIG_HOME $XDG_DATA_HOME $XDG_STATE_HOME $XDG_CACHE_HOME

echo "XDG dirs set and created."

# Only set WSLg vars if running in WSL
if test -f /proc/version; and grep -qi microsoft /proc/version
    set -Ux DISPLAY :0
    set -Ux WAYLAND_DISPLAY wayland-0
    set -Ux XDG_RUNTIME_DIR /mnt/wslg/runtime-dir
    set -Ux PULSE_SERVER /mnt/wslg/PulseServer

    echo "WSL vars set"
end

