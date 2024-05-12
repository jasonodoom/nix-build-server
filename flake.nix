
i{
  description =
    "A build server configuration for Nix development and packaging.";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/master";
    ngipkgs.url = "github:ngi-nix/ngipkgs/main";
    vscode-server.url = "github:nix-community/nixos-vscode-server";
  };

  outputs = { self, nixpkgs, ngipkgs, vscode-server, ... }@inputs:
    let hostName = "moss-nix";
    in {
      nixosConfigurations = {
        moss-nix = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./configuration.nix
            vscode-server.nixosModules.default
            { networking.hostName = hostName; }
            ({ config, pkgs, ... }: {
              nix = {
                settings = {
                  auto-optimise-store = true;
                  experimental-features = [ "nix-command" "flakes" ];
                  sandbox = true;
                };
                gc = {
                  automatic = true;
                  dates = "weekly";
                  options = "--delete-older-than 7d";
                };
              };

              programs.bash.enableCompletion = true;
              programs.bash.promptInit = ''
              PS1="\[\033[01;34m\]\u@\[\033[01;32m\]\h \[\033[00m\]λ "
              '';

              users.users.moss = {
                isNormalUser = true;
                extraGroups = [ "wheel" ];
                hashedPassword =
                  "$6$2CHtJGJyxua6PJP5$jvzYLvuADfoR7gII4dHqvp0XCwLjLj0ouUsKTu9GtUXez6Sh2O9xXQ4TZ.Ut5C3bMwHvMcJmzHBPX9SYlCdat/";
                packages = with pkgs; [
                  curl
                  git
                  gh
                  nixfmt-classic
                  senpai
                  tmux
                  screen
                  vim
                  weechat
                  wget
                  htop
                  tailscale
                ];

                openssh.authorizedKeys = {
                  keys = [
                    # redundant with fetch below, but hard-coded for consistency
                    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKQRbcTH0OZCQciQLgFXDqqqbc0383pXA/65JlZqpCyQ jason@theophany"
                  ];
                  keyFiles = with builtins;
                    [
                      (fetchurl {
                        url = "https://github.com/jasonodoom.keys";
                        sha256 =
                          "sha256:1i65babsl8l4am8651n0ph0i9ssyqwbky5q5kq34wdxwzqv7dakd";
                      })
                    ];
                };
              };

              services = {
                tailscale.enable = true;
                vscode-server.enable = true;
                xserver = {
                  enable = true;
                  autorun = false;
                  displayManager.startx.enable = true;
                };
                openssh = {
                  enable = true;
                  settings = {
                    PermitRootLogin = "prohibit-password";
                    PasswordAuthentication = false;
                    X11Forwarding = true;
                  };
                };
              };

              system.stateVersion = "23.11";
            })
          ];
        };

        moss-nix-aarch64 = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          crossSystem = nixpkgs.lib.systems.examples.aarch64-multiplatform;
          modules = [
            ./configuration.nix
            vscode-server.nixosModules.default
            ({ config, pkgs, ... }:
              {
                # Duplicate settings for aarch64
              })
          ];
        };
      };
    };
}
