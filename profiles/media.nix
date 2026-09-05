# Profile: 媒体 — MPV/音乐（mpd/ncmpcpp/ncspot/playerctl）/内容创作
{
  config,
  lib,
  pkgs,
  ...
}:
let
  secureUosc = pkgs.mpvScripts.uosc.overrideAttrs (oldAttrs: {
    postPatch = (oldAttrs.postPatch or "") + ''
      set -eu
      fail() {
        echo "secureUosc: $*" >&2
        exit 1
      }

      main=src/uosc/main.lua
      menus=src/uosc/lib/menus.lua
      updater=src/uosc/elements/Updater.lua

      test -f "$main" || fail "missing $main"
      test -f "$menus" || fail "missing $menus"
      test -f "$updater" || fail "missing $updater"

      require_marker() {
        grep -Fq -- "$1" "$2" || fail "missing marker '$1' in $2"
      }

      require_marker "open_subtitles_api_key" "$main"
      require_marker "open_subtitles_agent" "$main"
      require_marker "Update uosc" "$main"
      require_marker "bind_command('update', function()" "$main"
      require_marker "bind_command('download-subtitles', open_subtitle_downloader)" "$main"
      require_marker "download_command = 'script-binding uosc/download-subtitles'" "$main"
      require_marker "function open_subtitle_downloader()" "$menus"

      test "$(awk '/^function open_subtitle_downloader\(\)$/ { print NR; exit }' "$menus")" = 887 \
        || fail "unexpected subtitle downloader line"
      test "$(wc -l < "$menus")" = 1138 \
        || fail "unexpected menus.lua length"

      sed -i \
        -e "/open_subtitles_api_key =/d" \
        -e "/open_subtitles_agent =/d" \
        -e "/title = t('Update uosc')/d" \
        -e "/bind_command('update', function()/,+2d" \
        -e "/bind_command('download-subtitles'/d" \
        -e "/download_command = 'script-binding uosc\\/download-subtitles'/d" \
        "$main"
      sed -i '/^function open_subtitle_downloader()/,$d' "$menus"
      rm -- "$updater"

      assert_absent() {
        if grep -Fq -- "$1" "$2"; then
          fail "forbidden marker '$1' remains in $2"
        fi
      }

      for marker in \
        "Update uosc" \
        "uosc/update" \
        "download-subtitles" \
        "open_subtitles_api_key" \
        "open_subtitles_agent" \
        "open_subtitle_downloader" \
        "elements/Updater"; do
        assert_absent "$marker" "$main"
        assert_absent "$marker" "$menus"
      done
      tree_absent() {
        if grep -R -Fq -- "$1" src/uosc; then
          fail "forbidden tree marker '$1' remains"
        fi
      }

      for marker in \
        "raw.githubusercontent.com" \
        "api.github.com/repos/tomasklaen/uosc" \
        "api.opensubtitles.com" \
        "curl -fsSL" \
        "irm " \
        "download-subtitles" \
        "search-subtitles" \
        "open_subtitles" \
        "Updater.lua" \
        "elements/Updater"; do
        tree_absent "$marker"
      done
      if grep -R -E -q -- "['\"]https?://" src/uosc; then
        fail "runtime URL literal remains in src/uosc"
      fi
      test ! -e "$updater" || fail "$updater still exists"
    '';
  });
in
{
  options.mcb.profiles.media = lib.mkEnableOption "媒体（MPV、音乐守护/内容创作/录屏）";

  config = lib.mkIf config.mcb.profiles.media {
    home.packages = with pkgs; [
      # ── 音乐 ──
      mpd # 音乐守护进程
      ncmpcpp # MPD TUI 客户端
      ncspot # Spotify TUI 客户端（需要 C 依赖，cargo install 在 NixOS 上不可行）
      playerctl # 媒体键控制

      # ── 内容创作 ──
      obs-studio # 录屏与直播
    ];
    # MPV 由 Home Manager 模块包装脚本，避免裸 mpv 与增强包重复安装。
    programs.mpv = {
      enable = true;
      scripts = with pkgs.mpvScripts; [
        secureUosc # 现代界面；禁用自更新与 OpenSubtitles 下载入口
        thumbfast # 时间轴缩略图预览
        autoload # 自动加载同目录媒体
        mpris # 桌面媒体控制集成
      ];
      scriptOpts = {
        thumbfast = {
          max_width = 320;
          max_height = 180;
          tone_mapping = "auto";
        };
        autoload = {
          images = false;
          same_type = true;
          ignore_hidden = true;
        };
      };
    };
  };
}
