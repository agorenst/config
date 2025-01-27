if status is-interactive
  # Commands to run in interactive sessions can go here
end

# Automatically start up tmux if we're not already in it.
if not set -q TMUX
  tmux attach-session -t default || tmux new-session -s default
end


bind \cj 'commandline -f history-search-forward'
bind \ck 'commandline -f history-search-backward'
bind \ch 'commandline -f backward-char'
bind \cl 'commandline -f forward-char'

# From https://gist.github.com/josh-padnick/c90183be3d0e1feb89afd7573505cab3
function _initialize_ssh
  if not pgrep --full ssh-agent | string collect > /dev/null
    eval (ssh-agent -c)
    set -Ux SSH_AGENT_PID $SSH_AGENT_PID
    set -Ux SSH_AUTH_SOCK $SSH_AUTH_SOCK
  end
end

# function to_windows
#   cp $argv[1] $WINDESKTOP
# end

# Handy function
function add_to_path
  set -l path_element $argv[1]
  if not contains -- $path_element $PATH
    set -gx PATH $path_element $PATH
  end
end

# Needed for efm-langserver for my neovim setup
add_to_path "/home/aaron/go/bin"
# fnm, used to install node, used for some nvim plugins :/ (mainly tree-sitter...)
add_to_path "/home/aaron/.local/share/fnm"

# Add fnm environment to source.
fnm env | source

function resrc
  source ~/.config/fish/config.fish
end

function nvim_in_dir
  # Check if the directory exists
  if test -d $argv[1]
    # Push the directory and open nvim
    pushd $argv[1]
    nvim
    # Return to the previous directory
    popd
  else
    echo "Directory $argv[1] does not exist"
  end
end

function evc
  nvim_in_dir ~/.config/nvim
end

function efc
  nvim_in_dir ~/.config/fish
  resrc
end

function etw
  nvim_in_dir ~/.config/task
  resrc
end

# Move To Config
function mtc
  pushd ~/config
end

function etx
  nvim_in_dir ~/.config/tmux
  if test $status = 0
    tmux source-file ~/.config/tmux/tmux.conf
    echo "tmux config reloaded."
  else
    echo "Failed to edit tmux config."
  end
end


#################################################################################
#################################################################################
#################################################################################

#set -e fish_greeting
set fish_greeting ""

function git_branch
  if git rev-parse --is-inside-work-tree > /dev/null 2>&1
  end
  set -l branch (git symbolic-ref --short HEAD 2> /dev/null)
  # If we're in a 'detached HEAD' state, show the commit hash instead of branch name
  if not test -n "$branch"
    set branch (git rev-parse --short HEAD 2> /dev/null)
  end
  # Print the branch name or commit hash
  echo -n " ["$branch"]"
end

function fish_prompt
  # Define TokyoNight colors using hexadecimal
  set -l path_color (set_color '#7dcfff') # teal
  set -l git_color (set_color green)
  set -l time_color (set_color blue)
  set -l reset_color (set_color normal)


  #set -l timestamp (date "+%H:%M:%S") # military time
  set -l timestamp (date "+%I:%M:%S %p")
  echo -n $time_color"["$timestamp"] "
  echo -n $path_color(prompt_pwd)

  # For some reason concatenating 
  set -l git_info (git_branch)
  echo -n $git_color$git_info $reset_color"> "
end

function fish_preexec --on-event fish_preexec
    set -g aaron_command_executed true
end

function fish_right_prompt
  set -l date_color (set_color purple)
  set -l runtime_color (set_color green)
  set -l reset_color (set_color normal)
  if set -q aaron_command_executed
    echo -n $runtime_color
    printf "%.1fs " (math "$CMD_DURATION / 1000")
    # echo -n (math "$CMD_DURATION/1000")s ""
    # echo -n $date_color(date '+%Y-%m-%d      ')$reset_color
    set -e aaron_command_executed
  end
end

#################################################################################

# Created by `pipx` on 2024-11-03 20:20:26
set PATH $PATH /home/aaron/.local/bin
