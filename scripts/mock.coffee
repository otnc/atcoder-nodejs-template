{ existsSync, mkdirSync, readdirSync, statSync, readFileSync, writeFileSync } = require 'fs'
{ join } = require 'path'
dayjs    = require 'dayjs'
utc      = require 'dayjs/plugin/utc'
timezone = require 'dayjs/plugin/timezone'
dayjs.extend utc
dayjs.extend timezone

rootDir = join __dirname, '..'

args = process.argv.slice 2
unless args.length >= 2
  console.error 'Usage: pnpm mock <problem> <number> [date]  (e.g. pnpm mock a 1  or  pnpm mock a 1 20260418)'
  process.exit 1

[problem, num, specifiedDate] = args

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

dest = join qDir, dateDir, 'mock', problem, "#{num}.txt"
mkdirSync (join qDir, dateDir, 'mock', problem), { recursive: true }
console.log "Saving to: #{dest}"
console.log "(Input: ^Z + Enter to save)\n"

input = readFileSync 0, 'utf-8'
writeFileSync dest, input
console.log "\nSaved: #{dest}"
