const fs = require('fs')

const out = []
const print = (x) => out.push(x)

const rep = (n, f) => {
  for (let i = 0; i < n; i++) f(i)
}
const sortAsc = (a) => a.sort((x, y) => x - y)
const sortDesc = (a) => a.sort((x, y) => y - x)

const lowerBound = (a, x) => {
  let lo = 0,
    hi = a.length
  while (lo < hi) {
    const m = (lo + hi) >> 1
    if (a[m] < x) lo = m + 1
    else hi = m
  }
  return lo
}
const upperBound = (a, x) => {
  let lo = 0,
    hi = a.length
  while (lo < hi) {
    const m = (lo + hi) >> 1
    if (a[m] <= x) lo = m + 1
    else hi = m
  }
  return lo
}
const bisect = (ok, ng, f) => {
  while (Math.abs(ok - ng) > 1) {
    const m = ng + Math.floor((ok - ng) / 2)
    if (f(m)) ok = m
    else ng = m
  }
  return ok
}

function main(input) {
  const tokens = input.trim().split(/\s+/)
  let idx = 0
  const next = () => tokens[idx++]
  const nextInt = () => +tokens[idx++]
  const nextInts = (n) => Array.from({ length: n }, () => +tokens[idx++])

  // ---
}

const input = fs.readFileSync(0, 'utf-8', '/dev/stdin')
main(input)
process.stdout.write(out.length ? out.join('\n') + '\n' : '')
