# host-switch-graph-aspl
For a given host-switch graph, compute host-to-host diameter (h-diameter) and host-to-host average shortest path length (h-ASPL).

## Example
```
$ ruby host-switch-graph.rb example.edges
# of host, # of switch, radix: 80 41 6
5
4.472151898734177
```

## Graph file format
1st line: three numbers; the number of hosts, the number of switches, and the number of ports per switch
other lines: a edge defined by a pair of node number

## Features
- Ruby script (easy to run).
- Quite slower than [C++ program written by Ryota Yasudo](https://github.com/r-ricdeau/host-switch-aspl)

## Links
[Graph Golf 2021](http://research.nii.ac.jp/graphgolf/) for host-switch graph.
