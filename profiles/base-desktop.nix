# Profile: 基础桌面 — 终端/浏览器/文件管理/媒体播放/Wayland 基础
{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.mcb.profiles.base-desktop = lib.mkEnableOption "基础桌面环境（终端、浏览器、文件管理、媒体播放、Wayland 基础工具）";

  config = lib.mkIf config.mcb.profiles.base-desktop {
    # Wayland 工具已移至系统层 modules/packages.nix（waylandTools）
    # 系统默认开启（modules/options.nix: enableWaylandTools = true）
    home.packages = with pkgs; [
      # 终端
      kitty # GPU 终端（图像协议 + 连字）
      # 浏览器
      firefox # 开源浏览器
      telegram-desktop # Telegram 客户端
      google-chrome # Chromium 系浏览器
      # 文件管理
      nautilus # GUI 文件管理器
      file-roller # 图形化压缩/解压管理器
      # 媒体播放
      vlc # 多媒体播放器
      imv # 图片查看器（Wayland 友好）
      loupe # GNOME 现代图片查看器
      zathura # PDF 阅读器（键盘友好）
      papers # GNOME 现代文档/PDF 阅读器
      kdePackages.kdenlive # 视频剪辑

      # niri / pipewire — 系统级（programs.niri.enable / services.pipewire.enable 已管理）
    ];

  };
}
