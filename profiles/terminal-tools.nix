# Profile: 极客终端工具 — zellij, jujutsu
{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.mcb.profiles.terminal-tools = lib.mkEnableOption "极客终端增强（zellij/jujutsu，其余工具走 cargo install）";

  config = lib.mkIf config.mcb.profiles.terminal-tools {
    home.packages = with pkgs; [
      # 现代终端复用器（Rust，浮动窗格，WASM 插件，需 C 依赖）
      zellij

      # 现代 Git（Google 出品，需 openssl/libgit2 等 C 依赖）
      jujutsu
    ];
    # ⚠ atuin / broot / herdr → cargo install（纯 Rust，无 C 依赖，运行 bootstrap-toolchain）
  };
}
