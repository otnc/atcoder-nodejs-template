# @usage pnpm result:delete <問題番号> <番号> [日付]
# @desc  期待出力を削除

{ existsSync, readdirSync, statSync, unlinkSync } = require 'fs'
{ join } = require 'path'
dayjs    = require 'dayjs'
utc      = require 'dayjs/plugin/utc'
timezone = require 'dayjs/plugin/timezone'
dayjs.extend utc
dayjs.extend timezone

rootDir = join __dirname, '..'

args = process.argv.slice 2
unless args.length >= 2
  console.error 'Usage: pnpm result:delete <problem> <number> [date]  (e.g. pnpm result:delete a 1  or  pnpm result:delete a 1 20260418)'
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
  dateDir = dirs.find (d) -> existsSync join qDir, d, 'mock', problem, "#{num}._result.txt"
  unless dateDir
    console.error "Result file not found: q/<date>/mock/#{problem}/#{num}._result.txt"
    process.exit 1

target = join qDir, dateDir, 'mock', problem, "#{num}._result.txt"
unless existsSync target
  console.error "Not found: #{target}"
  process.exit 1

unlinkSync target
console.log "Deleted: #{target}"
