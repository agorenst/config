#!/bin/zsh

# TODO: Take arguments, validate complete paths
# TODO: Check existence of directories already

function setup_configs() {
  echo "Setting up configs"
  #ln -s /home/aaron/repos/config/nvim /home/aaron/.config/nvim
  #ln -s /home/aaron/repos/config/tmux /home/aaron/.config/tmux
  # ln -s /home/aaron/repos/config/zshrc.personal /home/aaron/.config/zshrc.personal
}

setup_configs

function setup_shells() {
  # download oh-my-zsh
  sudo apt install zsh
  sudo chsh $(which zsh)
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  # First things first: make sure we start in tmux from now on
  # Set up my local thing
  echo "
# Import my local helpers
source ~/zshrc.personal
" >> $HOME/.zshrc
}

#setup_shells
