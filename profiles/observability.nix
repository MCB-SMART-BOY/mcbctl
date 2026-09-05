# Profile: 系统可观测性 — eBPF, perf, valgrind, rr, flamegraph
{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.mcb.profiles.observability = lib.mkEnableOption "系统可观测性与性能剖析（eBPF/perf/valgrind/rr/flamegraph）";

  config = lib.mkIf config.mcb.profiles.observability {
    home.packages = with pkgs; [
      # ── eBPF 动态内核追踪 ──
      bpftrace
      bcc
      perf
      trace-cmd
      kernelshark

      # ── 内存/并发调试 ──
      valgrind
      rr # Mozilla 可逆调试器

      # ── 性能可视化 ──
      flamegraph # Brendan Gregg 火焰图脚本
      hotspot # perf GUI 分析

      # ── IO 分析 ──
      fio
      ioping

      # ── 系统调用 + 网络追踪 ──
      sysdig

      # ── 结构化日志查看 ──
      lnav
    ];
  };
}
