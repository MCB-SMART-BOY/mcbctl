# Profile: 现代 Wayland 桌面组件 — 启动器/状态栏/通知/锁屏
{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.mcb.profiles.modern-wm = lib.mkEnableOption "现代 Wayland 桌面组件（waybar/walker/swaynotificationcenter/swaylock-effects）";

  config = lib.mkIf config.mcb.profiles.modern-wm {
    home.packages = with pkgs; [
      # 非 GNOME Wayland 会话的图形 PolicyKit 认证代理
      polkit_gnome

      # Wayland 状态栏
      waybar

      # 现代 Wayland 启动器（AI 语义搜索）
      walker

      # 应用启动器（另一种风格）
      anyrun

      # 通知中心
      swaynotificationcenter

      # 锁屏特效增强
      swaylock-effects

      # Wayland 壁纸管理
      swaybg

      # 屏幕截图增强（satty 替代 swappy，更现代）
      satty

      # 剪贴板历史（wl-clipboard 在 modules/packages.nix waylandTools）
      cliphist

      # 屏幕录制
      wf-recorder

      # 色彩管理
      wlsunset # 夜间色温

      # Wayland 启动器
      rofi
    ];
  };
}
