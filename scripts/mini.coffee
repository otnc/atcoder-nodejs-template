# @usage pnpm mini <問題番号> [日付]
# @desc  問題ファイルを terser で minify（元ファイルを上書き）
# @desc  上書き前に <問題番号>-bak_<連番>.js としてバックアップを保存

{ existsSync, readdirSync, statSync, readFileSync, writeFileSync, copyFileSync } = require 'fs'
{ join } = require 'path'
{ minify } = require 'terser'
chalk    = require 'chalk'
dayjs    = require 'dayjs'
utc      = require 'dayjs/plugin/utc'
timezone = require 'dayjs/plugin/timezone'
dayjs.extend utc
dayjs.extend timezone

rootDir = join __dirname, '..'

args = process.argv.slice 2
unless args.length
  console.error 'Usage: pnpm mini <problem> [date]  (e.g. pnpm mini a  or  pnpm mini a 20260418)'
  process.exit 1

[problem, specifiedDate] = args

qDir = join rootDir, 'q'
todayStr = dayjs().tz('Asia/Tokyo').format 'YYYYMMDD'

if specifiedDate
  unless existsSync join qDir, specifiedDate, "#{problem}.js"
    console.error "Not found: q/#{specifiedDate}/#{problem}.js"
    process.exit 1
  dateDir = specifiedDate
else
  unless existsSync qDir
    console.error 'No problems found. Run pnpm start first.'
    process.exit 1
  dirs = readdirSync(qDir)
    .filter (d) -> statSync(join qDir, d).isDirectory()
    .sort (a, b) ->
      return -1 if a is todayStr
      return  1 if b is todayStr
      b.localeCompare a
  dateDir = dirs.find (d) -> existsSync join qDir, d, "#{problem}.js"
  unless dateDir
    console.error "Problem file not found: #{problem}.js"
    process.exit 1

dir = join qDir, dateDir
filePath = join dir, "#{problem}.js"
code = readFileSync filePath, 'utf-8'

# 既存の <問題番号>-bak_<連番>.js を調べて次の連番を決める
bakRe = ///^#{problem}-bak_(\d+)\.js$///
maxSeq = readdirSync(dir).reduce (acc, name) ->
  m = name.match bakRe
  if m then Math.max acc, Number m[1] else acc
, 0
seq = maxSeq + 1
bakName = "#{problem}-bak_#{seq}.js"

run = ->
  try
    result = await minify code,
      toplevel: true
      format: comments: false
  catch err
    console.error chalk.red "Minify failed: #{err.message}"
    process.exit 1

  # minify 前のコードをバックアップしてから上書き
  copyFileSync filePath, join(dir, bakName)
  writeFileSync filePath, result.code + '\n'

  before = Buffer.byteLength code, 'utf-8'
  after = Buffer.byteLength result.code, 'utf-8'
  reduction = if before then Math.round((1 - after / before) * 100) else 0

  console.log chalk.gray "Backup : q/#{dateDir}/#{bakName}"
  console.log chalk.gray "Minify : q/#{dateDir}/#{problem}.js"
  console.log chalk.gray "Size   : #{before} -> #{after} bytes (-#{reduction}%)"

run()
