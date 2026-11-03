#!/usr/bin/env bash
#===============================================================================
#  Arctic Fox Anonymity - One-Shot Fixer (Kali Linux)
#
#  Ye script command-conflict ka PAKKA ilaaj hai:
#    1. Har wo 'arcticfox' file dhoondta hai jo HAMARA tool nahi hai
#       (/usr/bin, /usr/local/bin, ~/.local/bin waghera) - aur usay rename
#       kar deta hai (.old.TIMESTAMP) - kuch delete nahi hota, safe hai.
#    2. Hamara tool /usr/local/bin/arcticfox pe confirm/install karta hai.
#    3. /usr/bin/arcticfox pe symlink banata hai -> ab sudo chahe kisi bhi
#       order me PATH dekhe, HAMESHA hamara tool chalega.
#    4. Agar purana tool pip se aya tha to wo package bhi hata deta hai.
#    5. Dono modes verify karta hai (normal + sudo).
#
#  Usage:  sudo bash fix_arcticfox.sh
#===============================================================================
set -u

if [ -t 1 ]; then
    C_R=$'\e[1;31m'; C_G=$'\e[1;32m'; C_Y=$'\e[1;33m'; C_C=$'\e[1;36m'; C_0=$'\e[0m'
else
    C_R=""; C_G=""; C_Y=""; C_C=""; C_0=""
fi
ok()   { printf '%s[+]%s %s\n' "$C_G" "$C_0" "$*"; }
warn() { printf '%s[!]%s %s\n' "$C_Y" "$C_0" "$*"; }
err()  { printf '%s[-]%s %s\n' "$C_R" "$C_0" "$*"; }

STAMP="$(date +%Y%m%d%H%M%S)"
MARKER="Arctic Fox Anonymity"

echo ""
echo "  ${C_C}Arctic Fox Anonymity - One-Shot Fixer${C_0}"
echo ""

#--- 0. Root check ----------------------------------------------------------------
[ "$(id -u)" -eq 0 ] || { err "Root chahiye. Chalao:  sudo bash $0"; exit 1; }

# Invoking user ka home (sudo ke sath HOME=/root ho jata hai)
USER_HOME="$(getent passwd "${SUDO_USER:-root}" 2>/dev/null | cut -d: -f6)"

#--- 1. Foreign 'arcticfox' files rename karo -------------------------------------
FIXED=0
for dir in /usr/bin /usr/local/bin /bin /usr/sbin /sbin /root/.local/bin \
           "${USER_HOME:+$USER_HOME/.local/bin}"; do
    [ -n "$dir" ] || continue
    f="$dir/arcticfox"
    [ -e "$f" ] || continue
    if grep -qa "$MARKER" "$f" 2>/dev/null; then
        ok "Keep:  $f   (ye hamara hi tool hai)"
    else
        mv -f "$f" "$f.old.$STAMP" \
            && { ok "Fixed: $f   ->  $(basename "$f").old.$STAMP  (purana tool, renamed)"; FIXED=1; } \
            || warn "Rename nahi ho saka: $f (manually dekh lo)"
    fi
done
[ "$FIXED" -eq 0 ] && ok "Koi conflicting purana tool nahi mila."

#--- 2. Hamara tool /usr/local/bin pe pakka karo ----------------------------------
SRC=""
for c in "$(pwd)/arcticfox" "$USER_HOME/Downloads/Arctic-Fox-Anonymity/arcticfox" \
         /root/Downloads/Arctic-Fox-Anonymity/arcticfox /usr/share/arcticfox/arcticfox; do
    [ -n "$c" ] && [ -f "$c" ] && grep -qa "$MARKER" "$c" && { SRC="$c"; break; }
done
if [ -f /usr/local/bin/arcticfox ] && grep -qa "$MARKER" /usr/local/bin/arcticfox; then
    ok "Hamara tool installed hai: /usr/local/bin/arcticfox"
elif [ -n "$SRC" ]; then
    install -m 0755 "$SRC" /usr/local/bin/arcticfox \
        && ok "Reinstalled: $SRC -> /usr/local/bin/arcticfox"
else
    warn "/usr/local/bin/arcticfox nahi mila aur source bhi nahi mila."
    warn "Pehle installer chalao:  cd Arctic-Fox-Anonymity && sudo bash install.sh"
    exit 1
fi

#--- 3. Bulletproof symlink (/usr/bin me) ------------------------------------------
ln -sf /usr/local/bin/arcticfox /usr/bin/arcticfox
ok "Symlink: /usr/bin/arcticfox -> /usr/local/bin/arcticfox  (sudo bhi ab sahi uthayega)"

#--- 4. Purana pip package ho to PUCHH ke hata do (koi aur package kharab na ho) --
maybe_uninstall_pip() {
    local pipcmd="$1"
    command -v "$pipcmd" >/dev/null 2>&1 || return 0
    "$pipcmd" show arcticfox >/dev/null 2>&1 || return 0
    warn "Python package 'arcticfox' ($pipcmd) mila - ye shayad wahi purana conflict hai:"
    "$pipcmd" show arcticfox 2>/dev/null | sed -n '1,2p' | sed 's/^/       /'
    printf '%s[?]%s Is pip package ko uninstall karein? [y/N]: ' "$C_Y" "$C_0"
    local reply
    read -r reply
    if [[ "$reply" =~ ^[Yy]$ ]]; then
        "$pipcmd" uninstall -y arcticfox >/dev/null 2>&1 && ok "pip package 'arcticfox' hata diya ($pipcmd)."
    else
        warn "Skip kiya. Baad me khud hata sakte ho:  $pipcmd uninstall arcticfox"
    fi
}
maybe_uninstall_pip pip3
maybe_uninstall_pip pip

#--- 5. Verify (dono modes) ---------------------------------------------------------
hash -r 2>/dev/null || true
echo ""
echo "  ${C_C}Verification:${C_0}"
printf '     %-26s %s\n' "Normal shell:" "$(command -v arcticfox 2>/dev/null)"
printf '     %-26s %s\n' "Under sudo:"   "$(sudo sh -c 'command -v arcticfox' 2>/dev/null)"
echo ""
V="$(arcticfox version 2>&1)"
VS="$(sudo arcticfox version 2>&1)"
printf '     %-26s %s\n' "arcticfox version:" "$V"
printf '     %-26s %s\n' "sudo arcticfox version:" "$VS"
echo ""
if echo "$V" | grep -q "$MARKER" && echo "$VS" | grep -q "$MARKER"; then
    ok "SAB PAKKA THEK HAI!  Ab chalao:  sudo arcticfox start"
    echo ""
    echo "     Quick start:"
    echo "        sudo arcticfox start     <- sab traffic Tor pe"
    echo "        arcticfox status         <- check karo (Tor: YES dikhna chahiye)"
    echo "        sudo arcticfox stop      <- wapas normal internet"
    echo ""
else
    err "Abhi bhi gadbad hai - upar wali 'Verification' lines ka screenshot bhejo."
    exit 1
fi
