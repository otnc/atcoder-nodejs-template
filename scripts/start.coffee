# @usage pnpm start <問題番号>
# @desc  q/YYYYMMDD/<問題番号>.js を template.js から生成

{ existsSync, mkdirSync, copyFileSync } = require 'fs'
{ join } = require 'path'
dayjs    = require 'dayjs'
utc      = require 'dayjs/plugin/utc'
timezone = require 'dayjs/plugin/timezone'
dayjs.extend utc
dayjs.extend timezone

rootDir = join __dirname, '..'

problem = process.argv[2]
unless problem
  console.error 'Usage: pnpm start <problem>  (e.g. pnpm start a)'
  process.exit 1

dateStr = dayjs().tz('Asia/Tokyo').format 'YYYYMMDD'

dir = join rootDir, 'q', dateStr
mkdirSync dir, { recursive: true } unless existsSync dir

dest = join dir, "#{problem}.js"
if existsSync dest
  console.log "Already exists: #{dest}"
  process.exit 0

copyFileSync join(rootDir, 'template.js'), dest
console.log "Created: #{dest}"
