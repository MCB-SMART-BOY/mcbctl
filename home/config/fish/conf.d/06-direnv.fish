# ══════════════════════════════════════════════════════════════════
# Direnv — 目录级环境变量自动加载
# ══════════════════════════════════════════════════════════════════
# 来源: ~/.config/fish/conf.d/06-direnv.fish
if not status is-interactive
    return
end


if type -q direnv
    direnv hook fish | source
end
