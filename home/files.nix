# 用户配置文件部署：portable core 默认启用，Linux/NixOS 内容显式接线。

{
  config,
  lib,
  ...
}:

let
  linux = config.mcb.platform.linux;
  niri = config.mcb.platform.niri;
  nixos = config.mcb.platform.nixos;
  portableFishFunctions = [
    "_mcb_toolchain"
    "backup"
    "bootstrap-toolchain"
    "check-toolchain"
    "copy"
    "extract"
    "fcd"
    "fe"
    "history"
    "mkcd"
    "upgrade-toolchain"
  ];
  nixosFishFunctions = [
    "_mcb_flake_dir"
    "_mcb_flake_ref"
    "_mcb_flake_source"
    "_mcb_flake_target"
    "nfu"
    "nrb"
    "nrc"
    "nrs"
    "nrt"
    "nru"
  ];
  fishFunctionFiles =
    names:
    builtins.listToAttrs (
      map (name: {
        name = "fish/functions/${name}.fish";
        value = {
          source = ./config/fish/functions + "/${name}.fish";
        };
      }) names
    );
in
{
  config = lib.mkMerge [
    {
      # Shell / Tmux 配置
      programs.zsh.initContent = builtins.readFile ./config/zsh/.zshrc;
      xdg.configFile =
        (fishFunctionFiles portableFishFunctions)
        // (lib.optionalAttrs nixos (fishFunctionFiles nixosFishFunctions))
        // {
          "fish/config.fish".source = lib.mkForce ./config/fish/config.fish;
          "fish/conf.d".source = ./config/fish/conf.d;
          "toolchain/tools.json".source = ./config/toolchain/tools.json;
          "starship.toml".source = ./config/starship/starship.toml;
          "btop/btop.conf".source = ./config/btop/btop.conf;
          "btop/themes/noctalia.theme".source = ./config/btop/themes/noctalia.theme;
          "fastfetch/config.jsonc".source = ./config/fastfetch/mokka.jsonc;
          "kitty/kitty.conf".source = ./config/kitty/kitty.conf;
          "helix/config.toml".source = ./config/helix/config.toml;
          "helix/languages.toml".source = ./config/helix/languages.toml;
          "clangd/config.yaml".source = ./config/clangd/config.yaml;
        };
      programs.tmux.extraConfig = builtins.readFile ./config/tmux/tmux.conf;

      # fastfetch 随机 logo 池（wrapper 从中随机选取）
      home.file.".local/share/fastfetch/logos/logo-01.png".source = ./assets/fastfetch-logos/logo-01.png;
      home.file.".local/share/fastfetch/logos/logo-02.png".source = ./assets/fastfetch-logos/logo-02.png;
      home.file.".local/share/fastfetch/logos/logo-03.webp".source =
        ./assets/fastfetch-logos/logo-03.webp;

    }
    (lib.mkIf niri {
      xdg.configFile."niri/config.kdl".source = ./config/niri/config.kdl;
      xdg.configFile."niri/outputs.kdl".source = ./config/niri/outputs.kdl;
      xdg.configFile."niri/rules.kdl".source = ./config/niri/rules.kdl;
      xdg.configFile."niri/binds.kdl".source = ./config/niri/binds.kdl;
      xdg.configFile."fcitx5/profile".source = ./config/fcitx5/profile;
      xdg.configFile."fcitx5/conf/classicui.conf".source = ./config/fcitx5/conf/classicui.conf;

      home.file."Pictures/Wallpapers" = {
        source = ./assets/wallpapers;
        recursive = true;
      };
    })
    (lib.mkIf (linux && config.mcb.profiles.theming) {
      xdg.dataFile."themes/Catppuccin-Purple-Dark-Catppuccin" = {
        source = ./assets/themes/Catppuccin-Purple-Dark-Catppuccin;
        recursive = true;
      };
      xdg.dataFile."themes/Catppuccin-Purple-Dark-Catppuccin-hdpi" = {
        source = ./assets/themes/Catppuccin-Purple-Dark-Catppuccin-hdpi;
        recursive = true;
      };
      xdg.dataFile."themes/Catppuccin-Purple-Dark-Catppuccin-xhdpi" = {
        source = ./assets/themes/Catppuccin-Purple-Dark-Catppuccin-xhdpi;
        recursive = true;
      };
      xdg.dataFile."icons/Catppuccin-Mocha-Mauve-Cursors" = {
        source = ./assets/themes/Catppuccin-Mocha-Mauve-Cursors;
        recursive = true;
      };
    })
  ];
}
