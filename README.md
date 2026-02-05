# dotfiles

Personal Arch Linux dotfiles for my Omarchy + Hyprland setup.

Includes:
- zsh (Oh My Zsh + Powerlevel10k)
- tmux
- Neovim
- Hyprland

## Restore
```sh
git clone git@github.com:lucasmelnyk/dotfiles.git ~/dotfiles
ln -s ~/dotfiles/zsh/.zshrc ~/.zshrc
ln -s ~/dotfiles/tmux/.tmux.conf ~/.tmux.conf
ln -s ~/dotfiles/config/* ~/.config/

