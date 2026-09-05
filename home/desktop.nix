# Home Manager 桌面应用与输入法环境变量。

{
  config,
  lib,
  pkgs,
  ...
}:

let
  providers = config.mcb.desktop.providers;
  research = config.mcb.profiles.research;
  chinaApps = config.mcb.profiles.china-apps;
  clashVergeExec =
    if config.mcb.platform.nixos then "/run/wrappers/bin/clash-verge %U" else "clash-verge %U";

  xwaylandBridgePkg =
    if pkgs ? xwaylandvideobridge then
      let
        evaluated = builtins.tryEval pkgs.xwaylandvideobridge;
      in
      if evaluated.success && lib.isDerivation evaluated.value then evaluated.value else null
    else
      null;

in
{
  config = {
    home.packages = lib.optionals (xwaylandBridgePkg != null) [ xwaylandBridgePkg ];

    home.sessionVariables = {
      GTK_IM_MODULE = "fcitx";
      QT_IM_MODULE = "fcitx";
      SDL_IM_MODULE = "fcitx";
      GLFW_IM_MODULE = "fcitx";
      XMODIFIERS = "@im=fcitx";
      XIM_SERVERS = "fcitx";
    };

    xdg.mimeApps = lib.mkIf research {
      enable = true;
      defaultApplications = {
        "application/pdf" = [ "sioyek.desktop" ];
        "application/postscript" = [ "sioyek.desktop" ];
        "application/msword" = [ "libreoffice-writer.desktop" ];
        "application/rtf" = [ "libreoffice-writer.desktop" ];
        "application/vnd.openxmlformats-officedocument.wordprocessingml.document" = [
          "libreoffice-writer.desktop"
        ];
        "application/vnd.oasis.opendocument.text" = [ "libreoffice-writer.desktop" ];
        "application/vnd.ms-excel" = [ "libreoffice-calc.desktop" ];
        "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" = [
          "libreoffice-calc.desktop"
        ];
        "application/vnd.oasis.opendocument.spreadsheet" = [ "libreoffice-calc.desktop" ];
        "application/vnd.ms-powerpoint" = [ "libreoffice-impress.desktop" ];
        "application/vnd.openxmlformats-officedocument.presentationml.presentation" = [
          "libreoffice-impress.desktop"
        ];
        "application/vnd.oasis.opendocument.presentation" = [ "libreoffice-impress.desktop" ];
        "x-scheme-handler/zotero" = [ "zotero.desktop" ];
        "text/x-bibtex" = [ "zotero.desktop" ];
        "application/x-research-info-systems" = [ "zotero.desktop" ];
      };
    };

    xdg.desktopEntries = lib.mkMerge [
      (lib.mkIf research {
        "sioyek" = {
          name = "Sioyek";
          genericName = "PDF Viewer";
          comment = "PDF viewer optimized for research papers";
          exec = "sioyek %U";
          icon = "sioyek";
          categories = [
            "Office"
            "Viewer"
          ];
          mimeType = [
            "application/pdf"
            "application/postscript"
          ];
          startupNotify = true;
          terminal = false;
        };
        "zotero" = {
          name = "Zotero";
          genericName = "Reference Manager";
          comment = "Collect, organize and cite research";
          exec = "zotero %U";
          icon = "zotero";
          categories = [
            "Office"
            "Education"
            "Science"
          ];
          mimeType = [
            "x-scheme-handler/zotero"
            "text/x-bibtex"
            "application/x-research-info-systems"
          ];
          startupNotify = true;
          terminal = false;
        };
        "obsidian" = {
          name = "Obsidian";
          comment = "Knowledge base";
          exec = "obsidian %U";
          icon = "obsidian";
          categories = [ "Office" ];
          mimeType = [ "x-scheme-handler/obsidian" ];
          startupNotify = true;
          terminal = false;
        };
      })
      (lib.mkIf chinaApps {
        "io.github.msojocs.bilibili" = {
          name = "Bilibili";
          comment = "Bilibili Desktop";
          exec = "bilibili %U";
          icon = "io.github.msojocs.bilibili";
          categories = [
            "AudioVideo"
            "Video"
            "TV"
          ];
          settings = {
            Keywords = "bilibili;b站;视频;动漫;";
          };
          terminal = false;
        };
        "clash-nyanpasu" = {
          name = "Clash Nyanpasu";
          comment = "Clash Nyanpasu! (∠・ω< )⌒☆";
          exec = "clash-nyanpasu";
          icon = "clash-nyanpasu";
          categories = [ "Development" ];
          startupNotify = true;
          terminal = false;
        };
      })
      (lib.mkIf providers.clashVerge {
        "clash-verge" = {
          name = "Clash Verge";
          comment = "Clash Verge Rev";
          exec = clashVergeExec;
          icon = "clash-verge";
          categories = [ "Development" ];
          mimeType = [ "x-scheme-handler/clash" ];
          startupNotify = true;
          terminal = false;
        };
      })
    ];

    # Override Flatpak-exported desktop entry with PATH workaround for Glycin.
    # Flatpak export at /var/lib/flatpak/exports/share wins XDG_DATA_DIRS
    # precedence over /etc/profiles; placing in XDG_DATA_HOME ensures highest
    # priority.  PATH=/app/bin:/usr/bin lets Glycin's flatpak-spawn sandbox
    # find prlimit without granting host D-Bus permissions.
    xdg.dataFile = lib.mkMerge [
      (lib.mkIf providers.kazumi {
        "applications/io.github.Predidit.Kazumi.desktop".text = ''
          [Desktop Entry]
          Type=Application
          Name=Kazumi
          Comment=Watch Animes online with danmaku support.
          Exec=${pkgs.coreutils}/bin/env PATH=/app/bin:/usr/bin ${pkgs.flatpak}/bin/flatpak run io.github.Predidit.Kazumi
          Icon=io.github.Predidit.Kazumi
          Terminal=false
          StartupNotify=false
          Categories=AudioVideo;
          X-Flatpak=io.github.Predidit.Kazumi
        '';
      })
      (lib.mkIf providers.wemeet {
        # Native 与普通 XWayland 接收远端共享时，xcast 都持续返回 EGL
        # window surface error 3005；桌面入口默认走 XWayland + Mesa EGL。
        # `wemeet` 与 `wemeet-xwayland` 保留为 Native/GLVND 对照入口。
        "applications/wemeetapp.desktop".text = ''
          [Desktop Entry]
          Name=WemeetApp
          Name[zh_CN]=腾讯会议
          Exec=wemeet-xwayland-mesa %u
          Icon=wemeet
          Type=Application
          Terminal=false
          Categories=AudioVideo;
          MimeType=x-scheme-handler/wemeet;
        '';
      })
      (lib.mkIf providers.steam {
        "applications/steam.desktop".text = ''
          [Desktop Entry]
          Type=Application
          Name=Steam
          Comment=Steam Game Library
          Exec=${config.home.homeDirectory}/.local/bin/steam-launcher %U
          Icon=steam
          Terminal=false
          StartupNotify=false
          Categories=Game;
          MimeType=x-scheme-handler/steam;
        '';
      })
    ];
    systemd.user.services.xwaylandvideobridge = lib.mkIf (xwaylandBridgePkg != null) {
      Unit = {
        Description = "XWayland Video Bridge (screen sharing for X11 apps)";
        After = [
          "graphical-session.target"
          "pipewire.service"
          "xdg-desktop-portal.service"
        ];
        PartOf = [ "graphical-session.target" ];
        Wants = [
          "pipewire.service"
          "xdg-desktop-portal.service"
        ];
        ConditionPathExistsGlob = "%t/wayland-*";
      };
      Service = {
        ExecStart = "${xwaylandBridgePkg}/bin/xwaylandvideobridge";
        Restart = "on-failure";
        RestartSec = 2;
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}
