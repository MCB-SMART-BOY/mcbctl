# Neovim：nixvim 管理编辑器与插件，语言工具统一从 PATH 解析。
{ ... }:

{
  imports = [
    ./nixvim/core.nix
    ./nixvim/plugins.nix
    ./nixvim/tooling.nix
    ./nixvim/dap.nix
    ./nixvim/keymaps.nix
    ./nixvim/lsp.nix
  ];
}
