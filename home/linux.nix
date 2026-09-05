# Linux Home Manager 模块：仅提供通用 Linux 平台能力。
{
  pkgs,
  ...
}:
{
  assertions = [
    {
      assertion = pkgs.stdenv.hostPlatform.isLinux;
      message = "homeModules.linux requires a Linux system.";
    }
  ];

  mcb.platform.linux = true;
}
