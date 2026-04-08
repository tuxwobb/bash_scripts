#!/bin/bash

# Basic applications
APPS=('vim' 'mc' 'tmux' 'fastfetch' 'git' 'wget' 'curl' 'fzf' 'btop' 'lazygit' 'bat' 'lsd' 'ripgrep')

# yazi dependencies
YAZI_DEP=('ffmpeg' '7zip' 'jq' 'poppler-utils' 'fd-find' 'ripgrep' 'fzf' 'zoxide' 'imagemagick' 'xclip')

# Setup parameters
USER='wobbler'
GROUP=${USER}

# Folders
HOME_DIR="/home/${USER}"
TOOLBOX_DIR="${HOME_DIR}/Downloads/toolbox"

# Urls
YAZI_URL='https://github.com/sxyazi/yazi/releases/download/v26.1.22/yazi-aarch64-unknown-linux-gnu.deb'
# YAZI_URL='https://github.com/sxyazi/yazi/releases/download/v26.1.22/yazi-x86_64-unknown-linux-gnu.deb'
LAZYVIM_URL='https://github.com/LazyVim/starter'
VIMPLUG_URL='https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
TPM_URL='https://github.com/tmux-plugins/tpm'

usage() {
  echo "Usage: $0 [-h] [-v] [-bylpt] [-a]"
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

# Log function
log() {
    echo ">>> ${*}"
}

# Test if the script is running under root account
test_root() {
  if [[ $UID -ne 0 ]]; then
    echo "You must run this script with root privileges!" >&2
    exit 1
  fi
}

# Basic applications installation function
basic_install() {
  log "Installing of basic applications: ${APPS[@]}"
  if ! sudo apt-get install -yq "${APPS[@]}" ; then
    log "Basic applications installation failed." >&2
    exit 1
  fi
  log "Basic applications installation successfull."
}

# Yazi installation
yazi_install() {

  log "Installing of Yazi dependencies: ${YAZI_DEP[@]}"
  if ! sudo apt-get install -yq "${YAZI_DEP[@]}" ; then
    log "Yazi dependencies installation failed." >&2
    exit 1
  fi
  log "Yazi dependencies installation successfull."

  log "Creating $TOOLBOX_DIR directory..."
  if ! mkdir -p $TOOLBOX_DIR &>/dev/null; then
    log "Error while creating directory ${TOOLBOX_DIR}." >&2
    exit 1
  fi
  log "Directory $TOOLBOX_DIR created succesfully."

  log "Change owner of directory ${TOOLBOX_DIR}"
  if ! chown -R ${USER}:${GROUP} $TOOLBOX_DIR &>/dev/null; then
    log "Change owner of directory ${TOOLBOX_DIR} failed." >&2
    exit 1
  fi
  log "Change owner of directory ${TOOLBOX_DIR} successfull."

  log "Downloading Yazi from ${YAZI_URL}"
  if ! wget -P ${TOOLBOX_DIR} ${YAZI_URL} &>/dev/null; then
    log "Download Yazi from ${YAZI_URL} failed." >&2
    exit 1
  fi
  log "Downloading Yazi from ${YAZI_URL} successfull."

  log "Installing Yazi package"
  if ! dpkg -i ${TOOLBOX_DIR}/yazi* &>/dev/null; then
    log "Installing Yazi package failed." >&2
    exit 1
  fi
  log "Installing Yazi package successfull."

  log "Deleting of Yazi installation file."
  if ! rm ${TOOLBOX_DIR}/yazi* &>/dev/null; then
    log "Deleting of Yazi installation file failed." >&2
    exit 1
  fi
  log "Deleting of Yazi installation file successfull."
}

# Tmux TPM installation function
tmux_tpm_install() {
  log "Downloading tpm from ${TPM_URL}"
  if ! git clone $TPM_URL ${HOME_DIR}/.tmux/plugins/tpm &>/dev/null; then
    log "Downloading tpm from ${TPM_URL} failed." >&2
    exit 1
  fi
  log "Downloading tpm from ${TPM_URL} successfull."

  log "Change owner of ${HOME_DIR}/.tmux directory."
  if ! chown -R ${USER}:${GROUP} ${HOME_DIR}/.tmux &>/dev/null; then
    log "Change owner of ${HOME_DIR}/.tmux failed" >&2
    exit 1
  fi
  log "Change owner of ${HOME_DIR}/.tmux directory successfull."
}

# Vimplug installation function
vimplug_install() {
  log "Downloading vimplug from ${VIMPLUG_URL}"
  if ! curl -fLo ${HOME_DIR}/.vim/autoload/plug.vim --create-dirs ${VIMPLUG_URL} &>/dev/null; then
    log "Downloading vimplug from ${VIMPLUG_URL} failed." >&2
    exit 1
  fi
  log "Downloading vimplug from ${VIMPLUG_URL} successfull."

  log "Change owner of ${HOME_DIR}/.vim directory."
  if ! chown -R ${USER}:${GROUP} ${HOME_DIR}/.vim &>/dev/null; then
    log "Change owner of ${HOME_DIR}/.vim directory failed." >&2
  fi
  log "Change owner of ${HOME_DIR}/.vim direcgory successfull."
}

# Lazyvim installation function
lazyvim_install() {
  log "Downloading of LazyVim from ${LAZYVIM_URL}"
  if ! git clone ${LAZYVIM_URL} ${HOME_DIR}/.config/nvim &>/dev/null; then
    log "Downloading of LazyVim from ${LAZYVIM_URL} failed." >&2
    exit 1
  fi
  log "Downloading of LazyVim from ${LAZYVIM_URL} successfull."

  log "Change owner of ${HOME_DIR}/.config/nvim directory."
  if ! chown -R ${USER}:${GROUP} ${HOME_DIR}/.config/nvim &>/dev/null; then
    log "Change owner of ${HOME_DIR}/.config/nvim direcgory failed." >&2
    exit 1
  fi
  log "Change owner of ${HOME_DIR}/.config/nvim directory successfull."

  log "Deleting of ${HOME_DIR}/.config/nvim/.git directory."
  if ! rm -rf ${HOME_DIR}/.config/nvim/.git &>/dev/null; then
    log "Deleting of ${HOME_DIR}/.config/nvim.git file failed." >&2
  fi
  echo ">>> Deleting of ${HOME_DIR}/.config/nvim.git file successful."
}

# Main app
while getopts hvbylpta OPTION; do
  case $OPTION in
  h)
    usage
    ;;
  v)
    VERBOSE='true'
    ;;
  b)
    INSTALL_BASIC='true'
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

if [[ $INSTALL_BASIC == 'true' ]]; then
  basic_install
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

if [[ $INSTALL_ALL == 'true' ]]; then
  basic_install
  yazi_install
  tmux_tpm_install
  vimplug_install
  lazyvim_install
fi

exit 0
