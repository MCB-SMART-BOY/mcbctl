# Profile: Nix 极客工具 — nom, nix-index, comma, nh, nix-tree, nix-du
{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.mcb.profiles.nix-tools = lib.mkEnableOption "Nix 极客工具（nom/nix-index/comma/nh/nix-tree/nix-du）";

  config = lib.mkIf config.mcb.profiles.nix-tools {
    home.packages = with pkgs; [
      # 构建进度可视化——替代原始 nix build 输出
      nix-output-monitor

      # 文件→包反向查询（nix-locate 命令）
      nix-index

      # 临时运行未安装的包（, <cmd> 语法）
      comma

      # 统一 nixos-rebuild/nix-collect-garbage 入口
      nh

      # 交互式依赖树
      nix-tree

      # 闭包体积分析
      nix-du

      # URL → Nix fetcher 表达式
      nurl
    ];
  };
}
