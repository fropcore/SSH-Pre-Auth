#!/usr/bin/env bash
# install-ubuntu.sh
set -euo pipefail

BANNER_TEXT='This service supports free expression and rejects 
censorship campaigns against art, NSFW content, or satire.
If you advocate speech bans or “morality” filters, disconnect.
Unauthorized access is prohibited and monitored. - S0X'

BANNER_PATH="${BANNER_PATH:-/etc/issue.net}"
DROPIN_DIR="/etc/ssh/sshd_config.d"
DROPIN_FILE="${DROPIN_DIR}/99-banner.conf"
SSHD_CONFIG="/etc/ssh/sshd_config"

log()  { printf "[*] %s\n" "$*"; }
ok()   { printf "[✓] %s\n" "$*"; }
warn() { printf "[!] %s\n" "$*"; }
die()  { printf "[✗] %s\n" "$*" >&2; exit 1; }

need_root() { [[ $EUID -eq 0 ]] || die "Please run as root (sudo)"; }

assert_ubuntu() {
  if ! grep -qi ubuntu /etc/os-release 2>/dev/null; then
    warn "This script is tailored for Ubuntu; continuing anyway."
  else
    ok "Ubuntu detected."
  fi
}

backup_if_exists() {
  local f="$1"
  if [[ -f "$f" ]]; then
    local ts; ts="$(date +%Y%m%d-%H%M%S)"
    cp -a "$f" "${f}.bak.${ts}"
    ok "Backed up $f -> ${f}.bak.${ts}"
  fi
}

write_banner_file() {
  printf "%s\n" "$BANNER_TEXT" > "$BANNER_PATH"
  chmod 0644 "$BANNER_PATH"
  ok "Wrote banner text to ${BANNER_PATH}"
}

write_dropin() {
  mkdir -p "$DROPIN_DIR"
  backup_if_exists "$DROPIN_FILE"
  printf "Banner %s\n" "$BANNER_PATH" > "$DROPIN_FILE"
  chmod 0644 "$DROPIN_FILE"
  ok "Created drop-in ${DROPIN_FILE}"
}

detect_conflicts() {
  log "Scanning for conflicting Banner directives..."
  local conflicts
  conflicts=$(grep -Rni --include='*.conf' '^\s*Banner\s+' /etc/ssh 2>/dev/null || true)
  if [[ -n "$conflicts" ]]; then
    echo "$conflicts"
    if echo "$conflicts" | grep -qi 'Banner[[:space:]]\+none'; then
      warn "Found 'Banner none'. The 99-banner.conf drop-in should override it, but consider removing it."
    fi
  else
    ok "No other Banner directives found in /etc/ssh/*.conf"
  fi
}

validate_and_reload() {
  if ! sshd -t 2>/dev/null; then
    die "sshd_config validation failed. Aborting."
  fi
  ok "sshd_config validation passed."
  systemctl reload ssh 2>/dev/null || systemctl reload sshd
  ok "SSH service reloaded."
}

show_effective_banner() {
  local eff
  eff=$(sshd -T 2>/dev/null | grep -i '^banner' || true)
  if [[ -n "$eff" ]]; then
    ok "Effective setting: ${eff}"
  else
    warn "Could not read effective banner via 'sshd -T'."
  fi
}

main() {
  need_root
  assert_ubuntu
  backup_if_exists "$SSHD_CONFIG"
  write_banner_file
  write_dropin
  detect_conflicts
  validate_and_reload
  show_effective_banner
  echo
  ok "Done. Test in another terminal:"
  echo "  ssh -o LogLevel=ERROR user@your-host"
  echo "Note: some non-interactive SSH commands will not display banners."
}
main "$@"
