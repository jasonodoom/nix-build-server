{
  description =
    "A build server configuration for Nix development and packaging.";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/master";
    ngipkgs.url = "github:ngi-nix/ngipkgs/main";
    vscode-server.url = "github:nix-community/nixos-vscode-server";
  };

  outputs = { self, nixpkgs, ngipkgs, vscode-server, ... }:
    let hostname = "moss.nix";
    in {
      nixosConfigurations = {
        moss-nix = nixpkgs.lib.nixosSystem rec {
          system = "x86_64-linux";
          modules = [
            ./configuration.nix

            # ngipkgs.nixosModules.flarum
            # ngipkgs.nixosModules.pretalx

            vscode-server.nixosModules.default

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

              users.users.moss = {
                isNormalUser = true;
                extraGroups = [ "wheel" ];
                hashedPassword =
                  "$6$2CHtJGJyxua6PJP5$jvzYLvuADfoR7gII4dHqvp0XCwLjLj0ouUsKTu9GtUXez6Sh2O9xXQ4TZ.Ut5C3bMwHvMcJmzHBPX9SYlCdat/";
                packages = with pkgs; [
                  curl
                  git
                  nixfmt
                  senpai
                  tmux
                  screen
                  vim
                  weechat
                  wget
                  htop
                ];

                environment.systemPackages = with pkgs; [ tailscale ];

                openssh.authorizedKeys = {
                  keys = [
                    # redundant with fetch below, but hard-coded for consistency
                    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFxpNuJzotmAhJnMeFFSY21wHp9jfx6EPCftfaOzWyHt jleightcap@schnittke"
                  ];
                  keyFiles = with builtins; [
                    (fetchurl {
                      url = "https://github.com/DMills27.keys";
                      sha256 =
                        "sha256:1swql188jhw99vbsjbi8xhdf73wmqrwdkwnxp67qy3w5lf02hp59";
                    })
                    (fetchurl {
                      url = "https://github.com/chickensoupwithrice.keys";
                      sha256 =
                        "sha256:0j5pxqspdrvpcwc9slkmix0rdfs3j0r09mhg29anvkb3zy73nclv";
                    })
                    (fetchurl {
                      url = "https://github.com/albertchae.keys";
                      sha256 =
                        "sha256:1wllbq80p7m4m2p021s0pkx9rqg7fii2lc8m2mn1pgcmh88zs96g";
                    })
                    (fetchurl {
                      url = "https://github.com/jasonodoom.keys";
                      sha256 =
                        "sha256:1i65babsl8l4am8651n0ph0i9ssyqwbky5q5kq34wdxwzqv7dakd";
                    })
                    (fetchurl {
                      url = "https://github.com/jleightcap.keys";
                      sha256 =
                        "sha256:0sgjm2j1259ck7zi13ik6sq0v032qlydy176ahavqn9qcp4fvsn2";
                    })
                  ];
                };
              };

              services = {
                tailscale.enable = true;
                vscode-server.enable = true;
                openssh.enable = true;
                xserver.enable = true;
                xserver.autorun = false;
                xserver.displayManager.startx.enable = true;
                openssh = {
                  enable = true;
                  settings = {
                    PermitRootLogin = "prohibit-password";
                    PasswordAuthentication = false;
                    X11Forwarding = true;
                  };
                };
              };

              system.stateVersion = "23.05";
            })
          ];
          specialArgs = { inherit self; };
        };
      };

    };
}
