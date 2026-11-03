<div align="center">

<img src="logo.png" alt="Arctic Fox Anonymity" width="280"/>

# 🦊 Arctic Fox Anonymity

**Transparent Tor routing for Kali Linux — anonymize your ENTIRE operating system.**

![Version](https://img.shields.io/badge/version-1.0.3-00b3b3?style=for-the-badge&logo=tor&logoColor=white)
![Platform](https://img.shields.io/badge/platform-Kali%20%7C%20Debian-blue?style=for-the-badge&logo=linux&logoColor=white)
![Language](https://img.shields.io/badge/language-Bash-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white)
![License](https://img.shields.io/badge/license-MIT-green?style=for-the-badge)

*Inspired by AnonGT / anonsurf — rebuilt cleaner, safer and easier to install.*

**Author:** [@arcticfox-cyber](https://github.com/arcticfox-cyber)

</div>

---

## 📖 What is it?

**Arctic Fox Anonymity** redirects **all traffic of your Kali Linux system** — every TCP
connection **and every DNS query** — through the **Tor network**. Unlike browser VPN
extensions or `proxychains` (which only cover single apps), this tool anonymizes the whole
operating system at the firewall level. Open Firefox, run `nmap`, use `sqlmap`, chat, game
update checks — everything goes through Tor automatically.

## ✨ Features

| Feature | Description |
| --- | --- |
| 🌐 **Full transparent routing** | All TCP traffic redirected to Tor's `TransPort` (9040) via iptables — no proxy settings needed in apps |
| 🔎 **DNS through Tor** | All DNS (UDP + TCP 53) forced to Tor's `DNSPort` (5353) — no DNS leaks |
| 🚫 **UDP leak protection** | Non-DNS UDP (QUIC/HTTP3, WebRTC-style) is rejected — apps silently fall back to TCP |
| 🚫 **ICMP blocked** | Ping cannot be proxied through Tor, so it is blocked instead of leaking destinations |
| 🧊 **IPv6 lock** | IPv6 output is blocked while routing — no IPv6 leaks |
| 🛡️ **Non-destructive firewall** | Uses its own iptables chains (`AF_NAT`, `AF_FILT`, `AF_FILT6`) — your existing firewall rules are **not** wiped (unlike AnonGT) |
| 💾 **Auto backup & restore** | `resolv.conf` and firewall snapshots saved to `/var/lib/arcticfox` and restored on stop |
| 🔄 **Identity change** | `arcticfox changeip` requests a fresh Tor circuit (NEWNYM) |
| 🎛️ **Menu + CLI flags** | Interactive menu (like AnonGT) *and* proper `start/stop/status` commands |
| 📦 **Clean install/uninstall** | `install.sh` puts the tool in `/usr/local/bin` with bash completion; `uninstall.sh` removes everything |

## 🚀 Install (Kali Linux)

### Option 1 — git clone (recommended)

```bash
git clone https://github.com/arcticfox-cyber/Arctic-Fox-Anonymity.git
cd Arctic-Fox-Anonymity
sudo bash install.sh
```

That's it. The `arcticfox` command now works from **any terminal**, just like a native Kali tool.

### Option 2 — single-file installer (no git needed)

Download `arcticfox_installer.sh` from [Releases](https://github.com/arcticfox-cyber/Arctic-Fox-Anonymity/releases), then:

```bash
bash arcticfox_installer.sh
```

> Old unrelated `arcticfox` tool on your system? Run `sudo bash fix_arcticfox.sh` —
> it removes the conflict and verifies the install in one shot.

## 🎮 Usage

```bash
sudo arcticfox start     # route ALL traffic through Tor
sudo arcticfox status    # verify you are behind Tor
sudo arcticfox changeip  # get a new Tor identity / circuit
sudo arcticfox stop      # restore normal internet
sudo arcticfox menu      # interactive menu (also: just run 'arcticfox')
```

<details>
<summary><b>All commands</b></summary>

| Command | Action |
| --- | --- |
| `start` | Start anonymous routing (TCP + DNS → Tor) |
| `stop` | Stop routing, restore your original DNS and firewall |
| `restart` | Stop + start with a fresh Tor circuit |
| `status` | Tor service, routing, IPv6, DNS and IP status — **verifies every protection component independently** |
| `recover` | **Emergency repair** — force-restores DNS, firewall and Tor service state |
| `changeip` | Request new Tor circuit (NEWNYM signal) |
| `ip` | Show the public IP websites see right now + Tor SOCKS IP |
| `menu` | Interactive numbered menu (default when run without args) |
| `banner` | Show the Arctic Fox banner |
| `version` | Print version |
| `-y, --yes` | Flag: skip confirmation prompts (useful in scripts) |

</details>

### Example: start

```
[?] Route ALL traffic through Tor? (connections will reset briefly) [y/N]: y
[*] Step 1/5  Configuring Tor (transparent proxy + DNS)...
[+] Tor transparent-proxy configuration written to /etc/tor/torrc
[*] Step 2/5  Restarting the Tor service...
[*] Step 3/5  Bootstrapping Tor...
   [*] Waiting for Tor to build a circuit ............
[*] Step 4/5  Applying firewall rules (backup saved to /var/lib/arcticfox)...
[*] Step 5/5  Forcing system DNS through Tor...

  +--------------------------------------------------+
  |  ARCTIC FOX ANONYMITY - ACTIVE                   |
  |  Tor exit IP : 185.220.xxx.xxx                   |
  |  DNS         : routed through Tor (127.0.0.1)    |
  |  IPv6        : blocked (leak protection)         |
  |  Ping (ICMP) : blocked (cannot be proxied)       |
  +--------------------------------------------------+
[+] All traffic is now going through the Tor network.
```

## 🧰 How it works

1. **Tor configuration** — `install.sh` / first `start` appends a marked block to
   `/etc/tor/torrc`: `TransPort 9040`, `DNSPort 5353`, `SocksPort 9050`,
   `ControlPort 9051`, `VirtualAddrNetworkIPv4 10.192.0.0/10`, `AutomapHostsOnResolve 1`.
2. **iptables** — on `start` a custom NAT chain redirects all output TCP to Tor's
   transparent port and DNS to Tor's DNS resolver. Tor's own traffic is exempted
   (`--uid-owner debian-tor`) so no routing loop happens. LAN ranges and loopback stay direct.
3. **Leak protection** — remaining UDP is rejected, ICMP is rejected, IPv6 output is rejected.
4. **Restore** — `stop` removes only the Arctic Fox chains, restores your original
   `resolv.conf` and stops the Tor service. Your system is exactly as it was before.

**Verify anytime:** run `arcticfox status` — it queries `check.torproject.org` and shows
whether you are **really** behind Tor (`Tor: YES`) or not.

## 📁 Repository structure

```
Arctic-Fox-Anonymity/
├── arcticfox          # main tool (bash, ~630 lines)
├── install.sh         # installer (deps + command + completion)
├── uninstall.sh       # clean removal
├── fix_arcticfox.sh   # one-shot fix for old conflicting arcticfox tools
├── completions/       # bash completion
├── logo.png           # official Arctic Fox logo
├── checksums.txt      # sha256 of every file
├── LICENSE            # MIT
└── README.md
```

## 🩺 Troubleshooting

| Problem | Fix |
| --- | --- |
| `ModuleNotFoundError: No module named 'core'` (Python traceback) | An old, unrelated Python tool also named `arcticfox` is shadowing ours. **One-shot fix (included):** `sudo bash fix_arcticfox.sh` |
| `arcticfox` runs the wrong tool after install | `hash -r` or open a new terminal (bash caches command paths) |
| `Tor failed to build a circuit` | Check your internet; on censored networks configure Tor bridges in `/etc/tor/torrc`, then `sudo arcticfox restart` |
| Tor won't start after install | Duplicate port in your custom `torrc`? Remove old `TransPort`/`DNSPort` lines, keep only the Arctic Fox block |
| Ping does not work while routing | By design — ICMP cannot go through Tor. Stop routing to ping |
| Some UDP app fails (Voice/QUIC) | By design — UDP is rejected. TCP fallback is automatic |
| Want the old firewall back manually | ⚠️ `sudo iptables-restore < /var/lib/arcticfox/iptables.v4.bak` **replaces your ENTIRE current firewall** with the snapshot taken at `start` — any rules added after that are lost. Prefer `sudo arcticfox stop` or `sudo arcticfox recover` first — they only remove Arctic Fox's own rules |
| Broke `resolv.conf` manually | `sudo cp /var/lib/arcticfox/resolv.conf.bak /etc/resolv.conf` |

## 🗑️ Uninstall

```bash
sudo bash uninstall.sh     # from the repo folder — removes everything cleanly
```

## 🇵🇰 Roman Urdu — Quick Start

> **Note (Urdu/Hindi users):** Ye tool poore Kali Linux ka internet Tor ke through bhejta hai.
> Install: `sudo bash install.sh` · Chalao: `sudo arcticfox start` · Band karo: `sudo arcticfox stop`
> · Check karo: `arcticfox status`. sirf legal pentesting aur privacy ke liye use karo! 🦊

## 🤝 Contributing

Found a bug or want to improve Arctic Fox? Open an
[issue](https://github.com/arcticfox-cyber/Arctic-Fox-Anonymity/issues) or send a pull request — contributions are welcome!

## ⚠️ Disclaimer

**For legal and ethical use only.** Arctic Fox Anonymity is intended for authorized
penetration testing, security research, OSINT and personal privacy on systems you own or
have permission to test. Anonymity is not a license for crime — Tor exit activity can still
be monitored by exit nodes, and using anonymity tools does not make illegal actions legal.
The authors take no responsibility for misuse.

## 📜 Changelog

### v1.0.3 — security audit fixes

- 🩹 **DNS routing fixed (critical):** local DNS (127.0.0.1:53) is now redirected to Tor's DNSPort *before* the loopback exemption — DNS can no longer bypass the Tor resolver
- 🩹 Duplicate `SocksPort` removed on Debian/Kali (tor-service-defaults already provides one — a duplicate made Tor refuse to start)
- 🛡️ Tor config is validated with `tor --verify-config` (exactly like the systemd unit runs it) before restarting; conflicting port directives in your own torrc are safely commented out
- 🛡️ Every firewall command is individually checked — one failed rule rolls back the whole start
- 🛡️ Failed starts now roll back rules **and** DNS completely
- 🔄 Tor service state is preserved: if Tor ran before Arctic Fox started, it stays on after `stop`
- 🩺 `status` verifies each protection component independently (NAT, TCP redirect, DNS redirects, ICMP, IPv6, resolv.conf, live DNS resolution)
- 🧠 `changeip` validates **both** Tor control responses (AUTHENTICATE + SIGNAL NEWNYM)
- 🚑 New `arcticfox recover` command (menu option 8) — emergency network repair
- 🗑️ Uninstaller restores DNS before touching backups and asks before deleting recovery backups (`--purge` skips the question)
- 🧰 `fix_arcticfox.sh` now shows the pip package and asks before uninstalling it
- 📦 Installer validates the `/usr/bin` symlink step

### v1.0.2 — conflict fixer

- Added `fix_arcticfox.sh` one-shot conflict fixer and bulletproof `/usr/bin/arcticfox` symlink

### v1.0.1 — installer hardening

- Old conflicting `arcticfox` tools are auto-renamed during install

## 📄 License

MIT — see [LICENSE](LICENSE).

---

<div align="center">

**🦊 Arctic Fox Anonymity** · made with ❤️ for the Kali Linux community
by [@arcticfox-cyber](https://github.com/arcticfox-cyber)

</div>
