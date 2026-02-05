#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d_%H%M%S)"

info() { printf "\033[1;36m[info]\033[0m %s\n" "$*"; }
warn() { printf "\033[1;33m[warn]\033[0m %s\n" "$*"; }
err()  { printf "\033[1;31m[err]\033[0m %s\n" "$*"; }

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || { err "Missing command: $1"; exit 1; }
}

is_arch() {
  [[ -f /etc/os-release ]] && grep -qiE '^ID=arch|^ID_LIKE=.*arch' /etc/os-release
}

backup_if_exists() {
  local target="$1"
  if [[ -e "$target" || -L "$target" ]]; then
    mkdir -p "$BACKUP_DIR"
    info "Backing up $target -> $BACKUP_DIR"
    mv "$target" "$BACKUP_DIR"/
  fi
}

link() {
  local src="$1"
  local dst="$2"

  if [[ ! -e "$src" ]]; then
    warn "Source missing, skipping: $src"
    return 0
  fi

  mkdir -p "$(dirname "$dst")"
  backup_if_exists "$dst"
  ln -s "$src" "$dst"
  info "Linked $dst -> $src"
}

install_pkgs_arch() {
  # Keep this list small and useful. Add/remove as you like.
  local pkgs=(
    zsh
    tmux
    neovim
    git
    ripgrep
    fzf
    fd
    zoxide
    bat
    eza
    git-delta
    lazygit
    wl-clipboard
  )

  info "Installing packages (Arch): ${pkgs[*]}"
  sudo pacman -Syu --needed --noconfirm "${pkgs[@]}"
}

main() {
  need_cmd git

  if [[ ! -d "$DOTFILES_DIR" ]]; then
    err "Dotfiles dir not found: $DOTFILES_DIR"
    err "Set DOTFILES_DIR or clone to ~/dotfiles"
    exit 1
  fi

  info "Using dotfiles dir: $DOTFILES_DIR"

  if is_arch; then
    install_pkgs_arch
  else
    warn "Not Arch detected. Skipping package install."
  fi

  # Symlinks
  link "$DOTFILES_DIR/zsh/.zshrc"   "$HOME/.zshrc"
  link "$DOTFILES_DIR/tmux/.tmux.conf" "$HOME/.tmux.conf"
  link "$DOTFILES_DIR/config/nvim" "$HOME/.config/nvim"
  link "$DOTFILES_DIR/config/hypr" "$HOME/.config/hypr"

  info "Done."
  if [[ -d "$BACKUP_DIR" ]]; then
    info "Backups saved in: $BACKUP_DIR"
  fi

  info "Next:"
  info "  - Restart terminal (or: exec zsh)"
  info "  - Reload tmux: tmux source-file ~/.tmux.conf"
}

main "$@"

