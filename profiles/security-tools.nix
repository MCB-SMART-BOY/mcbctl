# Profile: 安全审计与渗透测试 — gitleaks, trivy, hashcat, john, burpsuite, metasploit, 取证/加密工具
{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.mcb.profiles.security-tools = lib.mkEnableOption "安全审计与渗透测试工具（gitleaks/trivy/hashcat/john/burpsuite/metasploit/取证/加密）";

  config = lib.mkIf config.mcb.profiles.security-tools {
    home.packages = with pkgs; [
      # ── 密码破解 ──
      hashcat # GPU 加速密码破解
      john # John the Ripper

      # ── Web 测试 ──
      burpsuite # Web 代理（社区版）

      # ── 网络扫描 ──
      metasploit # 渗透测试框架

      # ── 取证 ──
      autopsy # 磁盘取证
      foremost # 文件恢复

      # ── 加密工具 ──
      gnupg # GnuPG
      paperkey # 纸质密钥备份

      # ── 密钥扫描 / 依赖审计（OMP 提交门禁 validate.sh 刚需）──
      gitleaks # 密钥泄漏扫描
      trivy # 依赖与文件系统漏洞审计
    ];
    # ⚠ nuclei → go install, ffuf → go install, sqlmap → uv tool install
    # 运行 bootstrap-toolchain 一键安装
  };
}
