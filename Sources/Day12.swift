import Algorithms
import Collections

// 830646 is too high

fileprivate struct Fence: Hashable, CustomStringConvertible {
  let from : Point
  let to: Point
  
  var description: String {
    "(\(from.x),\(from.y)) -> (\(to.x),\(to.y))"
  }
  
  init?(from: Point, to: Point) {
    if to != from.right() && to != from.down() {
      return nil
    }
    self.from = from
    self.to = to
  }
  
  func areOnStraight(_ other: Fence) -> Bool {
    var first = self
    var second = other
    if first.from == second.to {
      swap(&first, &second)
    }
    var onStraight = false
    if first.to != second.from {
      onStraight = false
    } else {
      onStraight = first.from.x == second.to.x || first.from.y == second.to.y
    }
    
    return onStraight
  }
  
  func orientation() -> Delta {
    if from.x == to.x {
      return DELTA_DOWN
    } else {
      return DELTA_RIGHT
    }
  }
  
  func getPossibleNeighbours() -> [Fence] {
    if to == from.right() {
      return [
        Fence(from: to.up(), to: to)!,
        Fence(from: to, to: to.right())!,
        Fence(from: to, to: to.down())!,
        Fence(from: from.up(), to: from)!,
        Fence(from: from, to: from.down())!,
        Fence(from: from.left(), to: from)!
      ]
    } else {
      return [
        Fence(from: from.left(), to: from)!,
        Fence(from: from.up(), to: from)!,
        Fence(from: from, to: from.right())!,
        Fence(from: to.left(), to: to)!,
        Fence(from: to, to: to.down())!,
        Fence(from: to, to: to.right())!,
      ]
    }
  }
}

extension Fence: Comparable {
  static func < (lhs: Fence, rhs: Fence) -> Bool {
    if lhs.from.x != rhs.from.x {
      return lhs.from.x < rhs.from.x
    } else if lhs.from.y != rhs.from.y {
      return lhs.from.y < rhs.from.y
    } else {
      return true
    }
  }
}

fileprivate class GarderFieldComponent {
  let character: Character
  let field: GardenField
  let tiles: [Point]
  
  init(field: GardenField, tiles: [Point]) {
    self.character = field.at(tiles.first!)!
    self.field = field
    self.tiles = tiles
  }
  
  func findTileAdjacantToFence(_ fence: Fence) -> Point? {
    if fence.orientation() == DELTA_DOWN {
      if field.isInField(fence.from) && field.at(fence.from) == character {
        return fence.from
      } else if field.isInField(fence.from.left()) && field.at(fence.from.left()) == character{
        return fence.from.left()
      } else {
        return nil
      }
    } else {
      if field.isInField(fence.from) && field.at(fence.from) == character {
        return fence.from
      } else if field.isInField(fence.from.up()) && field.at(fence.from.up()) == character {
        return fence.from.up()
      } else {
        return nil
      }
    }
  }
  
  func isAdjacent(_ fence: Fence, _ tile: Point) -> Bool {
    switch fence.orientation() {
    case DELTA_DOWN:
      return tile == fence.from || tile == fence.from.left()
    case DELTA_RIGHT:
      return tile == fence.from || tile == fence.from.up()
    default:
      assert(false)
    }
  }
  
  func isAdjacent(_ first: Point, _ second: Point) -> Bool {
    return (first.x == second.x && abs(first.y - second.y) == 1) ||
    (first.y == second.y && abs(first.x - second.x) == 1)
  }
  
  func perimeter() -> Int {
    tiles.map {
      tile in
      let neighbours = field.getNeighbouringTiles(tile, { from, to in true })
      let edges = (4 - neighbours.count) + neighbours.filter {
        field.at( $0 ) != field.at(tile)
      }.count
      return edges
    }.reduce(0, +)
  }
  
  func fences() -> [Fence] {
    tiles.map {
      tile in
      var fences: Array<Fence> = [];
      
      if !field.isInField(tile.up()) || field.at(tile.up()) != field.at(tile) {
        fences.append(Fence(from: tile, to: tile.right())!)
      }
      if !field.isInField(tile.down()) || field.at(tile.down()) != field.at(tile) {
        fences.append(Fence(from: tile.down(), to: tile.down().right())!)
      }
      if !field.isInField(tile.left()) || field.at(tile.left()) != field.at(tile) {
        fences.append(Fence(from: tile, to: tile.down())!)
      }
      if !field.isInField(tile.right()) || field.at(tile.right()) != field.at(tile) {
        fences.append(Fence(from: tile.right(), to: tile.right().down())!)
      }
      return fences
    }.flatMap { fences in fences }
  }
  
  func price() -> Int {
    perimeter() * tiles.count
  }
  
  func findNextFence(fence: Fence, allFences: inout Set<Fence>) -> Fence? {
    let tile = findTileAdjacantToFence(fence)!
    
    let allNeighbours = allFences.intersection(fence.getPossibleNeighbours())
    var neighbours = allNeighbours.filter {
      (nextFence) in
      if nextFence.orientation() == fence.orientation() {
        let nextTile = findTileAdjacantToFence(nextFence)
        return nextTile.map {isAdjacent($0, tile)} ?? false
      }
      if isAdjacent(nextFence, tile) {
        return true
      }
      
      // BA
      // AA case
      let nextTile = findTileAdjacantToFence(nextFence)
      if nextTile == nil {
        return false
      }
      
      let possibleIntermediateTiles = [
        Point(x: nextTile!.x, y: tile.y),
        Point(x: tile.x, y: nextTile!.y),
      ]
      
      return (field.at(nextTile!) == field.at(tile)) &&
      !possibleIntermediateTiles.filter {field.at($0) == field.at(tile)}.isEmpty
    }
    
    return !neighbours.isEmpty ? neighbours.popFirst()! : nil;
  }
  
  func batchPrice() -> Int {
    var allFences = Set(fences())
    var currentFence = allFences.popFirst()!
    var straightsArchive = Array<Array<Array<Fence>>>()
    var straights = [Array<Fence>([currentFence])];
    var totalStraights = 0
    
    let updateStraights = {
      if straights[0][0].areOnStraight(straights[straights.count - 1].last!) {
        straights[0].append(contentsOf: straights[straights.count - 1])
        straights.removeLast()
      }
      totalStraights += straights.count
      straightsArchive.append(straights)
      straights = [Array<Fence>([currentFence])]
    }
    
    while !allFences.isEmpty {
      let nextFence: Fence? = findNextFence(
        fence: currentFence,
        allFences: &allFences
      )
      if nextFence == nil {
        currentFence = allFences.popFirst()!
        updateStraights()
        continue
      }
      
      allFences.remove(nextFence!)
      if nextFence!.orientation() == currentFence.orientation() {
        straights[straights.count - 1].append(nextFence!)
      } else {
        straights.append(Array<Fence>([nextFence!]))
      }
      currentFence = nextFence!
    }
    
    updateStraights()
    let tilesCount = tiles.count
    return totalStraights * tilesCount
  }
}


fileprivate class GardenField {
  let rows: [[Character]]
  
  init(rows: [[Character]]) {
    self.rows = rows
  }
  
  func isInField(_ p: Point) -> Bool {
    rows.indices.contains(p.y) && rows[0].indices.contains(p.x)
  }
  
  func at(_ p: Point) -> Character? {
    rows[p.y][p.x]
  }
  
  func getNeighbouringTiles(_ p: Point, _ predicate: (Point, Point) -> Bool) -> [Point] {
    [
      p.up(),
      p.down(),
      p.left(),
      p.right()
    ].filter {
      isInField($0) && predicate(p, $0)
    }
  }
  
  func bfs(_ start: Point) -> Set<Point> {
    var queue = Deque([start])
    var visited = Set<Point>()
    while !queue.isEmpty {
      let p = queue.removeFirst()
      guard !visited.contains(p) else { continue }
      let result = visited.insert(p)
      if !result.inserted {
        continue
      }
      
      queue.append(contentsOf: getNeighbouringTiles(p){ from, to in
        at(from) == at(to)
      }.filter{!visited.contains($0)})
    }
    return visited
  }
  
  func findComponents() -> [GarderFieldComponent] {
    var visited = Set<Point>()
    var components = [GarderFieldComponent]()
    
    for y in 0..<rows.count {
      for x in 0..<rows[y].count {
        let p = Point(x: x, y:y)
        guard !visited.contains(p) else { continue }
        let component = bfs(p)
        components.append(GarderFieldComponent(field: self, tiles: Array(component)))
        visited.formUnion(component)
      }
    }
    return components
  }
}

struct Day12: AdventDay {
  // Save your data in a corresponding text file in the `Data` directory.
  var data: String
  var rows: [[Character]] { data.components(separatedBy: "\n").filter({$0.count > 0}).map({Array($0)}) }
  
  // Replace this with your solution for the first part of the day's challenge.
  func part1() -> Any {
    let field = GardenField(rows: rows)
    let components = field.findComponents()
    
    return components.map({$0.price()}).reduce(0, +)
  }
  
  func part2() -> Any {
    let field = GardenField(rows: rows)
    let components = field.findComponents()
    
    return components.map({$0.batchPrice()}).reduce(0, +)
  }
}
