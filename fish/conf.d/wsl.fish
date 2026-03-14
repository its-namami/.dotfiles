if test -f /proc/version; and grep -qi microsoft /proc/version
	# Apply Colemak-DH keyboard layout for X11 applications
	if test -n "$DISPLAY"
	    setxkbmap -print us -variant colemak_dh 2>/dev/null | xkbcomp - $DISPLAY 2>/dev/null
	end
end

