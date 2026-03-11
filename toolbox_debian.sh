#!/bin/bash

# Basic applications
# vim mc tmux fastfetch git wget curl fzf btop lazygit bat lsd ripgrep tldr

# yazi dependencies
# ffmpeg 7zip jq poppler-utils fd-find ripgrep fzf zoxide imagemagick xclip

# Setup
USER="wobbler"
GROUP=${USER}

HOME_DIR="/home/${USER}"
TOOLBOX_DIR="${HOME_DIR}/Downloads/toolbox"

YAZI_URL="https://github.com/sxyazi/yazi/releases/download/v26.1.22/yazi-aarch64-unknown-linux-gnu.deb"
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

# Test if the script is running under root account
if [[ $UID -ne 0 ]]; then
  echo "You must run this script with root privileges"
  exit 1
fi

# Basic applications installation
message_install "Basic applications"
sudo apt-get install -yq vim mc tmux fastfetch git wget curl fzf btop lazygit bat lsd ripgrep tldr
if [[ ${?} -ne 0 ]]; then
  message_install_failed "Basic applications"
  exit 1
else
  message_install_successful "Basic applications"
fi

# Yazi dependencies installation
message_install "yazi dependencies"
sudo apt-get install -yq ffmpeg 7zip jq poppler-utils fd-find ripgrep fzf zoxide imagemagick xclip
if [[ ${?} -ne 0 ]]; then
  message_install_failed "yazi dependencies"
  exit 1
else
  message_install_successful "yazi dependencies"
fi

# Toolbox directory
echo ">>> Creating $TOOLBOX_DIR directory..."
mkdir -p $TOOLBOX_DIR
if [[ ${?} -ne 0 ]]; then
  echo ">>> Error while creating directory ${TOOLBOX_DIR}."
  exit 1
fi
echo -e ">>> Directory $TOOLBOX_DIR created succesfully.\n"

# Yazi instllation
echo message_install "yazi"
echo ">>> Getting from ${YAZI_URL}..."
wget -P ${TOOLBOX_DIR} ${YAZI_URL}
if [[ ${?} -ne 0 ]]; then
  echo ">>> Error while getting from ${YAZI_URL}."
  exit 1
fi
echo ">>> downloaded successfully."
dpkg -i ${TOOLBOX_DIR}/yazi*
if [[ ${?} -ne 0 ]]; then
  message_install_failed "yazi"
  exit 1
fi
rm ${TOOLBOX_DIR}/yazi*
if [[ ${1} -ne 0 ]]
then
  echo ">>> Deleting of yazi file installation file unsuccessful!"
else
  echo ">>> Deleting of yazi file installation was successful."
message_install_successful "yazi"

# Tmux TPM installation
message_install "tpm"
git clone $TPM_URL ${HOME_DIR}/.tmux/plugins/tpm
chown -R ${USER}:${GROUP} ${HOME_DIR}/.tmux
message_install_successful "tpm"

# Vimplug installation
message_install "vim-plug"
curl -fLo ${HOME_DIR}/.vim/autoload/plug.vim --create-dirs ${VIMPLUG_URL}
chown -R ${USER}:${GROUP} ${HOME_DIR}/.vim
message_install_successful "vim-plug"

# Lazyvim installation
message_install "LazyVim"
git clone ${LAZYVIM_URL} ${HOME_DIR}/.config/nvim
chown -R ${USER}:${GROUP} ${HOME_DIR}/.config/nvim
rm -rf ${HOME_DIR}/.config/nvim/.git
message_install_successful "LazyVim"
