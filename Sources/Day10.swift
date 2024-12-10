import Algorithms
import Collections

fileprivate func isWalkStep(_ field: LavaField, _ currentPoint: Point, _ nextPoint: Point) -> Bool {
  let cur = field.tiles[currentPoint.y][currentPoint.x]
  let next = field.tiles[nextPoint.y][nextPoint.x]
  
  return next == cur + 1
}

fileprivate class LavaField {
  let tiles: [[Int]]
  
  init(rows: [[Character]]) {
    tiles = rows.map {
      $0.map {
        Int(String($0))!
      }
    }
  }
  
  func isInField(_ p: Point) -> Bool {
    return tiles.indices.contains(p.y) && tiles[0].indices.contains(p.x)
  }
  
  func getNeighbouringTiles(_ p: Point, _ predicate: (LavaField, Point, Point) -> Bool) -> [Point] {
     [
      p.step(DELTA_UP),
      p.step(DELTA_DOWN),
      p.step(DELTA_LEFT),
      p.step(DELTA_RIGHT)
    ].filter {
      isInField($0) && predicate(self, p, $0)
    }
  }
  
  func getStartingPositions() -> [Point] {
    tiles.enumerated().flatMap {
      (y, row) in
      row.enumerated().filter {
        (x, val) in
        val == 0
      }.map({
        (x, val) in
        Point(x: x, y: y)
      })
    }
  }
  
  func bfs(start: Point, predicate: (LavaField, Point, Point) -> Bool, visitor: (LavaField, Point) -> ()) {
    var deque = Deque([start])
    
    while !deque.isEmpty {
      let currentPoint = deque.removeFirst()
      visitor(self, currentPoint)
      let neighbours = getNeighbouringTiles(currentPoint, predicate)
      deque.prepend(contentsOf: neighbours)
    }
  }
}

struct Day10: AdventDay {
  // Save your data in a corresponding text file in the `Data` directory.
  var data: String
  var rows: [[Character]] { data.components(separatedBy: "\n").filter({$0.count > 0}).map({Array($0)}) }

  // Replace this with your solution for the first part of the day's challenge.
  func part1() -> Any {
    let field = LavaField(rows: rows)
    let startingPositions = field.getStartingPositions()
    var total = 0
    
    for pos in startingPositions {
      var encounteredEnds = Set<Point>()
      field.bfs(start: pos, predicate: isWalkStep, visitor: {
        (field, pos) in
        if field.tiles[pos.y][pos.x] == 9 {
          encounteredEnds.insert(pos)
        }
      })
      total += encounteredEnds.count
    }
    
    return total
  }

  func part2() -> Any {
    let field = LavaField(rows: rows)
    let startingPositions = field.getStartingPositions()
    var total = 0
    
    for pos in startingPositions {
      field.bfs(start: pos, predicate: isWalkStep, visitor: {
        (field, pos) in
        if field.tiles[pos.y][pos.x] == 9 {
          total += 1
        }
      })
    }
    
    return total
  }
}
