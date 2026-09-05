# Profile: 开发 — 工具链管理器 / 语言运行时 / 构建工具 / 编辑器 / Nix 辅助
{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.mcb.profiles.dev = lib.mkEnableOption "开发工具链（rustup/go/bun/opam/elan/cmake/gcc/编辑器/Nix LSP）";

  config = lib.mkIf config.mcb.profiles.dev {
    home.packages = with pkgs; [
      # ── 工具链管理器 ──
      rustup # Rust 工具链管理
      opam # OCaml 包管理
      elan # Lean 工具链管理
      go # Go 工具链入口
      bun # JavaScript/TypeScript runtime 与全局工具管理
      uv # Python 包与虚拟环境工具
      conda # Python/数据科学环境管理

      # ── C/C++ 构建 ──
      gnumake # make 构建
      cmake # C/C++ 构建系统
      pkg-config # 库探测
      openssl # TLS 库与工具
      gcc # GNU C/C++ 编译器
      binutils # 链接器/二进制工具
      clang-tools # C/C++ 工具链（clangd/clang-format）
      bear # 生成 compile_commands.json（Makefile 项目）
      mold # macOS 速度的链接器（跨 C/Rust/C++）
      sccache # 编译缓存（支持 S3/Redis 后端）
      ccache # 本地编译缓存（配合 CMake/Makefile 项目）

      # ── 编辑器 / IDE ──
      vscode-fhs # VS Code（FHS 兼容封装）
      zed-editor-fhs # Zed 编辑器

      # ── 编辑器通用工具（其余语言工具交给 rustup/opam/uv/bun/go）──
      lua-language-server # Lua LSP
      marksman # Markdown LSP
      nixd # Nix LSP
      nixfmt # Nix 格式化
      shellcheck # Shell 静态检查
      statix # Nix 静态检查
    ];
  };
}
