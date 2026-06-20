if status is-interactive
    # Commands to run in interactive sessions can go here
end

fish_add_path ~/.npm-global/bin

function jk
    lua "$HOME/terminal_jk/core/jk.lua" $argv
end

function ai
    lua "$HOME/terminal_jk/ai/ai.lua" $argv
end

alias chrome-fix="rm -f ~/.config/google-chrome/Singleton*"
