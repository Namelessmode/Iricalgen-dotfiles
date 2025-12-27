if status is-interactive
	#set -U fish_greeting ""
	starship init fish | source

	alias pamcan pacman
	alias fastfetch="$HOME/.local/bin/fastfetch.sh"
end
