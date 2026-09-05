# Home Manager Shell 配置入口（Fish/Zsh/Nushell/aliases/提示符）。

{
  config,
  lib,
  pkgs,
  ...
}:
let
  starshipNuConfig = pkgs.runCommand "starship-nushell-config.nu" { } ''
    ${lib.getExe config.programs.starship.package} init nu > "$out"
  '';
in
{

  programs.nushell = {
    enable = true;
    package = pkgs.nushell;
    configFile.source = ./config/nushell/config.nu;
    envFile.source = ./config/nushell/env.nu;
    extraConfig = lib.mkAfter ''
      if $nu.is-interactive and (($env.TERM? | default "") != "dumb") {
        source ${starshipNuConfig}
      }
    '';
    settings = {
      show_banner = false;
      edit_mode = "emacs";
      table.mode = "rounded";
      completions.case_sensitive = false;
      completions.external.enable = true;
      completions.external.max_results = 200;
      history.file_format = "sqlite";
      history.max_size = 50000;
      history.sync_on_enter = true;
      history.isolation = false;
      history.ignore_space_prefixed = true;
    };
    shellAliases = {
      g = "git";
      ga = "git add";
      gc = "git commit";
      gp = "git push";
      gl = "git pull";
      gs = "git status";
      gd = "git diff";
      gco = "git checkout";
      gb = "git branch";
      gst = "git stash";
      gcp = "git cherry-pick";
      grb = "git rebase";
      glg = "git log --oneline --graph --decorate";
      lg = "lazygit";
      c = "cargo";
      cb = "cargo build";
      cr = "cargo run";
      ct = "cargo test";
      cc = "cargo check";
      cw = "cargo watch -x check";
      cf = "cargo fmt";
      ccl = "cargo clippy";
      ca = "cargo add";
      cu = "cargo update";
      ll = "eza -l --icons --group-directories-first --git --time-style=long-iso";
      la = "eza -la --icons --group-directories-first --git";
      tree = "eza --tree --icons";
      bcat = "bat --paging=never --style=plain";
      catt = "bat --paging=always";
      grep = "grep --color=auto";
      md = "mkdir";
      rd = "rmdir";
      nsp = "nix search nixpkgs";
      nsh = "nix-shell";
      jctl = "journalctl -p 3 -xb";
      ports = "ss -tulanp";
      ip = "ip -color=auto";
      compress = "ouch compress";
      decompress = "ouch decompress";
      fdf = "fd";
      ssed = "sd";
      helpme = "tldr";
      http = "xh";
      mdview = "glow -p";
      ze = "zed";
      digg = "dig";
      dns = "doggo";
      pingg = "gping";
      j = "z";
      ji = "zi";
    };
  };

  programs.direnv = {
    enable = true;
    enableNushellIntegration = true;
    enableZshIntegration = false;
    enableFishIntegration = false;
  };

  programs.zoxide = {
    enable = true;
    enableNushellIntegration = true;
    enableZshIntegration = false;
    enableFishIntegration = false;
  };

  programs.zsh = {
    enable = true;
    dotDir = config.home.homeDirectory;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    initContent = lib.mkOrder 700 ''
      unsetopt nounset 2>/dev/null || true
    '';
    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "sudo"
        "docker"
        "rust"
        "fzf"
      ];
      theme = "robbyrussell";
    };
  };

  programs.tmux.enable = true;
  programs.fish.enable = true;

  programs.starship = {
    enable = true;
    enableNushellIntegration = false;
    enableZshIntegration = false;
    enableFishIntegration = false;
  };

  programs.bat = {
    enable = true;
    config.theme = "Catppuccin Mocha";
  };
}
