# 用户脚本打包：portable core 默认启用，Linux 入口显式接线。

{
  config,
  pkgs,
  lib,
  ...
}:

let
  niri = config.mcb.platform.niri;
  mkScript =
    {
      name,
      runtimeInputs ? [ ],
    }:
    pkgs.writeShellApplication {
      inherit name runtimeInputs;
      text = builtins.readFile ./scripts/${name};
    };

  portableScripts = {
    # 随机选取 logo 后调用真正的 fastfetch（logo 池在 ~/.local/share/fastfetch/logos/）。
    fastfetch = pkgs.writeShellApplication {
      name = "fastfetch";
      text = ''
        logo_dir="$HOME/.local/share/fastfetch/logos"
        if [ -d "$logo_dir" ]; then
          files=()
          for f in "$logo_dir"/*; do
            [ -f "$f" ] && files+=("$f")
          done
          count=''${#files[@]}
          if [ "$count" -gt 0 ]; then
            exec ${pkgs.fastfetch}/bin/fastfetch --logo "''${files[$((RANDOM % count))]}" "$@"
          fi
        fi
        exec ${pkgs.fastfetch}/bin/fastfetch "$@"
      '';
    };

    # JSON keeps schema validation and row extraction in the required jq runtime.
    mcb-toolchain = pkgs.writeShellApplication {
      name = "mcb-toolchain";
      runtimeInputs = [
        pkgs.jq
        pkgs.rustup
        pkgs.elan
        pkgs.go
        pkgs.uv
        pkgs.bun
        pkgs.opam
      ];
      text = builtins.readFile ./scripts/mcb-toolchain;
    };
  };

  niriScripts = {
    lock-screen = mkScript {
      name = "lock-screen";
    };

    niri-run = mkScript {
      name = "niri-run";
    };

    steam-launcher = mkScript {
      name = "steam-launcher";
    };
  };

  mkBinLink = scripts: name: {
    source = "${scripts.${name}}/bin/${name}";
  };
in
{
  home.packages = lib.mkAfter (
    builtins.attrValues portableScripts ++ lib.optionals niri (builtins.attrValues niriScripts)
  );

  home.file = lib.mkMerge [
    {
      ".local/bin/mcb-toolchain" = mkBinLink portableScripts "mcb-toolchain";
    }
    (lib.mkIf niri {
      ".local/bin/lock-screen" = mkBinLink niriScripts "lock-screen";
      ".local/bin/niri-run" = mkBinLink niriScripts "niri-run";
      ".local/bin/steam-launcher" = mkBinLink niriScripts "steam-launcher";
    })
  ];
}
