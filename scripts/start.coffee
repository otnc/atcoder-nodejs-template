# @usage pnpm start <問題番号> [テンプレート] [-f]
# @desc  q/YYYYMMDD/<問題番号>.js を生成（既定テンプレート: template.js）
# @desc  テンプレート指定: default | templates/ 内の名前（例: pnpm start a fast）
# @desc  -f / --force で既存ファイルを上書き

{ existsSync, mkdirSync, copyFileSync, readdirSync } = require 'fs'
{ join } = require 'path'
dayjs    = require 'dayjs'
utc      = require 'dayjs/plugin/utc'
timezone = require 'dayjs/plugin/timezone'
dayjs.extend utc
dayjs.extend timezone

rootDir = join __dirname, '..'
templatesDir = join rootDir, 'templates'

args = process.argv.slice 2
force = args.some (a) -> a in ['-f', '--force']
[problem, templateName] = args.filter (a) -> not a.startsWith '-'

unless problem
  console.error 'Usage: pnpm start <problem> [template] [-f]  (e.g. pnpm start a  or  pnpm start a fast -f)'
  process.exit 1

templateName ?= 'default'

# 利用可能なテンプレート一覧（default = ルートの template.js）
listTemplates = ->
  available = ['default']
  if existsSync templatesDir
    for f in readdirSync(templatesDir) when f.endsWith '.js'
      available.push f.replace /\.js$/, ''
  available

# テンプレート解決
templatePath =
  if templateName is 'default'
    join rootDir, 'template.js'
  else
    join templatesDir, "#{templateName}.js"

unless existsSync templatePath
  console.error "Template not found: #{templateName}"
  console.error "Available: #{listTemplates().join ', '}"
  process.exit 1

dateStr = dayjs().tz('Asia/Tokyo').format 'YYYYMMDD'

dir = join rootDir, 'q', dateStr
mkdirSync dir, { recursive: true } unless existsSync dir

dest = join dir, "#{problem}.js"
if existsSync(dest) and not force
  console.log "Already exists: #{dest}  (上書きするには -f)"
  process.exit 0

copyFileSync templatePath, dest
console.log "Created: #{dest}  (template: #{templateName})"
