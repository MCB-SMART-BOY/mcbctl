# Profile: 硬件交互与固件 — nvme-cli, fwupd, cpuid, dmidecode
{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.mcb.profiles.hardware = lib.mkEnableOption "硬件诊断与固件工具（nvme-cli/fwupd/cpuid/dmidecode）";

  config = lib.mkIf config.mcb.profiles.hardware {
    home.packages = with pkgs; [
      # NVMe SSD 管理
      nvme-cli

      # 固件更新（UEFI/SSD/外设）
      fwupd

      # CPU 特性检测
      cpuid

      # PCI/USB 设备信息
      pciutils
      usbutils

      # BIOS/DMI 信息
      dmidecode
      # 蓝牙工具
      bluez # 蓝牙协议栈核心工具集
      bluez-tools # 蓝牙命令行辅助工具
      blueman # 蓝牙图形管理器

      # 磁盘健康监控
      smartmontools

      # 磁盘参数调优
      hdparm
      sdparm

      # UEFI 启动项管理
      efibootmgr

      # Secure Boot 管理
      sbctl

      # BIOS/固件读写
      flashrom
    ];
  };
}
