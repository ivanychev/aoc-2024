import Algorithms
import Collections


func readPoints(_ rows: [[Character]]) -> [Point] {
  rows
    .map {String($0)}
    .map {$0.components(separatedBy: ",").map {Int($0)!}}
    .map {Point(x: $0[0], y: $0[1])}
}

fileprivate class ByteField {
  let size: Int
  var corrupted: Set<Point> = []
  
  init(size: Int) {
    self.size = size
  }
  
  func addByte(_ p: Point) {
    corrupted.insert(p)
  }
  
  func isEmptyTile(_ p: Point) -> Bool {
    0 <= p.x && p.x < size && 0 <= p.y && p.y < size && !corrupted.contains(p)
  }
  
  func getNeighbors(_ p: Point) -> [Point] {
    [
      p.up(),
      p.down(),
      p.left(),
      p.right(),
    ].filter(isEmptyTile)
  }
  
  func getPathSize() -> Int? {
    let start = Point(x: 0, y: 0)
    let end = Point(x: size - 1, y: size - 1)
    if corrupted.contains(start) || corrupted.contains(end) {
      return nil
    }
    
    var visited = Set<Point>()
    var queue = Deque<(Point, Int)>([(start, 0)])
    while !queue.isEmpty {
      let cur = queue.removeFirst()
      if cur.0 == end { return cur.1 }
      let res = visited.insert(cur.0)
      if res.inserted == false { continue }
      for neighbour in getNeighbors(cur.0) {
        queue.append((neighbour, cur.1 + 1))
      }
    }
    return nil
  }
}

struct Day18: AdventDay {
  // Save your data in a corresponding text file in the `Data` directory.
  var data: String
  var rows: [[Character]] { data.components(separatedBy: "\n").filter({$0.count > 0}).map({Array($0)}) }

  // Replace this with your solution for the first part of the day's challenge.
  func part1() -> Any {
    let points = readPoints(rows)
    let field = ByteField(size: 71)
    for i in 0..<1024 {
      field.addByte(points[i])
    }
    
    return field.getPathSize()!
  }

  func part2() -> Any {
    let points = readPoints(rows)
    let field = ByteField(size: 71)
    for i in 0...Int.max {
      if i % 100 == 0 {
        print("Iteration \(i)")
      }
      field.addByte(points[i])
      if field.getPathSize() == nil {
        return points[i]
      }
    }
    fatalError("Unreacheable")
  }
}
