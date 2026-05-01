STOW_TARGET ?= $(HOME)
STOW_PACKAGES := nvim pi
PI_AGENT_DIR := $(STOW_TARGET)/.pi/agent
PI_MODELS_TEMPLATE := $(PI_AGENT_DIR)/models.json.template
PI_MODELS_OUTPUT := $(PI_AGENT_DIR)/models.json
PI_SANDBOX_DIR := $(PI_AGENT_DIR)/extensions/sandbox

.PHONY: install stow unstow restow stow-dry-run build build-pi pi-models pi-extensions check-stow check-npm check-pi-env check-pi-models-template

install: stow build

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

pi-models: check-pi-env check-pi-models-template
	scripts/generate-pi-models "$(PI_MODELS_TEMPLATE)" "$(PI_MODELS_OUTPUT)"

pi-extensions: check-npm
	npm ci --prefix "$(PI_SANDBOX_DIR)"

check-stow:
	@command -v stow >/dev/null 2>&1 || { echo "stow is required." >&2; exit 1; }

check-npm:
	@command -v npm >/dev/null 2>&1 || { echo "npm is required." >&2; exit 1; }

check-pi-env:
	@test -n "$$OLLAMA_API_KEY" || { echo "OLLAMA_API_KEY is required." >&2; exit 1; }

check-pi-models-template:
	@test -f "$(PI_MODELS_TEMPLATE)" || { echo "$(PI_MODELS_TEMPLATE) is missing. Run make stow first." >&2; exit 1; }
