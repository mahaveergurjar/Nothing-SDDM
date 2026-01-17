#!/bin/bash

# Exit if not run as root
if [ "$EUID" -ne 0 ]; then
  echo "Error: This script must be run with sudo." >&2
  exit 1
fi

# Exit if sddm-greeter not installed
if ! command -v sddm-greeter >/dev/null 2>&1; then
  echo "Error: sdd-greeter is not installed." >&2
  return 1 # exit the function with error
fi

SWD="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

THEME_NAME="noctalia"
ASSET_DIR="$SWD/Assets"
SDDM_DIR="/usr/share/sddm"
DEST_DIR="$SDDM_DIR/themes/$THEME_NAME"
SDDM_CONF="/etc/sddm.conf"

install_theme() {
  # Create theme dir
  mkdir -p $DEST_DIR

  #copy over SDDM theme files
  cp -r $ASSET_DIR $DEST_DIR
  cp "$SWD/Main.qml" $DEST_DIR
  cp "$SWD/metadata.desktop" $DEST_DIR
  cp "$SWD/theme.conf" $DEST_DIR
  cp "$SWD/theme.template.conf" $DEST_DIR
  # permission needed for noctalia updates
  # via user templates
  chmod 666 "$DEST_DIR/theme.conf"
  echo "SDDM theme installed!"
  activate_theme
}

#--------------------------------------------
# UPDATE [Theme] sddm.conf
#--------------------------------------------
activate_theme() {
  if [ ! -f "$SDDM_CONF" ]; then
    echo "Error: $SDDM_CONF not found"
    exit 1
  fi

  # Create a backup of the config
  cp $SDDM_CONF "$SDDM_CONF.bak"

  # Modify [Theme.Current] field
  awk -v new_value="$THEME_NAME" '
  BEGIN {
    in_theme = 0
    current_found = 0
  }

  /^\[.*\]/ {
    if (in_theme && !current_found) {
        print "Current=" new_value
    }
    in_theme = ($0 == "[Theme]")
    print
    next
  }

  in_theme && /^[[:space:]]*Current[[:space:]]*=/ {
    print "Current=" new_value
    current_found = 1
    next
  }

  {
    print
  }

  END {
    if (in_theme && !current_found) {
        print "Current=" new_value
    }
  }
' "$SDDM_CONF" >"$SDDM_CONF.tmp" && mv "$SDDM_CONF.tmp" "$SDDM_CONF"

  echo "SDDM theme activated!"
  read -p "Do you want to install Noctalia integration via user templates? [y/N]" answer
  answer=${answer,,}

  if [[ "$answer" == "y" ]]; then
    add_user_template
  fi
}

#--------------------------------------------
# ADD [template.sddm] to user-templates.toml
#--------------------------------------------
add_user_template() {
  USER_TEMPLATE="/home/$SUDO_USER/.config/noctalia/user-templates.toml"

  awk -v dest="$DEST_DIR" '
  /^\[templates\.sddm\]/ { found=1 }
    { print }
    END {
      if (!found) {
        print "# SDDM GREETER"
        print "[templates.sddm]"
        print "input_path = \"" dest "/theme.template.conf\""
        print "output_path = \"" dest "/theme.conf\""
      }
    }
  ' "$USER_TEMPLATE" >"$USER_TEMPLATE.tmp" && mv "$USER_TEMPLATE.tmp" "$USER_TEMPLATE"

  # change owner of user-templates.toml back to user
  chown $SUDO_USER $USER_TEMPLATE
  echo "Updated: $USER_TEMPLATE"
}

install_theme
