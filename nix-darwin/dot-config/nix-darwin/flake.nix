{
  description = "Twid's Darwin System Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs }:
  let
    configuration = { pkgs, ... }: {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages =
        [ 
          #pkgs.vim
          #pkgs.inotify-tools
          #pkgs.oh-my-zsh 
          #pkgs.wezterm # no luck on x86_64-darwin
          #pkgs.copyq # no luck on x86_64-darwin 
          #pkgs.dropbox
          pkgs.neovim
          pkgs.ranger
          pkgs.alacritty
          pkgs.kitty
          pkgs.mpd
          pkgs.ncmpcpp 
          pkgs.stow 
          pkgs.zoxide
          pkgs.fzf
          pkgs.ripgrep
          pkgs.silver-searcher
          pkgs.fd
          pkgs.python3
          pkgs.pyenv
          pkgs.nodenv
          pkgs.tmux
          pkgs.tmuxinator
          pkgs.nodejs_22
          pkgs.go
          pkgs.rustup
          pkgs.docker
          pkgs.docker-compose
          pkgs.colima
        ];

      # Auto upgrade nix package and the daemon service.
      services.nix-daemon.enable = true;
      # nix.package = pkgs.nix;

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Create /etc/zshrc that loads the nix-darwin environment.
      programs.zsh.enable = true;  # default shell on catalina
      # programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 4;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "x86_64-darwin";

      # System settings
      system.defaults = {
        dock.autohide = true;
        # dock.autohide-delay = 0.24;
        dock.autohide-delay = 0.17;
        dock.orientation = "left";
        NSGlobalDomain.InitialKeyRepeat = 200;
        NSGlobalDomain.KeyRepeat = 75;
      };

      # Homebrew needs to be installed on its own!
      homebrew.enable = true;
      homebrew.casks = [
        "firefox"
	      "wireshark"
        "google-chrome"
        "wezterm" # nix package does not work on x86_64-darwin
        "copyq" # nix package does not work on x86_64-darwin
        "dropbox" # nix package does not work on x86_64-darwin
        "font-dejavu-sans-mono-nerd-font"
        "docker"
      ];
      homebrew.brews = [
	      "imagemagick"
      ];
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#Twids-iMac-Pro
    darwinConfigurations."Twids-iMac-Pro" = nix-darwin.lib.darwinSystem {
      modules = [ configuration ];
    };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."Twids-iMac-Pro".pkgs;
  };
}
