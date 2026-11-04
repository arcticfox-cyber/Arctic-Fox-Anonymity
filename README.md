 <div align="center">

# 🦊 ARCTIC FOX ANONYMITY

**Transparent Tor Routing Toolkit for Kali Linux**

`v1.0.3` · Bash · Tor · iptables

</div>

---

## 🚀 About

Arctic Fox Anonymity is a Bash-based privacy toolkit for Kali Linux and Debian-based systems. It configures transparent Tor routing using firewall rules, redirects TCP and DNS traffic through Tor, and provides commands to start, stop, check, and manage routing.

## ✨ Features

| Feature | Description |
|---|---|
| 🌐 Transparent Routing | Redirects configured TCP traffic through Tor |
| 🔎 DNS Protection | Routes DNS requests through Tor |
| 🛡️ Firewall Management | Uses dedicated iptables chains |
| 🚫 UDP Protection | Blocks unsupported UDP traffic while routing |
| 🔒 IPv6 Protection | Blocks IPv6 output while routing |
| 🔄 Identity Change | Requests a new Tor circuit |
| 💾 Backup & Restore | Saves firewall and DNS backups |
| 🎛️ Interactive Menu | CLI commands and interactive menu |
| 🧹 Easy Uninstall | Includes an uninstall script |

## 📋 Requirements

- Kali Linux or a compatible Debian-based distribution
- Root or sudo privileges
- Internet connection
- Git (for cloning the repository)

## 📥 Installation

### Method 1 — Install using Git (Recommended)

```bash
# Update packages
sudo apt update

# Install Git
sudo apt install git -y

# Clone the repository
git clone https://github.com/arcticfox-cyber/Arctic-Fox-Anonymity.git

# Enter the actual project directory (the source is in a nested folder)
cd Arctic-Fox-Anonymity/Arctic-Fox-Anonymity

# Run the installer
sudo bash install.sh
```

The installer installs the required dependencies, including Tor, curl and iptables, and installs the `arcticfox` command system-wide.

### Method 2 — Install using ZIP

1. Open the repository:
   https://github.com/arcticfox-cyber/Arctic-Fox-Anonymity
2. Click **Code → Download ZIP**.
3. Extract the downloaded ZIP.
4. Open a terminal in the extracted folder.

```bash
cd ~/Downloads/Arctic-Fox-Anonymity/Arctic-Fox-Anonymity

# Install
sudo bash install.sh
```

*If the extracted folder is somewhere else, use its actual path in the `cd` command.*

### Method 3 — Single-File Installer

If you have downloaded `arcticfox_installer.sh`, run:

```bash
# Go to the directory containing the installer
cd ~/Downloads

# Run the self-extracting installer
sudo bash arcticfox_installer.sh
```

This installer extracts the project files and attempts to run the system-wide installation automatically.

## 🎯 Usage

After installation, the `arcticfox` command is available from your terminal.

### Quick Start

```bash
# Start Tor routing
sudo arcticfox start

# Check routing status
arcticfox status

# Request a new Tor circuit
sudo arcticfox changeip

# Stop Tor routing and restore settings
sudo arcticfox stop
```

### Available Commands

| Command | Description |
|---|---|
| `sudo arcticfox start` | Start Tor routing |
| `sudo arcticfox stop` | Stop routing and restore settings |
| `sudo arcticfox restart` | Restart routing |
| `arcticfox status` | Check Tor and routing status |
| `sudo arcticfox changeip` | Request a new Tor circuit |
| `arcticfox ip` | Display current public IP information |
| `sudo arcticfox menu` | Open interactive menu |
| `arcticfox banner` | Display the project banner |
| `arcticfox version` | Display installed version |
| `sudo arcticfox -y start` | Start without confirmation prompts |

### Interactive Menu

```bash
sudo arcticfox menu
```

Or simply:

```bash
arcticfox
```

### Verify Tor Connection

```bash
arcticfox status
```

You can also check your public IP:

```bash
arcticfox ip
```

## 🔧 Troubleshooting

### Command not found

```bash
hash -r
arcticfox version
```

If necessary, open a new terminal.

### Command conflict / Wrong Arctic Fox tool

If another program named `arcticfox` is running instead:

```bash
cd Arctic-Fox-Anonymity/Arctic-Fox-Anonymity
sudo bash fix_arcticfox.sh
```

### Check Tor service

```bash
sudo systemctl status tor
```

Restart Tor:

```bash
sudo systemctl restart tor
```

### Check firewall rules

```bash
sudo iptables -L -n -v
```

### Check Tor logs

```bash
sudo journalctl -u tor --no-pager -n 50
```

## 🔄 Update

To download the latest repository version:

```bash
cd Arctic-Fox-Anonymity
git pull origin main
cd Arctic-Fox-Anonymity
sudo bash install.sh
```

## 🗑️ Uninstallation

Run the following command from the actual project directory (`Arctic-Fox-Anonymity/Arctic-Fox-Anonymity`):

```bash
sudo bash uninstall.sh
```

The uninstaller stops active routing, removes the Arctic Fox command and cleans up its configuration and backup directory.

To remove Tor separately if you no longer need it:

```bash
sudo apt purge tor
```

## ⚠️ Important Security Notice

- Tor does not guarantee complete anonymity.
- Only traffic covered by the configured firewall rules is routed through Tor.
- UDP, ICMP and IPv6 restrictions may affect some applications.
- Use HTTPS to protect data between your device and destination websites.
- Always test your network configuration before relying on it for privacy.
- Use this project only for legal and authorized security research.

## 📁 Project Structure

```text
Arctic-Fox-Anonymity/                 # repository root
└── Arctic-Fox-Anonymity/              # actual installable project
    ├── arcticfox
    ├── install.sh
    ├── uninstall.sh
    ├── fix_arcticfox.sh
    ├── README.md
    ├── logo.png
    ├── LICENSE
    ├── checksums.txt
    └── completions/
        └── arcticfox
```

## 🤝 Contributing

Contributions, bug reports, feature requests and improvements are welcome.

1. Fork this repository.
2. Create a feature branch.
3. Commit your changes.
4. Open a Pull Request.

## ⭐ Support

If you find Arctic Fox Anonymity useful, please give this repository a star!

**GitHub:** https://github.com/arcticfox-cyber

**Repository:** https://github.com/arcticfox-cyber/Arctic-Fox-Anonymity

## 📜 License

This project is licensed under the MIT License. See [LICENSE](LICENSE).

---

<div align="center">

**🦊 ARCTIC FOX ANONYMITY**

*Privacy · Security · Ethical Hacking*

**Stay Private. Stay Secure. Stay Ethical.**

</div>
