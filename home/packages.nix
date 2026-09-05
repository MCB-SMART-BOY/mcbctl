# 默认只启用跨平台工具；Linux 桌面能力通过 home.linux 显式接入。

{ config, lib, ... }:

{
  imports = [
    ../profiles/default.nix
  ];

  mcb.profiles = {
    nix-tools = lib.mkDefault true;
    terminal-tools = lib.mkDefault true;

    base-desktop = lib.mkDefault config.mcb.platform.linux;
    modern-wm = lib.mkDefault config.mcb.platform.niri;
    theming = lib.mkDefault config.mcb.platform.niri;
  };
}
