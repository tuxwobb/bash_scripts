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

APPS="vim mc tmux fastfetch git wget curl fzf btop lazygit bat lsd ripgrep npm tree-sitter-cli"
YAZI_DEP="ffmpeg 7zip jq poppler-utils fd-find ripgrep fzf zoxide imagemagick xclip"

YAZI_URL="https://github.com/sxyazi/yazi/releases/download/v26.1.22/yazi-aarch64-unknown-linux-gnu.deb"
# YAZI_URL="https://github.com/sxyazi/yazi/releases/download/v26.1.22/yazi-x86_64-unknown-linux-gnu.deb"
LAZYVIM_URL="https://github.com/LazyVim/starter"
VIMPLUG_URL="https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
TPM_URL="https://github.com/tmux-plugins/tpm"

usage() {
  echo "Usage: $0 [-v]"
  echo "  Script to install development environment on Debian"
  echo "    -h  man page"
  echo "    -v  verbose output of installation commands"
  echo "    -y  install yazi"
  echo "    -l  install lazyvim"
  echo "    -p  install vim vim-plug"
  echo "    -t  install tmux tpm"
  echo "    -a  install all tools"
  exit 1
}
# Help message functions
message_install() {
  if [[ $VERBOSE == 'true' ]]; then
    echo ">>> Installing ${*}..."
  fi
}

message_install_successful() {
  if [[ $VERBOSE == 'true' ]]; then
    echo -e ">>> ${*} installed successfully.\n"
  fi
}

message_install_failed() {
  if [[ $VERBOSE == 'true' ]]; then
    echo -e ">>> ${*} installation failed, read the instructions above!\n"
  fi
}

message_download() {
  if [[ $VERBOSE == 'true' ]]; then
    echo ">>> Downloading from ${*}..."
  fi
}

message_download_successful() {
  if [[ $VERBOSE == 'true' ]]; then
    echo -e ">>> Download from ${*} was successful.\n"
  fi
}

message_download_failed() {
  if [[ $VERBOSE == 'true' ]]; then
    echo -e ">>> Download from ${*} failed.\n"
  fi
}

message_change_owner() {
  if [[ $VERBOSE == 'true' ]]; then
    echo ">>> Changing owner of directory ${*} to ${USER}:${GROUP}..."
  fi
}

message_change_owner_successful() {
  if [[ $VERBOSE == 'true' ]]; then
    echo -e ">>> Changing owner of directory ${*} to ${USER}:${GROUP} was successful."
  fi
}

message_change_owner_failed() {
  if [[ $VERBOSE == 'true' ]]; then
    echo -e ">>> Chaning owner of directory ${*} to ${USER}:${GROUP} was unsuccessful!"
  fi
}

# Test if the script is running under root account
test_root() {
  if [[ $UID -ne 0 ]]; then
    echo "You must run this script with root privileges!"
    exit 1
  fi
}

# Basic applications installation function
basic_install() {
  message_install "Basic applications" "${APPS}"
  if ! sudo apt-get install -yq "${APPS}" &>/dev/null; then
    message_install_failed "Basic applications"
    exit 1
  fi
  message_install_successful "Basic applications"
}

# Yazi - Install dependencies
yazi_install_dependencies() {
  message_install "yazi dependencies" "${YAZI_DEP}"
  if ! sudo apt-get install -yq "${YAZI_DEP}" &>/dev/null; then
    message_install_failed "yazi dependencies"
    exit 1
  fi
  message_install_successful "yazi dependencies"
}

# Yazi - Create toolbox directory
yazi_create_toolbox_dir() {
  echo ">>> Creating $TOOLBOX_DIR directory..."
  if ! mkdir -p $TOOLBOX_DIR &>/dev/null; then
    echo ">>> Error while creating directory ${TOOLBOX_DIR}."
    exit 1
  fi
  echo -e ">>> Directory $TOOLBOX_DIR created succesfully.\n"
}

# Yazi - Change owner of toolbox directory
yazi_change_owner_toolbox_dir() {
  message_change_owner ${TOOLBOX_DIR}
  if ! chown -R ${USER}:${GROUP} $TOOLBOX_DIR &>/dev/null; then
    message_change_owner_failed ${TOOLBOX_DIR}
  fi
  message_change_owner_successful ${TOOLBOX_DIR}
}

# Yazi - Installation
yazi_install_application() {
  message_download ${YAZI_URL}
  if ! wget -P ${TOOLBOX_DIR} ${YAZI_URL} &>/dev/null; then
    message_download_failed ${YAZI_URL}
    exit 1
  fi
  message_download_successful ${YAZI_URL}
  message_install "yazi"
  if ! dpkg -i ${TOOLBOX_DIR}/yazi* &>/dev/null; then
    message_install_failed "yazi"
    exit 1
  fi
  message_install_successful "yazi"
}

# Yazi - remove installation file from toolbox directory
yazi_remove_installation_file() {
  echo ">>> Deleting of yazi installation file..."
  if ! rm ${TOOLBOX_DIR}/yazi* &>/dev/null; then
    echo ">>> Deleting of yazi installation file unsuccessful!"
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
  message_download ${TPM_URL}
  if ! git clone $TPM_URL ${HOME_DIR}/.tmux/plugins/tpm &>/dev/null; then
    message_download_failed ${TPM_URL}
    exit 1
  fi
  message_download_successful ${TPM_URL}
  message_change_owner "${HOME_DIR}/.tmux"
  if ! chown -R ${USER}:${GROUP} ${HOME_DIR}/.tmux &>/dev/null; then
    message_change_owner_failed "${HOME_DIR}/.tmux"
  fi
  message_change_owner_successful "${HOME_DIR}/.tmux"
  message_install_successful "tpm"
}

# Vimplug installation function
vimplug_install() {
  message_install "vim-plug"
  message_download ${VIMPLUG_URL}
  if ! curl -fLo ${HOME_DIR}/.vim/autoload/plug.vim --create-dirs ${VIMPLUG_URL} &>/dev/null; then
    message_download_failed ${VIMPLUG_URL}
    exit 1
  fi
  message_download_successful ${VIMPLUG_URL}
  message_change_owner "${HOME_DIR}/.vim"
  if ! chown -R ${USER}:${GROUP} ${HOME_DIR}/.vim &>/dev/null; then
    message_change_owner_failed "${HOME_DIR}/.vim"
  fi
  message_change_owner_successful "${HOME_DIR}/.vim"
  message_install_successful "vim-plug"
}

# Lazyvim installation function
lazyvim_install() {
  message_install "LazyVim"
  message_download ${LAZYVIM_URL}
  if ! git clone ${LAZYVIM_URL} ${HOME_DIR}/.config/nvim &>/dev/null; then
    message_download_failed ${LAZYVIM_URL}
    exit 1
  fi
  message_download_successful ${LAZYVIM_URL}
  if ! chown -R ${USER}:${GROUP} ${HOME_DIR}/.config/nvim &>/dev/null; then
    message_change_owner_failed "${HOME_DIR}/.config/nvim"
  fi
  message_change_owner_successful "${HOME_DIR}/.config/nvim"
  if ! rm -rf ${HOME_DIR}/.config/nvim/.git &>/dev/null; then
    echo ">>> Deleting of ${HOME_DIR}/.config/nvim.git file was unsuccessful!"
  fi
  echo ">>> Deleting of ${HOME_DIR}/.config/nvim.git file was successful."
  message_install_successful "LazyVim"
}

# Main app
while getopts hvylpta OPTION; do
  case $OPTION in
  h)
    usage
    ;;
  v)
    VERBOSE='true'
    ;;
  y)
    INSTALL_YAZI='true'
    ;;
  l)
    INSTALL_LAZYGIT='true'
    ;;
  p)
    INSTALL_VIMPLUG='true'
    ;;
  t)
    INSTALL_TPM='true'
    ;;
  a)
    INSTALL_ALL='true'
    ;;
  *)
    usage
    ;;
  esac
done

# Main
test_root

basic_install

if [[ $INSTALL_ALL == 'true' ]]; then
  yazi_install
  tmux_tpm_install
  vimplug_install
  lazyvim_install
  exit 0
fi

if [[ $INSTALL_YAZI == 'true' ]]; then
  yazi_install
fi

if [[ $INSTALL_LAZYGIT == 'true' ]]; then
  tmux_tpm_install
fi

if [[ $INSTALL_VIMPLUG == 'true' ]]; then
  vimplug_install
fi

if [[ $INSTALL_TPM == 'true' ]]; then
  lazyvim_install
fi

exit 0
