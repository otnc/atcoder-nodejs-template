# @usage pnpm mini:restore <問題番号> <番号> [日付]
# @desc  <問題番号>-bak_<番号>.js を <問題番号>.js に復元

{ existsSync, readdirSync, statSync, copyFileSync } = require 'fs'
{ join } = require 'path'
dayjs    = require 'dayjs'
utc      = require 'dayjs/plugin/utc'
timezone = require 'dayjs/plugin/timezone'
dayjs.extend utc
dayjs.extend timezone

rootDir = join __dirname, '..'

args = process.argv.slice 2
unless args.length >= 2
  console.error 'Usage: pnpm mini:restore <problem> <number> [date]  (e.g. pnpm mini:restore a 1  or  pnpm mini:restore a 1 20260418)'
  process.exit 1

[problem, num, specifiedDate] = args

qDir = join rootDir, 'q'
todayStr = dayjs().tz('Asia/Tokyo').format 'YYYYMMDD'

if specifiedDate
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
  dateDir = dirs.find (d) -> existsSync join qDir, d, "#{problem}-bak_#{num}.js"
  unless dateDir
    console.error "Backup file not found: q/<date>/#{problem}-bak_#{num}.js"
    process.exit 1

bakPath = join qDir, dateDir, "#{problem}-bak_#{num}.js"
unless existsSync bakPath
  console.error "Not found: #{bakPath}"
  process.exit 1

destPath = join qDir, dateDir, "#{problem}.js"
copyFileSync bakPath, destPath
console.log "Restored: q/#{dateDir}/#{problem}-bak_#{num}.js -> q/#{dateDir}/#{problem}.js"
