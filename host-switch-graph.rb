#!/usr/bin/ruby
# coding: utf-8

@n = 0 # ホスト数
@m = 0 # スイッチ数
@r = 0 # radix．スイッチのポート数（グラフの次数）
@e = []

@verbose = false
while ARGV.first == '-'
  opt = ARGV.shift
  @verbose = true if opt == '-v'
end

# グラフを読み込み
@fn = ARGV.first # グラフのファイル名
f = open(@fn)
@n, @m, @r = f.readline.chop.split(/\s+/).map { |s| s.to_i }
puts "# of host, # of switch, radix: #{@n} #{@m} #{@r}"

def addEdge(e, i, j, maxnode, maxdegree)
  if i >= maxnode || j >= maxnode
    puts "Too much nodes"
    puts "node: #{i} #{j}"
    exit
  end
  e[i] = [] if e[i] == nil
  e[j] = [] if e[j] == nil
  if e[i].index(j) == nil
    e[i] << j
    e[j] << i
  end
  if e[i].length > maxdegree || e[j].length > maxdegree
    puts "Too much edges"
    puts "e[#{i}] = #{e[i]}"
    puts "e[#{j}] = #{e[j]}"
    exit
  end
end

f.each { |l|
  i, j = l.split.map { |s| s.to_i }
  addEdge(@e, i, j, @n + @m, @r)
}

# スイッチごとのホスト数
@sh = (0...@m).map { 0 } # @sh[i - @n]: スイッチiのホスト数
(0...@n).each { |i|
  if @e[i].length > 1
    puts "ホストの次数が1を超えています"
    exit
  end
  @sh[@e[i].first - @n] += 1
}

# スイッチの次数を確認
ds = (@n...@n + @m).map { |i| @e[i].length }
puts "スイッチの次数: #{ds}" if @verbose
puts "スイッチの次数の最小，最大: #{ds.min} #{ds.max}" if @verbose
if ds.length > 0 && ds.max > @r
  puts "スイッチの次数が#{@r}を超えています"
  exit
end

# 平均パス長（h-ASPL）の計算

def aspl(e, n, m)
  removeHosts(e, n)
  diam = 0
  sum = 0
  (n...n + m).each { |i| # スイッチi
    dist = spl(e, i, n, m)[n...n + m]
    diam = [diam, dist.max + 2].max
    puts "スイッチ #{i}: #{dist.zip(@sh)}" if @verbose
    dist.zip(@sh).each { |dj, ns| # dj 距離, ns ホスト数
      if dj > 0
        sum += (dj + 2) * ns * @sh[i - n]
      else # 同じスイッチにつながっているホストペア（dj == 0）
        sum += (dj + 2) * ns * (ns - 1)
      end
    }
  }
  [diam, 1.0 * sum / n / (n - 1)]
end

## スイッチiから他のスイッチまでのパス長
def spl(e, i, n, m)
  # e ノードごとの枝のリスト
  # i スイッチの番号
  # n ホスト数
  # m スイッチ数
  dist = (0...n + m).to_a.map { n + m }
  dist[i] = 0
  dx = 1 # jsにあるノードはiからの距離がx
  js = e[i]
  while js.length > 0
    js2 = [] # jsに隣接するノード．次のjs
    js.each { |j| # 次のノード
      next if j < n # ホストは無視
      if dist[j] > dx
        dist[j] = dx
        js2 += e[j] # 重複するかもしれないけどそのまま
      end
    }
    dx += 1
    js = js2.uniq # 重複を削除
  end
  p [i, hist(dist[0...n])] if @verbose
  dist
end

## 距離ごとのノード数
def hist(dist)
  h = (0..dist.max).to_a.map { 0 }
  dist.each { |d|
    h[d] += 1
  }
  h
end

## スイッチからホストへの枝を削除
def removeHosts(e, n)
  (n...e.length).each { |i| # スイッチi
    e[i] = e[i].map { |j| # .sort.map { |j|
      if j < n
        nil
      else
        j
      end
    }.compact
  }
end

k, a = aspl(@e, @n, @m)
# puts "diam = #{k} aspl = #{a}"
puts [a, k]
