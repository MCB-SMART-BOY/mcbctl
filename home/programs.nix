# Home Manager 程序功能开关与默认配置。

{ ... }:

{
  # Neovim 由 nixvim.nix 声明式配置；语言工具沿用各生态工具链。
  # Helix 编辑器（配置在 home/config/helix/）
  programs.helix = {
    enable = true;
  };
}
