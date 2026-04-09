# Bash scripts

Set of bash scripts for my daily use

## tmux.sh

Bash script to create set of tmux sessions from command line

Example:

    ./tmux.sh [-h] [-vad] [-f FILE] [SESSION]...

## backup.sh

Bash script to create backup of selected files/folders into selected folder

    ./backup.sh [-d DESTINATION] FILE|DIRECTORY [FILE|DIRECTORY]...

## add_local_users.sh

Bash script to create new users on local machine

    ./add_local_users user [-h] [-p FILE] [-P LENGTH] [-svl] USERNAME [USERNAME]...

## disable_local_users.sh

Bash script to disable users on local machine

    ./disable_local_user.sh [-h] [-drav] USERNAME [USERNAME]...

## toolbox_debian.sh

Bash script to prepare easily development environment on Debian

Basic applications:

    vim mc tmux fastfetch git wget curl fzf btop lazygit bat lsd ripgrep 

Yazi dependencies:

    ffmpeg 7zip jq poppler-utils fd-find ripgrep fzf zoxide imagemagick xclip

Other applications:

    neovim yazi

Installed plugins:

    LazyVim 
    
    vim-plug 
   
    tmux-tpm

Example:

    ./toolbox_debian.sh [-h] [-v] [-bylpt] [-a]

## run-everywhere.sh

Bash script to run command on multiple servers

    ./run-everywhere.sh [-f FILE] [-dvs] COMMAND 

