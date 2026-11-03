#!/usr/bin/env bash
#===============================================================================
#  Arctic Fox Anonymity - Installer for Kali Linux
#  Installs dependencies + the 'arcticfox' command system-wide.
#  Usage:  sudo bash install.sh
#===============================================================================
set -u

NAME="Arctic Fox Anonymity"
VERSION="1.0.3"

if [ -t 1 ]; then
    C_R=$'\e[1;31m'; C_G=$'\e[1;32m'; C_Y=$'\e[1;33m'
    C_C=$'\e[1;36m'; C_W=$'\e[1;37m'; C_B=$'\e[2m'; C_0=$'\e[0m'
else
    C_R=""; C_G=""; C_Y=""; C_C=""; C_W=""; C_B=""; C_0=""
fi

ok()   { printf '%s[+]%s %s\n' "$C_G" "$C_0" "$*"; }
err()  { printf '%s[-]%s %s\n' "$C_R" "$C_0" "$*"; }
info() { printf '%s[*]%s %s\n' "$C_C" "$C_0" "$*"; }
warn() { printf '%s[!]%s %s\n' "$C_Y" "$C_0" "$*"; }
die()  { err "$*"; exit 1; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cat <<'BANNER'

     _          _         _   ___          _
    /_\  _ __ __| |__ _| |_ / __|__ _ _ __| |_ ___ _ _
   / _ \|\ V // _` / _`|  _| (__/ _` | '_ \  _/ -_) '_|
  /_/ \_\\_/\ \__,_\__,_|\__|\___\__,_| .__/\__\___|_|
          |___/                       |_|

BANNER
printf '     %s%s v%s - Installer%s\n\n' "$C_W" "$NAME" "$VERSION" "$C_0"

#--- 1. Root check ---------------------------------------------------------------
[ "$(id -u)" -eq 0 ] || die "Installer must run as root.  Use:  sudo bash install.sh"

#--- 2. Dependencies -------------------------------------------------------------
info "Installing dependencies (tor, curl, iptables)..."
if command -v apt-get >/dev/null 2>&1; then
    export DEBIAN_FRONTEND=noninteractive
    apt-get update -y >/dev/null 2>&1 || true
    apt-get install -y tor curl iptables >/dev/null 2>&1 \
        || apt-get install -y tor curl iptables || die "apt-get failed to install dependencies."
else
    # Non-apt systems: just verify the binaries exist
    for bin in tor curl iptables ip6tables; do
        command -v "$bin" >/dev/null 2>&1 || die "Dependency '$bin' missing and apt-get not found. Install it manually."
    done
fi
ok "Dependencies installed."

#--- 3. Install the main command -------------------------------------------------
info "Installing 'arcticfox' to /usr/local/bin..."
install -m 0755 "$SCRIPT_DIR/arcticfox" /usr/local/bin/arcticfox \
    || die "Could not copy the arcticfox script to /usr/local/bin."
ok "Installed /usr/local/bin/arcticfox"

#--- 3b. Handle conflicting old 'arcticfox' tools ---------------------------------
# Some systems have an OLD, unrelated Python/binary tool also named 'arcticfox'.
# It must be renamed BEFORE we place our bulletproof symlink on top.
OLD="/usr/bin/arcticfox"
if [ -f "$OLD" ] && [ ! -L "$OLD" ] && ! grep -qa "Arctic Fox Anonymity" "$OLD"; then
    warn "Found an OLD / other 'arcticfox' tool at $OLD (not this tool)."
    mv -f "$OLD" "${OLD}.old.$(date +%Y%m%d%H%M%S)" 2>/dev/null \
        && ok "Renamed it to ${OLD}.old.* - it can no longer shadow the new command." \
        || warn "Could not rename it - if 'arcticfox' runs the wrong tool, use fix_arcticfox.sh"
fi

#--- 3c. Bulletproof symlink (sudo + normal shells always resolve to ours) -------
if ln -sf /usr/local/bin/arcticfox /usr/bin/arcticfox; then
    ok "Bulletproof symlink: /usr/bin/arcticfox -> /usr/local/bin/arcticfox"
    [ -x /usr/bin/arcticfox ] || warn "Symlink exists but is not executable - check /usr/local/bin/arcticfox"
else
    die "Could not create the /usr/bin/arcticfox symlink."
fi

#--- 4. Extra assets -------------------------------------------------------------
info "Installing assets to /usr/share/arcticfox..."
mkdir -p /usr/share/arcticfox || die "Could not create /usr/share/arcticfox."
[ -f "$SCRIPT_DIR/logo.png" ]        && cp -f "$SCRIPT_DIR/logo.png"        /usr/share/arcticfox/logo.png
[ -f "$SCRIPT_DIR/README.md" ]       && cp -f "$SCRIPT_DIR/README.md"       /usr/share/arcticfox/README.md
[ -f "$SCRIPT_DIR/LICENSE" ]         && cp -f "$SCRIPT_DIR/LICENSE"         /usr/share/arcticfox/LICENSE
[ -f "$SCRIPT_DIR/fix_arcticfox.sh" ] && cp -f "$SCRIPT_DIR/fix_arcticfox.sh" /usr/share/arcticfox/fix_arcticfox.sh
ok "Assets installed."

#--- 5. Bash completion ----------------------------------------------------------
if [ -d /etc/bash_completion.d ]; then
    cp -f "$SCRIPT_DIR/completions/arcticfox" /etc/bash_completion.d/arcticfox 2>/dev/null \
        && ok "Bash completion installed (re-open your terminal or: source /etc/bash_completion)."
fi

#--- 6. Prepare backup directory --------------------------------------------------
mkdir -p /var/lib/arcticfox || die "Could not create /var/lib/arcticfox."
ok "Backup directory ready: /var/lib/arcticfox"

#--- 7. Verify --------------------------------------------------------------------
echo ""
info "Verifying installation..."
if [ -x /usr/local/bin/arcticfox ]; then
    /usr/local/bin/arcticfox version
    hash -r 2>/dev/null || true
    RESOLVED="$(command -v arcticfox 2>/dev/null || true)"
    if [ -n "$RESOLVED" ] && [ "$RESOLVED" != "/usr/local/bin/arcticfox" ]; then
        warn "Your shell still resolves 'arcticfox' to: $RESOLVED"
        info "Fix: run 'hash -r' or open a new terminal, then try 'arcticfox version'."
    fi
else
    die "/usr/local/bin/arcticfox is missing - installation failed."
fi

echo ""
printf -v dashes '%.0s-' {1..56}
border="  +${dashes}+"
printf '%s%s%s\n' "$C_G" "$border" "$C_0"
printf '  |  %s%-53s%s |\n' "$C_W" "INSTALLATION COMPLETE" "$C_0"
printf '  |  %-53s |\n' "Command  : arcticfox (works from any terminal)"
printf '  |  %-53s |\n' "Start    : sudo arcticfox start"
printf '  |  %-53s |\n' "Menu     : sudo arcticfox menu"
printf '  |  %-53s |\n' "Uninstall: sudo bash uninstall.sh (repo folder)"
printf '%s%s%s\n' "$C_G" "$border" "$C_0"
echo ""
printf '   %sQuick start:%s\n' "$C_Y" "$C_0"
printf '      sudo arcticfox start     # all traffic through Tor\n'
printf '      arcticfox status         # check you are behind Tor\n'
printf '      sudo arcticfox stop      # back to normal internet\n'
echo ""
printf '   %sFOR LEGAL / ETHICAL USE ONLY.%s Pentesting, security research and\n' "$C_R" "$C_0"
printf '   privacy on systems you own. Stay legal, stay safe.  -  Arctic Fox\n'
echo ""
