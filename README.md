# dotfiles

GNU stow で管理する dotfiles。

## 構成

```
dotfiles/
└── nvim/                # stow パッケージ
    └── .config/nvim/    # ホームから見たパス
```

`stow nvim` を実行するとパッケージ配下の構造が `$HOME` に symlink として展開される。
新しいパッケージを足すときも同じルール: `<package>/<home から見たパス>/...`。

## セットアップ

### 1. 依存コマンドを入れる

macOS:

```sh
brew install stow gettext
```

Linux:

```sh
# Debian / Ubuntu
sudo apt install stow gettext npm

# Fedora
sudo dnf install stow gettext npm
```

### 2. 既存の設定を退避（初回のみ）

stow は既存ファイルを上書きしない。先に `$HOME` 側を片付ける。

```sh
# 例: nvim
mv ~/.config/nvim ~/.config/nvim.bak

# 例: pi
mv ~/.pi/agent/agents ~/.pi/agent/agents.bak
mv ~/.pi/agent/prompts ~/.pi/agent/prompts.bak
mv ~/.pi/agent/extensions ~/.pi/agent/extensions.bak
mv ~/.pi/agent/settings.json ~/.pi/agent/settings.json.bak
```

### 3. 環境変数を設定する

`~/.pi/agent/models.json` は API key を含むため Git 管理しない。
`make install` 時に `OLLAMA_API_KEY` から生成する。

```sh
export OLLAMA_API_KEY="..."
```

### 4. インストールする

リポジトリのルートで実行する。

```sh
make install
```

確認:

```sh
ls -l ~/.config/nvim   # -> .../dotfiles/nvim/.config/nvim
```

## 操作チートシート

| やりたいこと | コマンド |
|---|---|
| リンク作成とビルドを実行 | `make install` |
| 全パッケージを展開 | `make stow` |
| 展開を解除 | `make unstow` |
| 構造変更後に貼り直し | `make restow` |
| 動作確認（dry-run） | `make stow-dry-run` |
| ビルドだけ実行 | `make build` |
| Pi のビルドだけ実行 | `make build-pi` |

## Pi

Pi Coding Agent の設定は `pi` パッケージで管理する。

```sh
make stow
```

`~/.pi/agent/models.json.template` を管理し、環境変数から `~/.pi/agent/models.json` を生成する。

```sh
export OLLAMA_API_KEY="..."
make pi-models
```

拡張の Node.js 依存は `package-lock.json` に従って入れる。

```sh
make pi-extensions
```
