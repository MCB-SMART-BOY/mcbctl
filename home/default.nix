# 用户配置入口：只提供无身份的 Home Manager 模块。

{ config, lib, ... }:

{
  imports = [
    ./nixvim.nix
    ./base.nix
    ./programs.nix
    ./mpv.nix
    ./shell.nix
    ./git.nix
    ./packages.nix
    ./files.nix
    ./scripts.nix
  ];

  options.mcb.platform = {
    linux = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether the explicit Linux platform module is enabled.";
    };
    niri = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether the explicit Niri desktop module is enabled.";
    };
    nixos = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether the explicit NixOS integration module is enabled.";
    };
  };

  options.mcb.desktop.providers = {
    kazumi = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether the host provides the Kazumi Flatpak.";
    };
    steam = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether the host provides Steam.";
    };
    wemeet = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether the Home Manager configuration provides Wemeet.";
    };
    clashVerge = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether the host provides the Clash Verge command.";
    };
  };

  config = {
    assertions = [
      {
        assertion = !config.mcb.platform.niri || config.mcb.platform.linux;
        message = "The Niri desktop module requires homeModules.linux.";
      }
    ];
    home.stateVersion = "26.05";
    programs.home-manager.enable = true;
    xdg.enable = true;
  };
}
