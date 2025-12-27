function walsec
    set script "$HOME/.local/bin/wbselecgen.sh"
    
    # If no argument, open the wallpaper selector
    if test (count $argv) -eq 0
        "$script"
        return
    end
    
    # If an argument is given, check it
    set img $argv[1]
    if not test -f "$img"
        echo "❌ File not found: $img"
        return 1
    end
    
    # Apply the wallpaper directly
    "$script" "$img"
end
