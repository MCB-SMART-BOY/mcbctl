# Profile: 主题 — 图标 / 光标 / GTK 外观
{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.mcb.profiles.theming = lib.mkEnableOption "桌面主题（图标/光标/GTK 主题）";

  config = lib.mkIf config.mcb.profiles.theming {
    home.packages = with pkgs; [
      adwaita-icon-theme # GNOME 默认图标
      gnome-themes-extra # GNOME 主题补充（Murrine 引擎）
      (tela-circle-icon-theme.override { colorVariants = [ "dracula" ]; }) # Tela-circle dracula 图标（Garuda Mokka 同款）
      nwg-look # GTK/图标主题切换 GUI
      nixos-artwork.wallpapers.catppuccin-mocha # Catppuccin Mocha 壁纸
    ];

    # GTK 主题 + 光标：从 Garuda Mokka ISO 直接复制，存于 assets/themes/
    # 由 files.nix 通过 xdg.dataFile 安装到 ~/.local/share/themes/ 和 ~/.local/share/icons/
    gtk = {
      enable = true;
      theme.name = "Catppuccin-Purple-Dark-Catppuccin";
      iconTheme.name = "Tela-circle-dracula-dark";
      cursorTheme = {
        name = "Catppuccin-Mocha-Mauve-Cursors";
        size = 24;
      };
      gtk3.extraConfig.gtk-application-prefer-dark-theme = 1;
      gtk2.extraConfig = ''
        gtk-im-module="fcitx"
      '';
    };
  };
}
