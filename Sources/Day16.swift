import Algorithms
import Collections

let DIRECTIONS: [Delta] = [
  .right(), .up(), .left(), .down()
]

fileprivate struct Node: Hashable {
  let pos: Point
  let directionIdx: Int // 0..<4
}

fileprivate class DeerFieldDjikstra {
  let field: DeerField
  let nodes: Set<Node>
  var previous: [Node: Node]
  var distances: [Node: Int]
  var queue: Set<Node>
  let startNode: Node
  
  init(field: DeerField) {
    self.field = field
    self.nodes = Set(field.getNodes())
    print("Seen \(self.nodes.count) nodes")
    self.startNode = Node(pos: field.start, directionIdx: 0)
    self.previous = [:]
    self.distances = nodes.reduce(into: [Node:Int]()) {
      (acc, node) in
      acc[node] = Int.max
    }
    self.distances[self.startNode] = 0
    self.queue = Set(self.nodes)
  }
  
  func neighboursOf(_ node: Node, opposite: Bool = false) -> [Node] {
    let nextPoint = node.pos.step(DIRECTIONS[(node.directionIdx + (opposite ? 2 : 0)) % DIRECTIONS.count])
    var neighbours: [Node] = (0..<DIRECTIONS.count).filter {
      $0 != node.directionIdx
    }.map {
      Node(pos: node.pos, directionIdx: $0)
    }
    
    let nodeInSameDirection = Node(pos: nextPoint, directionIdx: node.directionIdx)
    if nodes.contains(nodeInSameDirection) {
      neighbours.append(nodeInSameDirection)
    }
    return neighbours
  }
  
  func distanceBetween(_ node1: Node, _ node2: Node) -> Int {
    assert(node1.pos == node2.pos && node1.directionIdx != node2.directionIdx || node1.directionIdx == node2.directionIdx && node1.pos.manhattanDistance(to: node2.pos) == 1)
    if node1.directionIdx == node2.directionIdx {
      return 1
    }
    
    if DIRECTIONS[node1.directionIdx].isOpposite(DIRECTIONS[node2.directionIdx]) {
      return 2000
    }
    return 1000
  }
  
  func build() {
    var iters = 0
    while self.queue.count > 0 {
      let minNode = self.queue.min(by: {
        node1, node2 in
        self.distances[node1]! < self.distances[node2]!
      })!
      self.queue.remove(minNode)
      iters += 1
      if iters % 100 == 0 {
        print("Passed \(iters) iterations")
      }
      
      let neighboursStillInQueue = neighboursOf(minNode).filter { self.queue.contains($0) }
      for n in neighboursStillInQueue {
        let newDistance = self.distances[minNode]! + distanceBetween(minNode, n)
        if newDistance < self.distances[n]! {
          self.distances[n] = newDistance
          self.previous[n] = minNode
        }
      }
    }
  }
  
  func isOptimallyDecreasing(_ node1: Node, _ distance1: Int, _ node2: Node, _ distance2: Int) -> Bool {
    if node1.directionIdx == node2.directionIdx {
      return distance1 - distance2 == 1
    } else if DIRECTIONS[node1.directionIdx].isOpposite(DIRECTIONS[node2.directionIdx]) {
      return distance1 - distance2 == 2000
    }
    return distance1 - distance2 == 1000
  }
  
  func getOptimalNodes() -> Set<Node> {
    let nodeToDistances = endingDistances()
    let minDistance = nodeToDistances.values.min()!
    let optimalEndingNodes = nodeToDistances.filter {
      $0.value == minDistance
    }.map {
      $0.key
    }
    
    var optimalNodes = Set<Node>()
    
    for on in optimalEndingNodes {
      var queue = Deque<Node>([on])
      var visited = Set<Node>()
      while !queue.isEmpty {
        let current = queue.removeFirst()
        let result = visited.insert(current)
        if !result.inserted {
          continue
        }
        let neighbours = neighboursOf(current, opposite: true)
        for neighbour in neighbours {
          if !visited.contains(neighbour) && isOptimallyDecreasing(current, self.distances[current]!, neighbour, self.distances[neighbour]!) {
            queue.append(neighbour)
          }
        }
      }
      optimalNodes.formUnion(visited)
    }
    
    return optimalNodes
  }
  
  func endingDistances() -> [Node: Int] {
    (0..<DIRECTIONS.count).map { Node(pos: field.end, directionIdx: $0)}.reduce(into: [:], {
      (acc, node) in
      acc[node] = self.distances[node]
    })
  }
}

fileprivate class DeerField {
  let tiles: [[Character]]
  let start: Point
  let end: Point
  
  func getNodes() -> [Node] {
    tiles.enumerated().flatMap { rowAndY in
      rowAndY.element.enumerated().flatMap { tileAndX in
        if tileAndX.element == "." {
          return (0..<DIRECTIONS.count).map { directionIdx in
            Node(pos: Point(x: tileAndX.offset, y: rowAndY.offset), directionIdx: directionIdx)
          }
        } else {
          return [Node]()
        }
      }
    }
  }
  
  init(tiles: [[Character]], start: Point, end: Point) {
    self.tiles = tiles
    self.start = start
    self.end = end
  }
  
  static func fromChars(_ chars: [[Character]]) -> DeerField {
    var start: Point?
    var end: Point?
    let tiles = chars.enumerated().map {
      rowAndY in
      rowAndY.element.enumerated().map {
        tileAndX in
        if tileAndX.element == "S" {
          start = Point(x: tileAndX.offset, y: rowAndY.offset)
          return Character(".")
        } else if tileAndX.element == "E" {
          end = Point(x: tileAndX.offset, y: rowAndY.offset)
          return Character(".")
        }
        return tileAndX.element
      }
    }
    return DeerField(tiles: tiles, start: start!, end: end!)
  }
  
  
}

struct Day16: AdventDay {
  // Save your data in a corresponding text file in the `Data` directory.
  var data: String
  var chars: [[Character]] { data.components(separatedBy: "\n").filter({$0.count > 0}).map({Array($0)}) }
  
  // Replace this with your solution for the first part of the day's challenge.
  func part1() -> Any {
    let field = DeerField.fromChars(chars)
    let djkstra = DeerFieldDjikstra(field: field)
    djkstra.build()
    return djkstra.endingDistances().values.min()!
  }
  
  func part2() -> Any {
    let field = DeerField.fromChars(chars)
    let djkstra = DeerFieldDjikstra(field: field)
    djkstra.build()
    let optimalPoints = djkstra.getOptimalNodes().map({$0.pos})
    return Set(optimalPoints).count
  }
}
