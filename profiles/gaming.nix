# Profile: 游戏 — 平台 / 兼容层 / 性能工具
{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.mcb.profiles.gaming = lib.mkEnableOption "游戏（Steam/MangoHud/Proton/Lutris/Wine）";

  config = lib.mkIf config.mcb.profiles.gaming {
    mcb.desktop.providers.steam = lib.mkDefault true;
    # linux-wallpaperengine / ffmpeg / mangohud / protonup-qt / lutris — 系统层 gaming 包组已管理
    home.packages = with pkgs; [

      # Windows 兼容层
      wineWow64Packages.stable # Wine（32/64 位兼容）
      winetricks # Wine 运行库安装脚本
    ];
  };
}
