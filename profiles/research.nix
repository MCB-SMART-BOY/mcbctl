# Profile: 学术写作 — 文献管理 / 排版 / PDF 工具 / 笔记 / 办公套件
{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.mcb.profiles.research = lib.mkEnableOption "学术写作与办公（Zotero/TeX/Typst/Obsidian/LibreOffice）";

  config = lib.mkIf config.mcb.profiles.research {
    home.packages = with pkgs; [
      # ── 文献与阅读 ──
      sioyek # 学术 PDF 阅读器
      zotero # 文献管理

      # ── 排版引擎 ──
      pandoc # 文档格式转换
      typst # 新一代排版引擎
      texstudio # LaTeX IDE
      (texlive.withPackages (ps: [ ps.scheme-medium ])) # TeX Live 中型套装
      biber # BibLaTeX 参考文献工具

      # ── PDF 工具 ──
      qpdf # PDF 结构处理
      poppler-utils # PDF 命令行工具（pdftotext 等）

      # ── 笔记与办公 ──
      obsidian # Markdown 知识库
      libreoffice-still # 办公套件（稳定分支）
      xournalpp # 手写笔记/PDF 标注
      goldendict-ng # 词典工具
    ];
  };
}
