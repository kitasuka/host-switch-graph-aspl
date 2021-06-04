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

## ホストの次数を確認
ds = (0...@n).map { |i| @e[i].length }
puts "ホストの次数: #{ds}" if @verbose
if ds.min > 1
  puts "ホストの次数が1を超えています"
  exit
end

## スイッチの次数を確認
ds = (@n...@n + @m).map { |i| @e[i].length }
puts "スイッチの次数: #{ds}" if @verbose
puts "スイッチの次数の最小，最大: #{ds.min} #{ds.max}" if @verbose
if ds.length > 0 && ds.max > @r
  puts "スイッチの次数が#{@r}を超えています"
  exit
end

# 平均パス長
def aspl(e, n, m)
  # e ノードごとの枝のリスト
  # n ホスト数
  # m スイッチ数
  dsum = 0
  diam = 0
  (0...n).each { |i| # このノードからの距離を調べる
    dist = (0...n + m).to_a.map { n + m }
    dist[i] = 0
    dx = 1 # jsにあるノードはiからの距離がx
    js = e[i]
    while js.length > 0
      js2 = [] # jsに隣接するノード．次のjs
      js.each { |j| # 次のノード
        if dist[j] > dx
          dist[j] = dx
          js2 += e[j] # 重複するかもしれないけどそのまま
        end
      }
      dx += 1
      js = js2
    end
    # p dist[0...h]
    p [i, hist(dist[0...n])] if @verbose
    dsum += dist[0...n].reduce(:+)
    diam = [diam, dist[0...n].max].max
  }
  [diam, 1.0 * dsum / n / (n - 1)]
end

# 距離ごとのノード数
def hist(dist)
  h = (0..dist.max).to_a.map { 0 }
  dist.each { |d|
    h[d] += 1
  }
  h
end

k, a = aspl(@e, @n, @m)
# puts "diam = #{k} aspl = #{a}"
puts [k, a]
