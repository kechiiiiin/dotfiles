# dotfiles

macOS用の個人設定ファイル集

## 構成

| ファイル | 説明 |
|---------|------|
| `zsh/.zshrc` | zsh設定（PATH、エイリアス、プラグイン） |
| `zsh/.zprofile` | シェルプロファイル（Homebrew、Python） |
| `git/.gitconfig` | Git設定 |
| `git/.gitignore_global` | グローバルgitignore |
| `vim/.vimrc` | Vim設定 |
| `starship/starship.toml` | Starshipプロンプト設定（Nerd Font対応） |
| `ghostty/config` | Ghosttyターミナル設定 |
| `deck/config.yml` | Deckプレゼンテーション設定 |
| `laminate/config.yaml` | Laminateコードブロック画像化設定 |
| `zsh_scripts/obsidian_helper.sh` | Obsidianデイリーノート用ヘルパー |
| `claude/settings.json` | Claude Code設定（hooks、statusLine、plugins） |
| `claude/statusline-command.sh` | ステータスライン表示スクリプト（セッション・使用量表示） |
| `claude/hooks/discord-notify.py` | Claude Code停止・通知時のDiscord通知スクリプト |
| `claude/scripts/save-conversation.py` | 会話をObsidian vaultに自動保存するスクリプト |
| `claude/.env.sample` | Claude Code用環境変数のテンプレート |
| `yashiki/init` | [yashiki](https://github.com/typester/yashiki)（タグ型ウィンドウマネージャー）の起動スクリプト。全 PC 共通のキー割り当て・画面の見分け方 |
| `yashiki/hosts/<LocalHostName>.sh` | yashiki の PC ごとの配置（タグとアプリの対応・タグごとの並べ方）。新しい PC は `scutil --get LocalHostName` の名前でファイルを足す |
| `yashiki/seiretsu` | yashiki の整列キー（W+X／Option+X）。同じアプリの2枚目（Chrome・cmux など）が再起動で元の場所へ戻ったとき、決めた場所へ送り直して並べ直す |
| `yashiki/hosts/<LocalHostName>.seiretsu` | 整列キーの送り先（PC ごと）。1行に `アプリ名｜元の画面｜元のタグ｜送り先の画面｜送り先のタグ`（区切りは半角の縦棒） |
| `yashiki/layouts/yashiki-layout-kinto` | yashiki の自作レイアウト: 横に均等割り |
| `yashiki/layouts/yashiki-layout-sanbun` | yashiki の自作レイアウト: Obsidian を右 1/3 に固定（`yonbun`＝右 1/4、`benkyou`＝勉強用はこのファイルへのリンク） |
| `yashiki/layouts/yashiki-layout-jiyuu` | yashiki の自作レイアウト: 何も並べない（フリーのタグ用） |
| `yashiki/com.kechiiiiin.yashiki.plist` | ログイン時に yashiki を起動する LaunchAgent（setup.sh が登録する） |
| `yashiki/layouts/winowner.swift` | ウィンドウの持ち主アプリを調べる道具。setup.sh がその PC でビルドする |

## セットアップ

```bash
# リポジトリをクローン
git clone git@github.com:kechiiiiin/dotfiles.git ~/dotfiles

# セットアップスクリプトを実行
~/dotfiles/setup.sh
```

既存ファイルがある場合は `.backup` として退避されます。

## 依存関係

- [Homebrew](https://brew.sh/)
- [Starship](https://starship.rs/) - `brew install starship`
- [yashiki](https://github.com/typester/yashiki) - `brew tap typester/yashiki && brew install --cask yashiki`（初回にアクセシビリティ権限を許可する）
- Xcode Command Line Tools - `xcode-select --install`（yashiki の自作レイアウトの python3 と swiftc）
- [Hack Nerd Font](https://www.nerdfonts.com/) - Ghostty・Starship用（setup.shで自動インストール）
- [anyenv](https://github.com/anyenv/anyenv) - 各種言語バージョン管理
