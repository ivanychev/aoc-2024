import Algorithms


struct Point: Equatable {
  let x: Int
  let y: Int
  
  static func zero() -> Point {
    Point(x: 0, y: 0)
  }
  
func step(_ delta: Delta) -> Point {
    Point(x: x + delta.dx, y: y + delta.dy)
  }
}

struct Delta: Equatable, Hashable {
  let dx: Int
  let dy: Int
  
  func opposite() -> Delta {
    Delta(dx: -dx, dy: -dy)
  }
}

struct FieldTraverseIterator: IteratorProtocol {
  let traverser: FieldTraverser
  let startPoints: [Point]
  var startPointIdx: Int
  
  init(traverser: FieldTraverser) {
    self.traverser = traverser
    self.startPoints = FieldTraverseIterator.getStartPoints(
      dx: traverser.delta.dx, dy: traverser.delta.dy, xRange: traverser.xRange, yRange: traverser.yRange)
    self.startPointIdx = 0
  }
  
  private static func getStartPoints(dx: Int, dy: Int, xRange: Range<Int>, yRange: Range<Int>) -> [Point] {
    var startPoints = [Point]()
    if dx != 0 {
      startPoints.append(contentsOf: yRange.map(
        {Point(x: 0, y: $0)}
      ))
    }
    if dy != 0 {
      var y0 = 0
      if abs(dy) > 0 && dy == -dx {
        y0 = yRange.upperBound - 1
      }
      let addPoints = xRange.map(
        {Point(x: $0, y: y0)}
      )
      if startPoints.first == Point.zero() {
        startPoints.append(contentsOf: addPoints[1...])
      } else {
        startPoints.append(contentsOf: addPoints)
      }
    }
    
    return startPoints
  }
  
  mutating func next() -> Array<Point>? {
    guard startPointIdx < startPoints.count else { return nil }
    defer {
      startPointIdx += 1
    }
    var points = [startPoints[startPointIdx]]
    var stepDelta = traverser.delta
    var opposite = false
    if !traverser.nextPointIsInField(points.last!, step: stepDelta) {
      stepDelta = stepDelta.opposite()
      opposite = true
    }
    if !traverser.nextPointIsInField(points.last!, step: stepDelta) {
      return points
    }
    while traverser.nextPointIsInField(points.last!, step: stepDelta) {
      points.append(points.last!.step(stepDelta))
    }
    if opposite {
      points = points.reversed()
    }
    return points
  }
  
}

class FieldTraverser: Sequence {
  let xRange: Range<Int>
  let yRange: Range<Int>
  let delta: Delta
  
  init(xRange: Range<Int>, yRange: Range<Int>, delta: Delta) {
    self.xRange = xRange
    self.yRange = yRange
    self.delta = delta
  }
  
  func nextPointIsInField(_ point: Point, step: Delta) -> Bool {
    return xRange.contains(point.x + step.dx) && yRange.contains(point.y + step.dy)
  }

  
  func makeIterator() -> FieldTraverseIterator {
    FieldTraverseIterator(traverser: self)
  }
}

struct Day04: AdventDay {
  // Save your data in a corresponding text file in the `Data` directory.
  var data: String
  var rows: [[Character]] { data.components(separatedBy: "\n").filter({$0.count > 0}).map({Array($0)}) }
  
  func pointArrayToString(_ points: [Point]) -> String {
    String(points.map({rows[$0.y][$0.x]}))
  }


  // Replace this with your solution for the first part of the day's challenge.
  func part1() -> Any {
    
    let xmasPattern = /XMAS/
    var total = 0
    
    var deltas = [Delta]()
    for dx in [-1, 0, 1] {
      for dy in [-1, 0, 1] {
        if dy == 0 && dx == 0 { continue }
        deltas.append(Delta(dx: dx, dy: dy))
      }
    }
    
    var deltaToCount = [Delta:Int]()
    
    for delta in deltas {
      let field = FieldTraverser(xRange: 0..<rows[0].count, yRange: 0..<rows.count, delta: delta)
      for pointArray in field {
        let line = pointArrayToString(pointArray)
        let matchCount = line.matches(of: xmasPattern).count
        
        total += matchCount
        deltaToCount[delta, default: 0] += matchCount
      }
    }
    
    return total
  }
  
  func isXmas2At(_ point: Point) -> Bool {
    if rows[point.y + 1][point.x + 1] != "A" {
      return false
    }
    
    if !((rows[point.y][point.x] == "M" && rows[point.y + 2][point.x + 2] == "S") ||
         (rows[point.y][point.x] == "S" && rows[point.y + 2][point.x + 2] == "M")) {
      return false
    }
    if !((rows[point.y + 2][point.x] == "M" && rows[point.y][point.x + 2] == "S") ||
         (rows[point.y + 2][point.x] == "S" && rows[point.y][point.x + 2] == "M")) {
      return false
    }
    
    return true
  }
  
  
  func part2() -> Any {
    var totalXmas = 0
    
    for y in 0..<(rows.count - 2) {
      for x in 0..<(rows[0].count - 2) {
        if isXmas2At(Point(x: x, y: y)) {
          totalXmas += 1
        }
      }
    }
    return totalXmas
  }
  
  
}
