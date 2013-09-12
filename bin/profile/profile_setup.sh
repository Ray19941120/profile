#!/bin/sh

# Check prerequisites
command -v git 2>&1 >/dev/null || echo "Git missing, cannot go on..." && exit 1

# Goto home directory
cd $HOME

# Download and install vcsh if not already there
if ! command -v vcsh >/dev/null 2>&1; then
	git clone https://github.com/RichiH/vcsh.git "$HOME/bin/vcsh"
	export PATH="$PATH:$HOME/bin/vcsh"
fi

# Get profile repository
vcsh clone https://github.com/oliv5/profile.git
