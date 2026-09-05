# Profile: 国内应用 — 代理 GUI / 动漫 CLI
# GUI 企业应用（QQ/微信/B站）和动漫漫画 GUI → 交 Flatpak 管理（modules/options.nix mcb.flatpak.apps）
{
  config,
  lib,
  pkgs,
  ...
}:
let
  # niri + NVIDIA 下对比 Native Wayland 与 XWayland；Mesa EGL 只作用于
  # 该 WeMeet 入口，不污染全局 GLVND 或其他 Wayland 应用。
  wemeetXwaylandMesa = pkgs.writeShellApplication {
    name = "wemeet-xwayland-mesa";
    text = ''
      export __EGL_VENDOR_LIBRARY_FILENAMES="${pkgs.mesa}/share/glvnd/egl_vendor.d/50_mesa.json"
      exec ${pkgs.wemeet}/bin/wemeet-xwayland "$@"
    '';
  };
in
{
  options.mcb.profiles.china-apps = lib.mkEnableOption "国内应用（会议/代理GUI/动漫CLI）";

  config = lib.mkIf config.mcb.profiles.china-apps {
    mcb.desktop.providers.wemeet = lib.mkDefault true;
    home.packages = with pkgs; [
      # ── 国内会议/办公 ──
      # 保留 nixpkgs 默认集成的社区 wemeet-wayland-screenshare
      # compatibility hook；niri SHM fallback 负责非 DMA-BUF 客户端。
      wemeet
      wemeetXwaylandMesa # NVIDIA 对照路径：XWayland + Mesa EGL

      # ── 代理 GUI ──
      clash-nyanpasu # Clash GUI（MetaCubeX 生态）
      metacubexd # MetaCubeX 仪表盘/控制前端

      # ── 动漫 CLI（GUI 交 Flatpak） ──
      ani-cli # 终端动漫工具

      # kazumi → Flatpak (io.github.Predidit.Kazumi)
      # bilibili / mangayomi 保留 nixpkgs；venera 已被新版 nixpkgs 移除：
      bilibili
      mangayomi
    ];
    # ⚠ mangal → go install（运行 bootstrap-toolchain）
  };
}
