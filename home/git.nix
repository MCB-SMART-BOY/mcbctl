# Git 配置（选项定义在 profiles/default.nix 共享 hub 中）。

{ config, lib, ... }:

let
  cfg = config.mcb.git;
  editor = "hx";
in
{
  config = {
    mcb.git.userName = lib.mkDefault "your-name";
    mcb.git.userEmail = lib.mkDefault "you@example.com";

    programs.git = {
      enable = true;
      lfs.enable = true;
      settings = {
        user = {
          name = cfg.userName;
          email = cfg.userEmail;
        };
        core = {
          editor = editor;
          pager = "delta";
        };
        interactive.diffFilter = "delta --color-only";
        delta = {
          navigate = true;
          "side-by-side" = true;
        };
      };
    };
  };
}
