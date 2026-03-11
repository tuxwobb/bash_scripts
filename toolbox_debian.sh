#!/bin/bash

# Basic applications
# vim mc tmux fastfetch git wget curl fzf btop lazygit bat lsd ripgrep tldr

# yazi dependencies
# ffmpeg 7zip jq poppler-utils fd-find ripgrep fzf zoxide imagemagick xclip

# Setup parameters
USER="wobbler"
GROUP=${USER}

HOME_DIR="/home/${USER}"
TOOLBOX_DIR="${HOME_DIR}/Downloads/toolbox"

APPS="vim mc tmux fastfetch git wget curl fzf btop lazygit bat lsd ripgrep npm"
YAZI_DEP="ffmpeg 7zip jq poppler-utils fd-find ripgrep fzf zoxide imagemagick xclip"

# YAZI_URL="https://github.com/sxyazi/yazi/releases/download/v26.1.22/yazi-aarch64-unknown-linux-gnu.deb"
YAZI_URL="https://github.com/sxyazi/yazi/releases/download/v26.1.22/yazi-x86_64-unknown-linux-gnu.deb"
LAZYVIM_URL="https://github.com/LazyVim/starter"
VIMPLUG_URL="https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
TPM_URL="https://github.com/tmux-plugins/tpm"

# Help message functions
message_install() {
  echo ">>> Installing ${1}..."
}

message_install_successful() {
  echo -e ">>> ${1} installed successfully.\n"
}

message_install_failed() {
  echo -e ">>> ${1} installation failed, read the instructions above!\n"
}

message_download() {
  echo ">>> Downloading from ${1}..."
}

message_download_successful() {
  echo -e ">>> Download from ${1} was successful.\n"
}

message_download_failed() {
  echo -e ">>> Download from ${1} failed.\n"
}

# Test if the script is running under root account
test_uid() {
  if [[ $UID -ne 0 ]]; then
    echo "You must run this script with root privileges"
    exit 1
  fi
}

# Basic applications installation function
basic_install() {
  message_install "Basic applications"
  sudo apt-get install -yq ${APPS}
  if [[ ${?} -ne 0 ]]; then
    message_install_failed "Basic applications"
    exit 1
  else
    message_install_successful "Basic applications"
  fi
}

# Yazi - Install dependencies
yazi_install_dependencies() {
  message_install "yazi dependencies"
  sudo apt-get install -yq ${YAZI_DEP}
  if [[ ${?} -ne 0 ]]; then
    message_install_failed "yazi dependencies"
    exit 1
  else
    message_install_successful "yazi dependencies"
  fi
}

# Yazi - Create toolbox directory
yazi_create_toolbox_dir() {
  echo ">>> Creating $TOOLBOX_DIR directory..."
  mkdir -p $TOOLBOX_DIR
  if [[ ${?} -ne 0 ]]; then
    echo ">>> Error while creating directory ${TOOLBOX_DIR}."
    exit 1
  fi
  echo -e ">>> Directory $TOOLBOX_DIR created succesfully.\n"
}

# Yazi - Change owner of toolbox directory
yazi_change_owner_toolbox_dir() {
  echo ">>> Changing owner of $TOOLBOX_DIR to ${USER}:${GROUP}..."
  chown -R ${USER}:${GROUP} $TOOLBOX_DIR
  if [[ ${?} -ne 0 ]]; then
    echo ">>> Changing owner of $TOOLBOX_DIR was unsuccessful!"
    exit 1
  else
    echo ">>> Changing owner of $TOOLBOX_DIR was successful"
  fi
}

# Yazi - Installation
yazi_install_application() {
  message_install "yazi"
  message_download ${YAZI_URL}
  wget -P ${TOOLBOX_DIR} ${YAZI_URL}
  if [[ ${?} -ne 0 ]]; then
    message_download_failed ${YAZI_URL}
    exit 1
  fi
  message_download_successful ${YAZI_URL}
  
  dpkg -i ${TOOLBOX_DIR}/yazi*
  if [[ ${?} -ne 0 ]]; then
    message_install_failed "yazi"
    exit 1
  fi
  message_install_successful "yazi"
}

# Yazi - remove installation file from toolbox directory
yazi_remove_installation_file() {
  rm ${TOOLBOX_DIR}/yazi*
  if [[ ${1} -ne 0 ]]; then
    echo ">>> Deleting of yazi installation file unsuccessful!"
    exit 1
  fi 
  echo ">>> Deleting of yazi installation file was successful."
}

# Yazi installation function
yazi_install() {
  yazi_install_dependencies
  yazi_create_toolbox_dir
  yazi_change_owner_toolbox_dir
  yazi_install_application
  yazi_remove_installation_file
}

# Tmux TPM installation function
tmux_tpm_install() {
  message_install "tpm"
  git clone $TPM_URL ${HOME_DIR}/.tmux/plugins/tpm
  chown -R ${USER}:${GROUP} ${HOME_DIR}/.tmux
  message_install_successful "tpm"
}

# Vimplug installation function
vimplug_install() 
  message_install "vim-plug"
  curl -fLo ${HOME_DIR}/.vim/autoload/plug.vim --create-dirs ${VIMPLUG_URL}
  chown -R ${USER}:${GROUP} ${HOME_DIR}/.vim
  message_install_successful "vim-plug"
}

# Lazyvim installation function
lazyvim_install() {
  message_install "LazyVim"
  message_download ${LAZYVIM_URL}
  git clone ${LAZYVIM_URL} ${HOME_DIR}/.config/nvim
  if [[ ${?} -ne 0 ]] 
  then
    message_download_failed ${LAZYVIM_URL}
    exit 1
  fi
  message_download_successful ${LAZYVIM_URL}
  
  chown -R ${USER}:${GROUP} ${HOME_DIR}/.config/nvim
  rm -rf ${HOME_DIR}/.config/nvim/.git
  message_install_successful "LazyVim"
}

# Main app
test_uid
basic_install
yazi_install
tmux_tpm_install
# vimplug_install
# lazyvim_install
