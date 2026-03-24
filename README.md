# Bash scripts

Set of bash scripts for my daily use

## tmux.sh

Bash script to create tmux sessions from command line

Example:

    ./tmux.sh -f sessions.txt test test2 -a

## backup.sh

Bash script to create backup of selected files/folders into selected folder

    ./backup.sh -d /tmp *.sh

## add_users.sh

Bash script to create new users

    ./add_users user

## disable_local_user.sh

Bash script to disable users

    ./disable-local-user.sh

## toolbox_debian.sh

Bash script to prepare development environment on Debian

Installed applications:

    vim mc tmux fastfetch git wget curl fzf btop lazygit bat lsd ripgrep tldr ffmpeg 7zip jq poppler-utils fd-find ripgrep fzf zoxide imagemagick xclip

    neovim

    yazi

Installed plugins:

    LazyVim 
    
    vim-plug 
   
    tmux-tpm

Example:

    ./toolbox_debian.sh


