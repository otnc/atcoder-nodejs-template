# @usage pnpm format [<問題番号> [日付]]
# @desc  問題ファイル（省略時はプロジェクト全体）を Prettier でフォーマット

{ existsSync, readdirSync, statSync } = require 'fs'
{ join } = require 'path'
{ spawnSync } = require 'child_process'
dayjs    = require 'dayjs'
utc      = require 'dayjs/plugin/utc'
timezone = require 'dayjs/plugin/timezone'
dayjs.extend utc
dayjs.extend timezone

rootDir = join __dirname, '..'

args = process.argv.slice 2

unless args.length
  result = spawnSync 'pnpm', ['exec', 'prettier', '--write', '.'],
    stdio: 'inherit', shell: true, cwd: rootDir
  process.exit result.status ? 0

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

filePath = join qDir, dateDir, "#{problem}.js"
result = spawnSync 'pnpm', ['exec', 'prettier', '--write', filePath],
  stdio: 'inherit', shell: true, cwd: rootDir
process.exit result.status ? 0
