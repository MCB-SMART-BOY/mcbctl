# Profile: AI 工具链 — ollama, llama-cpp, open-webui（aider-chat 已迁至 uv tool install）
{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.mcb.profiles.ai-tools = lib.mkEnableOption "AI 工具链（ollama/llama-cpp/open-webui）";

  config = lib.mkIf config.mcb.profiles.ai-tools {
    home.packages = with pkgs; [
      # 本地 LLM 运行时
      ollama
      llama-cpp

      # ChatGPT 风格 Web 前端（连接 ollama）
      open-webui
    ];

    # ⚠ aider-chat → uv tool install（运行 bootstrap-toolchain）
  };
}
