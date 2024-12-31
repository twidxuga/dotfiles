# Twid's recipe to backup homebrew packages:

# Homebrew list all installed packages and casks 
brew list --full-name --installed-on-request > brew-list.txt

# Hobebrew list all installed packages and dependencies
brew deps --tree --installed > brew-deps.txt

