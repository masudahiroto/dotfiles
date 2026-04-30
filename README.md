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

### 1. stow を入れる

```sh
brew install stow
```

### 2. 既存の設定を退避（初回のみ）

stow は既存ファイルを上書きしない。先に `$HOME` 側を片付ける。

```sh
# 例: nvim
mv ~/.config/nvim ~/.config/nvim.bak
```

### 3. リンクを張る

リポジトリのルートで実行する。

```sh
stow -t ~ nvim
```

確認:

```sh
ls -l ~/.config/nvim   # -> .../dotfiles/nvim/.config/nvim
```

## 操作チートシート

| やりたいこと | コマンド |
|---|---|
| 全パッケージを展開 | `stow -t ~ */` |
| 特定パッケージを展開 | `stow -t ~ nvim` |
| 展開を解除 | `stow -t ~ -D nvim` |
| 構造変更後に貼り直し | `stow -t ~ -R nvim` |
| 動作確認（dry-run） | `stow -t ~ -nv nvim` |
