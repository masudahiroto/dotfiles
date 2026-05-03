STOW_TARGET ?= $(HOME)
STOW_PACKAGES := nvim pi doom
APT_PACKAGES := stow gettext-base ripgrep bubblewrap socat fd-find emacs-nox curl
NPM_CODING_AGENT_PACKAGES := @openai/codex
NPM_PI_CODING_AGENT_PACKAGES := @mariozechner/pi-coding-agent
NPM_EMACS_PACKAGES := typescript typescript-language-server
NEOVIM_ARCHIVE := nvim-linux-x86_64.tar.gz
NEOVIM_URL := https://github.com/neovim/neovim/releases/latest/download/$(NEOVIM_ARCHIVE)
NEOVIM_INSTALL_DIR := /opt/nvim-linux-x86_64
NEOVIM_BIN := /usr/local/bin/nvim
PI_AGENT_DIR := $(STOW_TARGET)/.pi/agent
PI_MODELS_TEMPLATE := $(PI_AGENT_DIR)/models.json.template
PI_MODELS_OUTPUT := $(PI_AGENT_DIR)/models.json
PI_SANDBOX_DIR := $(PI_AGENT_DIR)/extensions/sandbox
DOOM_EMACS_DIR := $(STOW_TARGET)/.config/emacs
DOOM_REPO := https://github.com/doomemacs/doomemacs
TREESIT_TYPESCRIPT_REPO := https://github.com/tree-sitter/tree-sitter-typescript

.PHONY: install setup-system-packages setup-neovim setup-coding-agents install-codex install-pi-cli setup-emacs setup-emacs-lsp setup-emacs-treesit stow unstow restow stow-dry-run build build-pi setup-doom pi-models pi-extensions check-stow check-git check-curl check-npm check-emacs check-pi-env check-pi-models-template

install: setup-system-packages setup-neovim stow setup-coding-agents build

setup-system-packages:
	@if command -v apt-get >/dev/null 2>&1 && command -v sudo >/dev/null 2>&1; then \
		sudo apt-get update; \
		sudo DEBIAN_FRONTEND=noninteractive apt-get install -y $(APT_PACKAGES); \
	else \
		for package in stow envsubst rg bwrap socat fdfind emacs; do \
			command -v "$$package" >/dev/null 2>&1 || { echo "$$package is required." >&2; exit 1; }; \
		done; \
	fi

setup-neovim: check-curl
	@set -e; \
	tmp_dir="$$(mktemp -d)"; \
	trap 'rm -rf "$$tmp_dir"' EXIT; \
	curl -fsSL -o "$$tmp_dir/$(NEOVIM_ARCHIVE)" "$(NEOVIM_URL)"; \
	sudo rm -rf "$(NEOVIM_INSTALL_DIR)"; \
	sudo tar -C /opt -xzf "$$tmp_dir/$(NEOVIM_ARCHIVE)"; \
	sudo mkdir -p "$$(dirname "$(NEOVIM_BIN)")"; \
	sudo ln -sfn "$(NEOVIM_INSTALL_DIR)/bin/nvim" "$(NEOVIM_BIN)"; \
	"$(NEOVIM_BIN)" --version | head -n 1

setup-coding-agents: install-codex install-pi-cli

install-codex: check-npm
	npm install -g $(NPM_CODING_AGENT_PACKAGES)

install-pi-cli: check-npm
	npm install -g $(NPM_PI_CODING_AGENT_PACKAGES)

setup-emacs: setup-doom setup-emacs-lsp setup-emacs-treesit

setup-emacs-lsp: check-npm
	npm install -g $(NPM_EMACS_PACKAGES)

setup-emacs-treesit: check-emacs
	emacs --init-directory "$(DOOM_EMACS_DIR)" \
		--eval "(progn (require 'treesit) (setq treesit-language-source-alist '((typescript \"$(TREESIT_TYPESCRIPT_REPO)\" \"master\" \"typescript/src\") (tsx \"$(TREESIT_TYPESCRIPT_REPO)\" \"master\" \"tsx/src\"))) (unless (treesit-language-available-p 'typescript) (treesit-install-language-grammar 'typescript)) (unless (treesit-language-available-p 'tsx) (treesit-install-language-grammar 'tsx)) (kill-emacs 0))"

stow: check-stow
	stow -t "$(STOW_TARGET)" $(STOW_PACKAGES)

unstow: check-stow
	stow -t "$(STOW_TARGET)" -D $(STOW_PACKAGES)

restow: check-stow
	stow -t "$(STOW_TARGET)" -R $(STOW_PACKAGES)

stow-dry-run: check-stow
	stow -t "$(STOW_TARGET)" -nv $(STOW_PACKAGES)

build: build-pi

build-pi: pi-models pi-extensions

setup-doom: check-git check-emacs
	@if [ ! -d "$(DOOM_EMACS_DIR)/.git" ]; then \
		git clone --depth 1 "$(DOOM_REPO)" "$(DOOM_EMACS_DIR)"; \
	fi
	"$(DOOM_EMACS_DIR)/bin/doom" sync

pi-models: check-pi-env check-pi-models-template
	scripts/generate-pi-models "$(PI_MODELS_TEMPLATE)" "$(PI_MODELS_OUTPUT)"

pi-extensions: check-npm
	npm ci --prefix "$(PI_SANDBOX_DIR)"

check-stow:
	@command -v stow >/dev/null 2>&1 || { echo "stow is required." >&2; exit 1; }

check-git:
	@command -v git >/dev/null 2>&1 || { echo "git is required." >&2; exit 1; }

check-curl:
	@command -v curl >/dev/null 2>&1 || { echo "curl is required." >&2; exit 1; }

check-npm:
	@command -v npm >/dev/null 2>&1 || { echo "npm is required." >&2; exit 1; }

check-emacs:
	@command -v emacs >/dev/null 2>&1 || { echo "emacs is required." >&2; exit 1; }

check-pi-env:
	@test -n "$$OLLAMA_API_KEY" || { echo "OLLAMA_API_KEY is required." >&2; exit 1; }

check-pi-models-template:
	@test -f "$(PI_MODELS_TEMPLATE)" || { echo "$(PI_MODELS_TEMPLATE) is missing. Run make stow first." >&2; exit 1; }
