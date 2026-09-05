# Profile 聚合入口 — 所有可选 profile 在此导入 + 共享选项声明。

{
  config,
  lib,
  pkgs,
  ...
}:

let
  linuxOnlyProfiles = [
    "base-desktop"
    "china-apps"
    "containers"
    "dev"
    "gaming"
    "hardware"
    "life"
    "modern-wm"
    "observability"
    "theming"
  ];
in
{
  options.mcb.git = {
    userName = lib.mkOption {
      type = lib.types.str;
      default = "your-name";
      description = "Git user.name for commits.";
    };
    userEmail = lib.mkOption {
      type = lib.types.str;
      default = "you@example.com";
      description = "Git user.email for commits.";
    };
  };

  imports = [
    ./base-desktop.nix
    ./dev.nix
    ./research.nix
    ./gaming.nix
    ./china-apps.nix
    ./media.nix
    ./life.nix
    ./theming.nix
    ./nix-tools.nix
    ./containers.nix
    ./observability.nix
    ./hardware.nix
    ./security-tools.nix
    ./ai-tools.nix
    ./modern-wm.nix
    ./terminal-tools.nix
  ];

  config.assertions = map (profile: {
    assertion =
      !config.mcb.profiles.${profile} || (config.mcb.platform.linux && pkgs.stdenv.hostPlatform.isLinux);
    message =
      "Profile '${profile}' requires the explicit Linux platform capability; "
      + "system '${pkgs.system}' must import homeModules.linux.";
  }) linuxOnlyProfiles;
}
