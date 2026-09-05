# Profile: 生活工具 — 日历/天气/密码管理/下载/系统面板（yt-dlp 迁 uv tool install）
{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.mcb.profiles.life = lib.mkEnableOption "生活工具（日历/天气/工具/下载/备份/分区）";

  config = lib.mkIf config.mcb.profiles.life {
    home.packages = with pkgs; [
      # ── GNOME 生活应用 ──
      gnome-calendar # 日历
      gnome-clocks # 时钟
      gnome-calculator # 计算器
      gnome-weather # 天气
      glib.bin # Weather 桌面入口需要 gapplication
      gnome-maps # 地图
      gnome-contacts # 通讯录
      baobab # 磁盘占用可视化
      mission-center # 现代图形化系统监控

      # ── 工具 ──
      localsend # 局域网文件传输
      deja-dup # 图形化备份工具
      keepassxc # 密码管理（桌面应用，保留 Nix）
      simple-scan # 扫描仪前端

      # ── 下载 ──
      qbittorrent # BT 下载（桌面应用，保留 Nix）
      aria2 # 多协议下载

      # ── 系统面板 ──
      gparted # 分区管理
      pavucontrol # 音频设备控制
    ];
    # ⚠ yt-dlp → uv tool install（运行 bootstrap-toolchain）
  };
}
