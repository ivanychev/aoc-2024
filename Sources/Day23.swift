import Algorithms

fileprivate struct NodeSet: Hashable {
  let nodes: [String]
  
  static func fromArray(_ nodes: [String]) -> NodeSet {
    NodeSet(nodes: nodes.sorted(by: {$0 < $1}))
  }
  
  func hasNode(_ node: String) -> Bool {
    nodes.contains(node)
  }
}

struct Day23: AdventDay {
  // Save your data in a corresponding text file in the `Data` directory.
  var data: String
  var rows: [[Character]] { data.components(separatedBy: "\n").filter({$0.count > 0}).map({Array($0)}) }

  func buildGraph() -> [String: Set<String>]{
    var graph = [String: Set<String>]()
    rows.forEach {
      let components = String($0).components(separatedBy: "-")
      graph[String(components[0]), default: Set<String>()].insert(String(components[1]))
      graph[String(components[1]), default: Set<String>()].insert(String(components[0]))
    }
    return graph
  }
  // Replace this with your solution for the first part of the day's challenge.
  func part1() -> Any {
    var graph = buildGraph()
    
    var set = Set<NodeSet>()
    for node in graph.keys {
      if !node.starts(with: /t/) {
        continue
      }
      for comb in graph[node]!.combinations(ofCount: 2) {
        if graph[comb[0]]!.contains(comb[1]) {
          set.insert(NodeSet.fromArray([node, comb[0], comb[1]]))
        }
      }
    }

    return set.count
  }
  
  

  func part2() -> Any {
    let graph = buildGraph()
    let isStronglyConnected = { (nodes: any Sequence<String>) in
      for node in nodes {
        for otherNode in nodes {
          if otherNode == node {
            continue
          }
          if !graph[node]!.contains(otherNode) {
            return false
          }
        }
      }
      return true
    }
    
    let nodes = Array(graph.keys)
    var nextStep = [3:Set<NodeSet>()]
    var known = 0
    for comb in nodes.combinations(ofCount: 3) {
      if isStronglyConnected(comb) {
        nextStep[3]!.insert(NodeSet.fromArray(comb))
      }
    }
    while nextStep[nextStep.keys.max()!]!.count > 0 {
      let currentCliqueSize = nextStep.keys.max()!
      print("Searching for cliques of size \(currentCliqueSize+1), we have \(nextStep[currentCliqueSize]!.count) cliques at \(currentCliqueSize)")
      nextStep[currentCliqueSize+1] = Set<NodeSet>()
      for clique in nextStep[currentCliqueSize]! {
        for node in graph.keys {
          if clique.hasNode(node) {
            continue
          }
          let candidate = clique.nodes + [node]
          if isStronglyConnected(candidate) {
            nextStep[currentCliqueSize+1]!.insert(NodeSet.fromArray(candidate))
          }
        }
      }
    }
    return nextStep[nextStep.keys.max()! - 1]!
  }
}
