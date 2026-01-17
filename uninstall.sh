#!/bin/bash

# Exit if not run as root
if [ "$EUID" -ne 0 ]; then
  echo "Error: This script must be run with sudo." >&2
  exit 1

fi

THEME_NAME="noctalia"
THEME_DIR="/usr/share/sddm/themes/$THEME_NAME"
SDDM_CONF="/etc/sddm.conf"

uninstall_theme() {
  # Exit if theme already uninstalled
  if [[ ! -d "$THEME_DIR" ]]; then
    echo "Error: Theme is already uninstalled!" >&2
    exit 1
  fi

  rm -r $THEME_DIR
  echo "Noctalia theme removed!"
  deactivate_theme
}

deactivate_theme() {
  mv "$SDDM_CONF.bak" $SDDM_CONF
  echo "Noctalia theme deactivated!"
  remove_shell_integration
}

remove_shell_integration() {
  USER_TEMPLATE="/home/$SUDO_USER/.config/noctalia/user-templates.toml"

  awk '
  BEGIN { skip=0 }

  /^# SDDM GREETER$/ {
    skip=1
    next
  }
  /^output_path = / {
    if (skip) {
        skip=0
        next
    }
  }
  !skip
' $USER_TEMPLATE >"$USER_TEMPLATE.tmp" && mv "$USER_TEMPLATE.tmp" $USER_TEMPLATE

  # change ownership of user-templates.toml back to user
  chown $SUDO_USER $USER_TEMPLATE
  echo "Noctalia Shell integration removed!"
}

uninstall_theme
echo "All done!"
