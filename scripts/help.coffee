# @usage pnpm q
# @desc  このヘルプ（各スクリプトの @usage / @desc から自動生成）を表示

{ readFileSync } = require 'fs'
{ join } = require 'path'
chalk = require 'chalk'

rootDir = join __dirname, '..'

# 各スクリプトの先頭コメントから @usage / @desc を取り出す
extractMeta = (file) ->
  try
    src = readFileSync join(rootDir, file), 'utf-8'
  catch
    return null
  usage = null
  desc = []
  for line in src.split /\r?\n/
    if m = line.match /^#\s*@usage\s+(.*)$/
      usage = m[1].trim()
    else if m = line.match /^#\s*@desc\s+(.*)$/
      desc.push m[1].trim()
    else if usage and not /^#/.test line and line.trim() isnt ''
      break # メタコメントブロックを抜けたら終了
  return null unless usage
  { usage, desc }

pkg = JSON.parse readFileSync(join(rootDir, 'package.json'), 'utf-8')

console.log ''
console.log chalk.bold 'AtCoder Node.js Helper'
console.log chalk.gray 'AtCoder の問題を JavaScript (Node.js) で解くためのヘルパーツールです。'
console.log ''

for name, cmd of pkg.scripts
  m = cmd.match /scripts\/(\S+\.coffee)/
  continue unless m
  meta = extractMeta "scripts/#{m[1]}"
  continue unless meta
  console.log '  ' + chalk.cyan.bold meta.usage
  for d in meta.desc
    console.log '    ' + chalk.gray d

console.log ''
console.log chalk.gray '詳細は README.md を参照してください。'
console.log ''
