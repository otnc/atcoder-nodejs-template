{ existsSync, readdirSync, statSync, readFileSync } = require 'fs'
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
    spawnSync 'node', [filePath], { input, stdio: ['pipe', 'inherit', 'inherit'] }
    console.log ''
  process.exit 0
else
  console.log "Running: #{filePath}"
  console.log "(Input: ^Z + Enter to execute)\n"
  result = spawnSync 'node', [filePath], { stdio: 'inherit' }
  process.exit result.status ? 0
