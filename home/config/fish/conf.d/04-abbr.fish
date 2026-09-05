# ══════════════════════════════════════════════════════════════════
# 缩写（abbreviations）— Fish 推荐的 alias 替代方案
# ══════════════════════════════════════════════════════════════════
# 来源: ~/.config/fish/conf.d/04-abbr.fish
#
# abbr 输入时自动展开为完整命令，能看到完整命令后再执行。
# 用 abbr --erase <name> 可移除单个缩写。
if not status is-interactive
    return
end


# ── 📦 现代工具替换 ──
if type -q eza
    abbr --add ls   'eza --icons --group-directories-first --git'
    abbr --add ll   'eza -l --icons --group-directories-first --git --time-style=long-iso'
    abbr --add la   'eza -la --icons --group-directories-first --git'
    abbr --add lsz  'eza -al --color=always --total-size --group-directories-first --icons'
    abbr --add l.   'eza -ald --color=always --group-directories-first --icons .*'
    abbr --add tree 'eza --tree --icons'
end

if type -q bat
    abbr --add bcat 'bat --paging=never --style=plain'
    abbr --add catt 'bat --paging=always'
    abbr --add catb 'bat --style header,snip,changes' # Garuda 风格 cat 替代
end


abbr --add grep 'grep --color=auto'

type -q fd    && abbr --add fdf fd
type -q sd    && abbr --add ssed sd
type -q choose && abbr --add ccut choose
type -q difft  && abbr --add diffx difft
type -q tldr   && abbr --add helpme tldr
type -q xh     && abbr --add http xh
type -q glow   && abbr --add mdview 'glow -p'
type -q duf    && abbr --add df duf
type -q dust   && abbr --add du dust
type -q dua    && abbr --add dui 'dua interactive'
type -q procs  && abbr --add ps procs
type -q btop   && abbr --add top btop
type -q zed    && abbr --add ze zed
type -q dig    && abbr --add digg dig
type -q doggo  && abbr --add dns doggo
type -q gping  && abbr --add pingg gping

if type -q ouch
    abbr --add compress   'ouch compress'
    abbr --add decompress 'ouch decompress'
end

# ── 🛡️ 原生命令回退 ──
abbr --add oldls   'command ls'
abbr --add oldcat  'command cat'
abbr --add oldgrep 'command grep'
abbr --add olddf   'command df'
abbr --add olddu   'command du'
abbr --add oldps   'command ps'
abbr --add oldtop  'command top'

# ── 🌿 Git ──
abbr --add g   git
abbr --add ga  'git add'
abbr --add gc  'git commit'
abbr --add gp  'git push'
abbr --add gl  'git pull'
abbr --add gs  'git status'
abbr --add gd  'git diff'
abbr --add gco 'git checkout'
abbr --add gb  'git branch'
abbr --add gst 'git stash'
abbr --add gcp 'git cherry-pick'
abbr --add grb 'git rebase'
abbr --add glg 'git log --oneline --graph --decorate'
abbr --add lg  lazygit

# ── 🦀 Rust / Cargo ──
abbr --add c    cargo
abbr --add cb   'cargo build'
abbr --add cr   'cargo run'
abbr --add ct   'cargo test'
abbr --add cc   'cargo check'
abbr --add cw   'cargo watch -x check'
abbr --add cf   'cargo fmt'
abbr --add ccl  'cargo clippy'
abbr --add ca   'cargo add'
abbr --add cu   'cargo update'

# ── 📁 快捷导航 ──
abbr --add ..    'cd ..'
abbr --add ...   'cd ../..'
abbr --add ....  'cd ../../..'
abbr --add ..... 'cd ../../../..'
abbr --add -- -  'cd -'
abbr --add md 'mkdir -p'
abbr --add rd  rmdir

# ── 🛡️ 安全操作（交互确认） ──
abbr --add cp 'cp -iv'
abbr --add mv 'mv -iv'
abbr --add rm 'rm -iv'

# ── ✏️ 编辑器 ──
abbr --add e '$EDITOR'
abbr --add v '$EDITOR'

# ── 🌐 网络 ──
abbr --add ip    'ip -color=auto'
abbr --add myip  'curl -s https://ipinfo.io/ip'

# ── 📋 系统日志 ──
abbr --add jctl 'journalctl -p 3 -xb'
abbr --add ports 'ss -tulanp'

# ── 🧹 Nix 查询 ──
abbr --add nsp   'nix search nixpkgs'
abbr --add nsh   'nix-shell'
