#!/usr/bin/env bash
#===============================================================================
#  Arctic Fox Anonymity - Uninstaller
#  Stops routing (if active), removes the arcticfox command and cleans up.
#  Recovery backups are kept unless you confirm deletion (or pass --purge).
#  Usage:  sudo bash uninstall.sh [--purge]
#===============================================================================
set -u

if [ -t 1 ]; then
    C_R=$'\e[1;31m'; C_G=$'\e[1;32m'; C_Y=$'\e[1;33m'
    C_C=$'\e[1;36m'; C_W=$'\e[1;37m'; C_0=$'\e[0m'
else
    C_R=""; C_G=""; C_Y=""; C_C=""; C_W=""; C_0=""
fi

ok()   { printf '%s[+]%s %s\n' "$C_G" "$C_0" "$*"; }
err()  { printf '%s[-]%s %s\n' "$C_R" "$C_0" "$*"; }
info() { printf '%s[*]%s %s\n' "$C_C" "$C_0" "$*"; }
warn() { printf '%s[!]%s %s\n' "$C_Y" "$C_0" "$*"; }
die()  { err "$*"; exit 1; }

TORRC="/etc/tor/torrc"
TORRC_MARKER="# === Arctic Fox Anonymity configuration ==="
TORRC_END="# === End Arctic Fox Anonymity ==="
BACKUP_DIR="/var/lib/arcticfox"

printf '\n  %sArctic Fox Anonymity - Uninstaller%s\n\n' "$C_W" "$C_0"

[ "$(id -u)" -eq 0 ] || die "Uninstaller must run as root.  Use:  sudo bash uninstall.sh"

#--- 1. If routing is active, stop it safely -------------------------------------
if [ -x /usr/local/bin/arcticfox ]; then
    info "Stopping any active anonymous routing..."
    /usr/local/bin/arcticfox -y stop >/dev/null 2>&1 || true
    ok "Routing stopped (if it was active)."
fi

#--- 2. Remove the command and assets --------------------------------------------
info "Removing /usr/local/bin/arcticfox ..."
rm -f /usr/local/bin/arcticfox

# Remove OUR bulletproof symlink (only if it points to our tool - never touch others)
if [ -L /usr/bin/arcticfox ] && [ "$(readlink /usr/bin/arcticfox)" = "/usr/local/bin/arcticfox" ]; then
    rm -f /usr/bin/arcticfox
    ok "Removed /usr/bin/arcticfox symlink."
fi

info "Removing /usr/share/arcticfox ..."
rm -rf /usr/share/arcticfox

rm -f /etc/bash_completion.d/arcticfox 2>/dev/null

#--- 3. Clean torrc ---------------------------------------------------------------
if [ -f "$TORRC" ] && grep -qs "$TORRC_MARKER" "$TORRC"; then
    info "Removing Arctic Fox block from $TORRC ..."
    sed -i "\\|$TORRC_MARKER|,\\|$TORRC_END|d" "$TORRC"
    ok "Tor configuration cleaned."
fi

#--- 3b. Safety: never leave DNS forced when the backups are about to go ----------
if grep -qs '^nameserver 127\.0\.0\.1$' /etc/resolv.conf && [ -d "$BACKUP_DIR" ]; then
    warn "/etc/resolv.conf still points to 127.0.0.1 - restoring it now..."
    if [ -f "$BACKUP_DIR/resolv.conf.link" ]; then
        rm -f /etc/resolv.conf
        ln -s "$(cat "$BACKUP_DIR/resolv.conf.link")" /etc/resolv.conf \
            && ok "resolv.conf symlink restored from backup."
    elif [ -f "$BACKUP_DIR/resolv.conf.bak" ]; then
        cp -f "$BACKUP_DIR/resolv.conf.bak" /etc/resolv.conf \
            && ok "resolv.conf restored from backup."
    else
        err "No DNS backup found! Set your DNS manually, e.g.:"
        err "    echo 'nameserver 9.9.9.9' | sudo tee /etc/resolv.conf"
    fi
fi

# Also make sure no firewall rules were left behind
if command -v iptables >/dev/null 2>&1; then
    iptables -t nat -D OUTPUT -j AF_NAT 2>/dev/null; iptables -t nat -F AF_NAT 2>/dev/null; iptables -t nat -X AF_NAT 2>/dev/null
    iptables -D OUTPUT -j AF_FILT 2>/dev/null; iptables -F AF_FILT 2>/dev/null; iptables -X AF_FILT 2>/dev/null
    if command -v ip6tables >/dev/null 2>&1; then
        ip6tables -D OUTPUT -j AF_FILT6 2>/dev/null; ip6tables -F AF_FILT6 2>/dev/null; ip6tables -X AF_FILT6 2>/dev/null
    fi
fi

#--- 4. Remove backups (only with explicit confirmation) ---------------------------
if [ -d "$BACKUP_DIR" ]; then
    if [ "${1:-}" = "--purge" ]; then
        rm -rf "$BACKUP_DIR" && ok "Backup directory removed (--purge)."
    else
        printf '%s[?]%s Delete the recovery backups in %s? [y/N]: ' "$C_Y" "$C_0" "$BACKUP_DIR"
        read -r REPLY
        if [[ "$REPLY" =~ ^[Yy]$ ]]; then
            rm -rf "$BACKUP_DIR" && ok "Backup directory removed."
        else
            ok "Backups KEPT in $BACKUP_DIR (delete manually anytime)."
        fi
    fi
fi

echo ""
ok "Arctic Fox Anonymity has been completely removed."
info "Note: the 'tor' package is still installed. Remove it with:  sudo apt purge tor"
echo ""
