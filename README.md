# Noctalia SDDM Theme

Noctalia SDDM is a cozy, elegant login theme for **SDDM (Simple Desktop Display Manager)**, designed to complement the **Noctalia Shell** experience. It mimics the warm, dark aesthetic of the Rose Pine color palette, featuring rounded corners, smooth scaling, and a clean, modern interface tailored for Hyprland and KDE users.

![Noctalia SDDM Preview](Assets/preview.png)

## Features

- **Rose Pine Aesthetic** – A soothing, high-contrast dark theme using the Rose Pine palette.
- **Responsive Scaling** – Automatically adapts to 1080p, 1440p, and 4K resolutions.
- **Smart Avatar Handling** – Automatically detects user profile pictures or gracefully falls back to defaults.
- **Session Management** – Built-in support for switching desktop sessions (Wayland/X11).
- **Integrated Power Controls** – Suspend, Reboot, and Shutdown accessible directly from the login screen.
- **Customizable Configuration** – easy tweaks via `theme.conf`.
- **Noctalia Shell integration** - synchronize theme colors with Nocatalia shell via user templates.

## Auto Installer

### 1. Clone repository

```sh
git clone -b noctalia https://github.com/mahaveergurjar/sddm.git noctalia && cd noctalia
```

### 2. Run install script

```sh
sudo ./install.sh
```

The install script will ask if you want the optional color sync integration with Noctalia Shell.

## Manual installation

### 1. Clone the repository

```sh
git clone -b noctalia https://github.com/mahaveergurjar/sddm.git noctalia
```

### 2. Install the theme

Move the theme folder to the SDDM themes directory:

```sh
sudo cp -r noctalia /usr/share/sddm/themes/
```

### 3. Configure SDDM

Edit your SDDM configuration file to use the new theme:

```sh
sudo nano /etc/sddm.conf
```

Add or modify the `[Theme]` section:

```ini
[Theme]
Current=noctalia
```

### 4. Restart SDDM

To apply the changes, restart the display manager:

```sh
sudo systemctl restart sddm
```

### 5. Noctalia Shell integration (optional)

Open `~/.config/noctalia/user-templates.toml` and add the following lines at the Suspend

```sh
# SDDM GREETER
[templates.sddm]
input_path = "/usr/share/sddm/themes/noctalia/theme.template.conf"
output_path = "/usr/share/sddm/themes/noctalia/theme.conf"
```

## Configuration

### 1. General

You can customize colors, background, and blur settings in :

- `theme.conf` - if you **are not** using Noctalia Shell integration
- `theme.template.conf` - if you **are** using Noctalia Shell integration

> [!IMPORTANT]
> If using the Noctalia Shell integration do not modify the color variables inside `theme.template.conf`

```ini
[General]
background=Assets/background.png
blurRadius=0
# Rose Pine Color Palette overrides...
```

### 2. Noctalia Shell integration

- Enable user templates inside Noctalia Shell
  `Control Center > Settings > Color Schemes > Templates > Advanced > Enable user teplates`

- Change your Color Scheme inside Noctalia settings at least once so that the theme gets synced.

## Preview

You can test the theme without logging out by running the test script

```sh
./test.sh
```

_Note: Ensure you have `qt5-graphicaleffects` and `qt5-quickcontrols2` (or their Qt6 equivalents) installed._

## Credits

- Designed for **Noctalia Shell**.
- Uses **Rose Pine** color palette.

---

**Contributions are welcome!** Feel free to fork and submit pull requests.
