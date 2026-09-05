# Home Manager Flake 输出：显式按 system 生成 standalone 配置。

{ inputs, self }:

let
  lib = inputs.nixpkgs.lib;
  supportedSystems = [
    "x86_64-linux"
    "aarch64-linux"
    "x86_64-darwin"
    "aarch64-darwin"
  ];
  canonicalUser = "admin";
  defaultHomeDirectories = {
    "x86_64-linux" = "/home/admin";
    "aarch64-linux" = "/home/admin";
    "x86_64-darwin" = "/Users/admin";
    "aarch64-darwin" = "/Users/admin";
  };
  mkPkgs =
    system:
    import inputs.nixpkgs {
      inherit system;
      config = {
        allowUnfree = true;
        # WinBoat 0.9.0 当前仍固定 Electron 40；Electron 41 会触发 node-abi 构建失败。
        permittedInsecurePackages = [ "electron-40.10.5" ];
      };
    };
  homeModules = {
    default = {
      imports = [
        inputs.nixvim.homeModules.nixvim
        ../home/default.nix
      ];
    };
    linux = {
      imports = [ ../home/linux.nix ];
    };
    niri = {
      imports = [
        ../home/desktop.nix
        ../home/noctalia.nix
      ];
      config.mcb.platform.niri = true;
    };
    nixos = {
      imports = [ ../home/nixos.nix ];
    };
  };
  mkHomeConfiguration =
    {
      system,
      username,
      homeDirectory,
      desktopEnvironment ? null,
      extraModules ? [ ],
    }:
    if !(builtins.elem system supportedSystems) then
      throw "Unsupported Home Manager system '${system}'; choose one of ${builtins.concatStringsSep ", " supportedSystems}."
    else if username == "" then
      throw "Home Manager username must not be empty."
    else if homeDirectory == "" then
      throw "Home Manager homeDirectory must not be empty."
    else if desktopEnvironment != null && desktopEnvironment != "niri" then
      throw "Unsupported Home Manager desktop environment '${desktopEnvironment}'; choose null or \"niri\"."
    else
      inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = mkPkgs system;
        modules = [
          homeModules.default
          {
            home.username = username;
            home.homeDirectory = homeDirectory;
          }
        ]
        ++ lib.optional (desktopEnvironment == "niri") homeModules.linux
        ++ lib.optional (desktopEnvironment == "niri") homeModules.niri
        ++ extraModules;
      };
  nixosProfileModule = {
    # Full workstation composition for the host-specific NixOS target.
    mcb.profiles = {
      base-desktop = true;
      dev = true;
      research = true;
      gaming = true;
      china-apps = true;
      media = true;
      life = true;
      theming = true;
      nix-tools = true;
      containers = true;
      observability = true;
      hardware = true;
      security-tools = true;
      ai-tools = true;
      modern-wm = true;
      terminal-tools = true;
    };
    mcb.desktop.providers = {
      kazumi = true;
      steam = true;
      wemeet = true;
      clashVerge = true;
    };
  };
  nixosHomeConfiguration = mkHomeConfiguration {
    system = "x86_64-linux";
    username = canonicalUser;
    homeDirectory = defaultHomeDirectories."x86_64-linux";
    desktopEnvironment = "niri";
    extraModules = [
      homeModules.nixos
      nixosProfileModule
    ];
  };
  homeConfigurations =
    (lib.listToAttrs (
      map (
        system:
        lib.nameValuePair "${canonicalUser}@${system}" (mkHomeConfiguration {
          inherit system;
          username = canonicalUser;
          homeDirectory = defaultHomeDirectories.${system};
          desktopEnvironment = null;
        })
      ) supportedSystems
    ))
    // {
      # This target is intentionally host-specific; portable targets remain unchanged.
      "${canonicalUser}@nixos" = nixosHomeConfiguration;
    };
  sanitizeTarget =
    target:
    "${lib.strings.sanitizeDerivationName target}-${
      builtins.substring 0 12 (builtins.hashString "sha256" target)
    }";
  mkChecks =
    system:
    let
      pkgs = mkPkgs system;
      homeConfiguration = homeConfigurations."${canonicalUser}@${system}";
      homeManagerEval =
        pkgs.runCommand "home-manager-eval-${sanitizeTarget system}"
          {
            drvPath = builtins.unsafeDiscardStringContext homeConfiguration.activationPackage.drvPath;
          }
          ''
            printf '%s\n' "$drvPath" > "$out"
          '';
      homeManagerBuild = pkgs.runCommand "home-manager-build-${sanitizeTarget system}" { } ''
        set -euo pipefail
        test -e ${homeConfiguration.activationPackage}/activate
        touch "$out"
      '';
      nixosHomeManagerEval =
        if system == "x86_64-linux" then
          pkgs.runCommand "home-manager-eval-nixos"
            {
              drvPath = builtins.unsafeDiscardStringContext nixosHomeConfiguration.activationPackage.drvPath;
            }
            ''
              printf '%s\n' "$drvPath" > "$out"
            ''
        else
          null;
    in
    {
      home-manager-eval = homeManagerEval;
      home-manager-build = homeManagerBuild;
      shell-syntax =
        pkgs.runCommand "mcbctl-shell-syntax-check"
          {
            nativeBuildInputs =
              (with pkgs; [
                bash
                coreutils
                fish
                findutils
                lua
                shellcheck
                taplo
                zsh
                nushell
              ])
              ++ lib.optional (lib.hasSuffix "-linux" system) pkgs.niri;
          }
          ''
            set -euo pipefail
            cd ${self}
            bash scripts/check/shell-syntax.sh
            touch "$out"
          '';
      shell-tests =
        pkgs.runCommand "mcbctl-shell-tests"
          {
            nativeBuildInputs = with pkgs; [
              bash
              bats
              coreutils
              fish
              jq
              nushell
            ];
          }
          ''
            set -euo pipefail
            cd ${self}
            bats --print-output-on-failure scripts/tests/
            touch "$out"
          '';
      statix-check =
        pkgs.runCommand "mcbctl-statix-check"
          {
            nativeBuildInputs = [ pkgs.statix ];
          }
          ''
            set -euo pipefail
            cd ${self}
            statix check .
            touch "$out"
          '';
      deadnix-check =
        pkgs.runCommand "mcbctl-deadnix-check"
          {
            nativeBuildInputs = [ pkgs.deadnix ];
          }
          ''
            set -euo pipefail
            cd ${self}
            deadnix --fail . 2>&1 | tee "$out"
            touch "$out"
          '';
    }
    // lib.optionalAttrs (nixosHomeManagerEval != null) {
      nixos-home-manager-eval = nixosHomeManagerEval;
    };
in
{
  inherit homeConfigurations homeModules;

  lib.mkHomeConfiguration = mkHomeConfiguration;

  packages = lib.genAttrs supportedSystems (system: {
    home-manager = (mkPkgs system).home-manager;
  });

  apps = lib.genAttrs supportedSystems (
    system:
    let
      homeManagerPackage = (mkPkgs system).home-manager;
    in
    {
      home-manager = {
        type = "app";
        program = lib.getExe homeManagerPackage;
      };
    }
  );

  checks = lib.genAttrs supportedSystems mkChecks;

  formatter = lib.genAttrs supportedSystems (system: (mkPkgs system).nixfmt);

  devShells = lib.genAttrs supportedSystems (
    system:
    let
      pkgs = mkPkgs system;
    in
    {
      default = pkgs.mkShell {
        packages = with pkgs; [
          deadnix
          gitleaks
          nixfmt
          statix
          trivy
        ];
      };
    }
  );
}
