# Profile: 容器生态 — podman, distrobox, incus, qemu, WinBoat
{
  config,
  lib,
  pkgs,
  ...
}:
let
  winboatSystem = "x86_64-linux";
  winboatWithVmx = pkgs.winboat.overrideAttrs (oldAttrs: {
    postPatch = (oldAttrs.postPatch or "") + ''
      substituteInPlace src/renderer/data/docker.ts src/renderer/data/podman.ts \
        --replace-fail '                VERSION: "11",' \
          '                VERSION: "11",
                VMX: "Y",'
    '';
  });
in
{
  options.mcb.profiles.containers = lib.mkEnableOption "容器与虚拟化工具（podman/distrobox/incus/qemu/WinBoat）";

  config = lib.mkIf config.mcb.profiles.containers {
    assertions = [
      {
        assertion = pkgs.system == winboatSystem;
        message = "The containers profile requires system '${winboatSystem}' because WinBoat is x86_64-linux only.";
      }
    ];

    home.packages =
      with pkgs;
      [
        # 无守护进程 rootless 容器引擎
        podman
        podman-compose

        # 在容器里跑其他发行版（配合 podman）
        distrobox

        # 现代 LXD 替代——系统容器 + 轻量 VM
        incus

        # QEMU 虚拟化（virt-manager 需要）
        qemu

        # microVM（AWS Firecracker）
        firecracker
      ]
      ++ lib.optional (pkgs.system == winboatSystem) winboatWithVmx;
  };
}
