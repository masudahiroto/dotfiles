# dotfiles

```bash
make install
```

## Doom Emacs

The Doom user config is managed by this repository:

```text
doom/.config/doom/
```

Install Doom Emacs itself and sync packages separately:

```bash
make setup-doom
```

Do not commit Doom's generated local state, especially `~/.config/emacs/.local/`.
