#!/bin/sh
# yashiki の配置: kechiiins-macbook-air-2024（MacBook Air ＋ DELL P3222QE）
# init から読まれる。$DELL（外部モニタ）と $MAC（内蔵）は init が決めてある

# タグごとの並べ方。タグごとのレイアウトは画面をまたいで共通（--output は効かない）
yashiki layout-set kinto --tags 2 --output "$DELL"
# DELL タグ1 は Obsidian を右 1/3、タグ3（DaVinci）は右 1/4 に固定（同じ Obsidian が複数のタグにいるので順番では決められない）
yashiki layout-set sanbun --tags 1 --output "$DELL"
yashiki layout-set yonbun --tags 4 --output "$DELL"
# DELL タグ4（勉強）は Claude 左 1/2、右上 Kindle、右下 Obsidian｜cmux（cmux が無ければ右下は Obsidian だけ）
yashiki layout-set benkyou --tags 8 --output "$DELL"
# フリーのタグは並べない（jiyuu）: DELL はタグ10（P）、Mac はタグ9（-）
# タグごとのレイアウトは画面をまたいで共通（--output は効かない）ので、両画面で使っていない番号にする
yashiki layout-set jiyuu --tags 512 --output "$DELL"
yashiki layout-set jiyuu --tags 256 --output "$MAC"

# 定位置（2026-10-31 改）上から番号・左から並べる
# DELL: 1=Claude 2/3+Obsidian 1/3 ／ 2=Chrome+Chrome 1/2ずつ ／ 3=DaVinci 3/4+Obsidian 1/4 ／ 4=勉強 Claude 1/2+右上 Kindle+右下 Obsidian｜cmux
# Mac : 5=Discord ／ 6=Chrome ／ 7=cmux ／ 8=ChatGPT ／ 9=その他（浮いているもの）
# Claude はタグ1と4（1|8=9）、Obsidian はタグ1・3・4（1|4|8=13）
# cmux は2枚。DELL タグ4用の1枚は Mac タグ7に出るので、Option+Shift+O で送ってから Option+Shift+4（移した直後にずれたら W+R で並べ直す）
# Chrome は全部 DELL タグ2に出るので、Mac 用の1枚は Option+Shift+O で送ってから Option+Shift+6
yashiki rule-add --app-name Claude output "$DELL"
yashiki rule-add --app-name Claude tags 9
yashiki rule-add --app-name Obsidian output "$DELL"
yashiki rule-add --app-name Obsidian tags 13
yashiki rule-add --app-name "Google Chrome" output "$DELL"
yashiki rule-add --app-name "Google Chrome" tags 2
yashiki rule-add --app-name "DaVinci Resolve" output "$DELL"
yashiki rule-add --app-name "DaVinci Resolve" tags 4
yashiki rule-add --app-name Kindle output "$DELL"
yashiki rule-add --app-name Kindle tags 8
yashiki rule-add --app-name Discord output "$MAC"
yashiki rule-add --app-name Discord tags 16
yashiki rule-add --app-name cmux output "$MAC"
yashiki rule-add --app-name cmux tags 64
yashiki rule-add --app-name ChatGPT output "$MAC"
yashiki rule-add --app-name ChatGPT tags 128

# たまに開くアプリ（2026-10-31）: 決まった場所の無いものは並べずに浮かせて、いまの画面の上に出す
# 決まった場所のアプリだけ no-float で並べる
yashiki rule-add --app-name "*" float
for a in Claude Obsidian "Google Chrome" "DaVinci Resolve" Discord cmux ChatGPT Kindle; do
  yashiki rule-add --app-name "$a" no-float
done
