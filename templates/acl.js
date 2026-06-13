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

class UnionFind {
  constructor(n) {
    this.parent = new Int32Array(n).fill(-1)
  }
  find(x) {
    while (this.parent[x] >= 0) {
      const p = this.parent[x]
      if (this.parent[p] >= 0) this.parent[x] = this.parent[p]
      x = this.parent[x]
    }
    return x
  }
  union(a, b) {
    a = this.find(a)
    b = this.find(b)
    if (a === b) return false
    if (this.parent[a] > this.parent[b]) [a, b] = [b, a]
    this.parent[a] += this.parent[b]
    this.parent[b] = a
    return true
  }
  same(a, b) {
    return this.find(a) === this.find(b)
  }
  size(x) {
    return -this.parent[this.find(x)]
  }
}

class Fenwick {
  constructor(n) {
    this.n = n
    this.tree = new Array(n + 1).fill(0)
  }
  add(i, x) {
    for (i++; i <= this.n; i += i & -i) this.tree[i] += x
  }
  sum(r) {
    let s = 0
    for (; r > 0; r -= r & -r) s += this.tree[r]
    return s
  }
  rangeSum(l, r) {
    return this.sum(r) - this.sum(l)
  }
}

class SegTree {
  constructor(n, op, e) {
    this.op = op
    this.e = e
    let size = 1
    while (size < n) size <<= 1
    this.size = size
    this.data = new Array(2 * size).fill(e)
  }
  set(i, x) {
    i += this.size
    this.data[i] = x
    for (i >>= 1; i >= 1; i >>= 1) this.data[i] = this.op(this.data[2 * i], this.data[2 * i + 1])
  }
  get(i) {
    return this.data[i + this.size]
  }
  prod(l, r) {
    let sl = this.e,
      sr = this.e
    l += this.size
    r += this.size
    while (l < r) {
      if (l & 1) sl = this.op(sl, this.data[l++])
      if (r & 1) sr = this.op(this.data[--r], sr)
      l >>= 1
      r >>= 1
    }
    return this.op(sl, sr)
  }
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
