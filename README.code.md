# テンプレート / ヘルパー使用例

`pnpm start <問題番号> <テンプレート>` で選択できるテンプレートに同梱された、入出力ヘルパー・データ構造の使い方をまとめます。

- `default`（`template.js`）: 最小構成
- `fast`（`templates/fast.js`）: 高速 I/O ＋ 共通ヘルパー
- `acl`（`templates/acl.js`）: `fast` ＋ AC Library 風データ構造

> AtCoder のジャッジは提出した 1 ファイルのみを実行します。ここで使うヘルパー・データ構造はすべて提出ファイルに同梱される自作コードです（外部パッケージの `require` は不可）。

---

## 入力ヘルパー（fast / acl 共通）

`main(input)` 内で、空白・改行区切りのトークンを先頭から順に読みます。

| 関数 | 説明 |
| --- | --- |
| `next()` | 次のトークンを文字列で取得 |
| `nextInt()` | 次のトークンを数値で取得 |
| `nextInts(n)` | 次の n 個を数値配列で取得 |

```js
// 入力:
// 3
// 5 2 8
const n = nextInt() // 3
const a = nextInts(n) // [5, 2, 8]
const s = next() // 文字列として読む場合
```

```js
// H 行 W 列のグリッド
const h = nextInt()
const w = nextInt()
const grid = Array.from({ length: h }, () => next().split(""))
```

---

## 出力ヘルパー（fast / acl 共通）

`print(x)` で出力をバッファ `out` に貯め、プログラム終了時に 1 回だけ書き出します。`console.log` を毎行呼ぶよりはるかに高速です。

```js
print(42)
print([1, 2, 3].join(" ")) // スペース区切り
rep(3, (i) => print(i)) // 0 / 1 / 2 を順に
// => 末尾で out.join("\n") がまとめて出力される
```

`Yes`/`No` 形式:

```js
print(ok ? "Yes" : "No")
```

---

## ループ / ソート / 探索（fast / acl 共通）

| 関数 | 説明 |
| --- | --- |
| `rep(n, f)` | `for (let i=0; i<n; i++) f(i)` の定番ループ |
| `sortAsc(a)` / `sortDesc(a)` | 数値の昇順 / 降順ソート（破壊的） |
| `lowerBound(a, x)` | 昇順 `a` で `a[i] >= x` となる最小の i |
| `upperBound(a, x)` | 昇順 `a` で `a[i] > x` となる最小の i |
| `bisect(ok, ng, f)` | 答えで二分探索。`f(ok)=true / f(ng)=false` の境界の `ok` 側を返す |

### ループ

```js
let sum = 0
rep(n, (i) => {
  sum += a[i]
})
```

> 最内側のホットループは、コールバックを挟まない素の `for` が最速です。`rep` は記述量を減らす用途。本当に速度が要るループは次のように書きます。
>
> ```js
> for (let i = 0; i < n; i++) {
>   // ...
> }
> ```

### ソート

```js
sortAsc([10, 2, 1]) // [1, 2, 10]
sortDesc([10, 2, 1]) // [10, 2, 1]

// 素の sort は辞書順になる罠
;[10, 2, 1].sort() // [1, 10, 2]
```

> 巨大な整数配列は `Int32Array`（または `Float64Array`）にすると、`.sort()` が**数値順かつ高速**になります（比較関数の呼び出しが不要）。
>
> ```js
> const a = Int32Array.from(nextInts(n))
> a.sort() // 数値昇順。比較関数を渡さなくてよい
> ```

### 探索（二分探索）

`lowerBound` / `upperBound` は**昇順ソート済み**の配列に対して使います。

```js
const a = [1, 2, 2, 2, 4, 7]
lowerBound(a, 2) // 1（最初の 2 の位置）
upperBound(a, 2) // 4（最後の 2 の次）
upperBound(a, 2) - lowerBound(a, 2) // 3（値 2 の個数）
lowerBound(a, 8) // 6（全要素より大きい → 末尾）
```

`bisect` は「条件を満たす最大/最小の答え」を探すパターン（めぐる式二分探索）。`f` が単調なら境界を O(log) で求めます。

```js
// x*x <= 50 を満たす最大の x（= 7）
const x = bisect(1, 2e9, (m) => m * m <= 50)

// 単調に false→true となる最小の i（a[i] >= 4 の最小 i = 4）
const i = bisect(a.length - 1, -1, (m) => a[m] >= 4)
```

---

## データ構造（acl のみ）

### `UnionFind`（DSU / 素集合）

連結成分の管理。`union` / `same` / `size` が O(α(n))。

```js
const uf = new UnionFind(n) // 要素 0..n-1
uf.union(a, b) // a, b を併合（新たに併合したら true）
uf.same(a, b) // 同じ集合か
uf.size(a) // a が属する集合のサイズ
uf.find(a) // 代表元
```

例: 辺をすべて併合して連結成分数を数える

```js
const uf = new UnionFind(n)
rep(m, () => {
  const u = nextInt() - 1
  const v = nextInt() - 1
  uf.union(u, v)
})
let comp = 0
rep(n, (i) => {
  if (uf.find(i) === i) comp++
})
print(comp)
```

### `Fenwick`（BIT / フェニック木）

1 点加算・区間和が O(log n)。インデックスは 0-indexed、区間は半開区間 `[l, r)`。

```js
const bit = new Fenwick(n)
bit.add(i, x) // 位置 i に x を加算
bit.sum(r) // [0, r) の和
bit.rangeSum(l, r) // [l, r) の和
```

例: 転倒数（数列の逆順ペア数）

```js
const a = nextInts(n)
const bit = new Fenwick(n) // 値が 0..n-1 に正規化済みとする
let inv = 0
rep(n, (i) => {
  inv += i - bit.sum(a[i] + 1) // 既出のうち a[i] より大きい個数
  bit.add(a[i], 1)
})
print(inv)
```

> 総和が 2^53 を超える場合は `tree` を `BigInt` ベースに変えてください。

### `SegTree`（セグメント木 / モノイド）

1 点更新・区間クエリが O(log n)。`op`（結合的な二項演算）と `e`（単位元）を渡します。区間は半開区間 `[l, r)`。

```js
// 区間最大値
const seg = new SegTree(n, (a, b) => Math.max(a, b), -Infinity)
// 区間和
const seg2 = new SegTree(n, (a, b) => a + b, 0)
// 区間 GCD
const gcd = (a, b) => (b ? gcd(b, a % b) : a)
const seg3 = new SegTree(n, gcd, 0)

seg.set(i, x) // 位置 i を x に更新
seg.get(i) // 位置 i の値
seg.prod(l, r) // [l, r) に op を適用した結果
```

例: 配列を載せて区間最大値を答える

```js
const a = nextInts(n)
const seg = new SegTree(n, (x, y) => Math.max(x, y), -Infinity)
rep(n, (i) => seg.set(i, a[i]))
rep(q, () => {
  const l = nextInt() - 1
  const r = nextInt() // [l, r)
  print(seg.prod(l, r))
})
```

---

## minify（提出前の短縮）

```bash
pnpm mini <問題番号>          # terser で minify（元ファイルを上書き、バックアップ作成）
pnpm mini:restore <問題番号> <番号>  # バックアップから復元
```

詳細は [README.md](README.md) を参照。
