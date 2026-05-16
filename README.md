# AtCoder JavaScript Helper

AtCoder の問題を JavaScript で解くためのヘルパーツールです。

## セットアップ

```bash
pnpm nvm       # .nvmrc のバージョンに切り替え（未インストールなら自動インストール）
pnpm install
```

> Unix/macOS の場合は `bash scripts/nvm.sh` を使用してください。

## ディレクトリ構成

```
q/
  YYYYMMDD/           # コンテスト日付ごとのディレクトリ（JST）
    a.js
    b.js
    ...
scripts/
  start.coffee        # ファイル生成スクリプト
  test.coffee         # 実行スクリプト
  nvm.coffee          # Node バージョン切り替え（OS 判定ディスパッチャー）
  nvm.ps1             # Windows 用
  nvm.sh              # Unix/macOS 用
  nvm-restore.coffee  # バージョン復元（OS 判定ディスパッチャー）
  nvm-restore.ps1     # Windows 用
  nvm-restore.sh      # Unix/macOS 用
template.js           # 問題ファイルのテンプレート
.nvmrc                # 使用する Node.js バージョン
```

## 使い方

### Node.js バージョンの切り替え

```bash
pnpm nvm          # 現在のバージョンを .nvm-prev に保存し、.nvmrc のバージョンへ切り替え
pnpm nvm:restore  # .nvm-prev のバージョンに戻す
```

### 問題ファイルを作成する

```bash
pnpm start <問題番号>
```

今日の日付（JST）のディレクトリ `q/YYYYMMDD/` に `<問題番号>.js` を `template.js` をもとに生成します。

```bash
pnpm start a
# => Created: D:\...\q\20260516\a.js
```

ファイルが既に存在する場合は上書きせずスキップします。

### 問題を実行する

```bash
pnpm test <問題番号> [日付]
```

指定した問題ファイルを実行します。日付を省略すると、今日（JST）のディレクトリを優先し、なければ最新のものを使用します。

```bash
pnpm test a
# Running: D:\...\q\20260516\a.js
# (Input: ^Z + Enter to execute)
```

標準入力からテストケースを入力し、**`^Z` → `Enter`** で実行します。

```bash
# パイプで入力する場合
echo "3 5" | pnpm test a

# 日付を指定する場合
pnpm test a 20260418
```

## テンプレート

```js
const fs = require('fs')

function main(input) {
  const args = input.trim().split(/\s+/)
  // ---
}

const input = fs.readFileSync(0, 'utf-8', '/dev/stdin')
main(input)
```

