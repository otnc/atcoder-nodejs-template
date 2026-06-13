# @usage pnpm nvm
# @desc  .nvmrc のバージョンへ切り替え（現在を .nvm-prev に保存）

{ spawnSync } = require 'child_process'
{ join } = require 'path'
{ platform } = require 'os'

isWindows = platform() is 'win32'

result = if isWindows
  spawnSync 'powershell',
    ['-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', join(__dirname, 'nvm.ps1')],
    stdio: 'inherit'
else
  spawnSync 'bash',
    [join(__dirname, 'nvm.sh')],
    stdio: 'inherit'

process.exit result.status ? 0
