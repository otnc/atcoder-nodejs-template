# @usage pnpm test <問題番号> [日付]
# @desc  問題ファイルを実行（モックがあれば自動実行・期待出力と比較）
# @desc  日付省略時は今日（JST）優先、なければ最新を使用

{ existsSync, readdirSync, statSync, readFileSync } = require 'fs'
{ join } = require 'path'
{ spawnSync } = require 'child_process'
chalk = require 'chalk'
dayjs    = require 'dayjs'
utc      = require 'dayjs/plugin/utc'
timezone = require 'dayjs/plugin/timezone'
dayjs.extend utc
dayjs.extend timezone

rootDir = join __dirname, '..'

args = process.argv.slice 2
unless args.length
  console.error 'Usage: pnpm test <problem> [date]  (e.g. pnpm test a  or  pnpm test a 20260418)'
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

filePath = join qDir, dateDir, "#{problem}.js"

# Check for mock files (q/YYYYMMDD/mock/[problem]/[number].txt)
mockDir = join qDir, dateDir, 'mock', problem
mockFiles = if existsSync mockDir
  readdirSync(mockDir)
    .filter (f) -> /^\d+\.txt$/.test f
    .sort (a, b) -> parseInt(a) - parseInt(b)
else
  []

if mockFiles.length
  console.log "Running: #{filePath}"
  console.log "Mocks: #{mockFiles.length} file(s)\n"
  for mockFile in mockFiles
    num = mockFile.replace '.txt', ''
    mockPath = join mockDir, mockFile
    console.log "--- Mock #{num}: #{mockPath} ---"
    input = readFileSync mockPath
    ran = spawnSync 'node', [filePath], { input, stdio: ['pipe', 'pipe', 'inherit'], encoding: 'utf-8' }
    process.stdout.write ran.stdout if ran.stdout
    resultFile = join mockDir, "#{num}._result.txt"
    if existsSync resultFile
      console.log ''
      normalize = (s) -> s.replace(/\r\n/g, '\n').replace(/\r/g, '\n').trimEnd()
      expected = normalize readFileSync resultFile, 'utf-8'
      actual   = normalize ran.stdout ? ''
      if actual is expected
        console.log chalk.green 'Correct'
      else
        console.log chalk.red 'Incorrect'
        console.log "  Expected: #{expected.replace /\n/g, '\\n'}"
        console.log "  Actual:   #{actual.replace /\n/g, '\\n'}"
    console.log ''
  process.exit 0
else
  console.log "Running: #{filePath}"
  console.log "(Input: ^Z + Enter to execute)\n"
  result = spawnSync 'node', [filePath], { stdio: 'inherit' }
  process.exit result.status ? 0
