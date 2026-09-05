# ══════════════════════════════════════════════════════════════════
# Zoxide — 智能目录跳转
# ══════════════════════════════════════════════════════════════════
# 来源: ~/.config/fish/conf.d/07-zoxide.fish
if not status is-interactive
    return
end


if type -q zoxide
    zoxide init fish | source
    abbr --add j  z
    abbr --add ji zi
end
