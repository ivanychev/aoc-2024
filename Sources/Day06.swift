import Algorithms

enum Tile: Character {
  case FREE = "."
  case OBSTACLE = "#"
}

enum StepResult {
  case STEPPED
  case TURNED
  case REACHED_END_OF_MAP
  case CYCLE_DETECTED
}


class Field {
  var tiles: [[Tile]]
  
  init(tiles: [[Tile]]) {
    self.tiles = tiles
  }
  
  static func fromChars(_ chars: [[Character]]) -> Field {
    Field(tiles: chars.map {
      $0.map({Tile(rawValue:$0 == "^" ? ".": $0)!})
    })
  }
  
  func contains(_ point: Point) -> Bool {
    tiles.indices.contains(point.y) && tiles[0].indices.contains(point.x)
  }
  
  func tileAt(_ point: Point) -> Tile {
    tiles[point.y][point.x]
  }
}

class Guard {
  let field: Field
  var coordinates: Point
  var direction: Delta
  var visited: Set<Point>
  var visitedWithDirection: Set<DirectedPoint>
  
  init(field: Field, coordinates: Point, direction: Delta) {
    self.field = field
    self.coordinates = coordinates
    self.direction = direction
    self.visited = [coordinates]
    self.visitedWithDirection = [DirectedPoint(point: coordinates, direction: direction)]
  }
  
  func step() -> StepResult {
    let nextCoordinates = coordinates.step(direction)
    if !field.contains(nextCoordinates) {
      return .REACHED_END_OF_MAP
    }
    if field.tileAt(nextCoordinates) == .OBSTACLE {
      self.direction = self.direction.turnClockwise()
      let (inserted, _) = self.visitedWithDirection.insert(DirectedPoint(point: self.coordinates, direction: direction))
      return inserted ? .TURNED: .CYCLE_DETECTED
    }
    self.coordinates = nextCoordinates
    self.visited.insert(nextCoordinates)
    
    let (inserted, _) = self.visitedWithDirection.insert(DirectedPoint(point: nextCoordinates, direction: direction))
    return inserted ? .STEPPED: .CYCLE_DETECTED
  }
}


struct Day06: AdventDay {
  // Save your data in a corresponding text file in the `Data` directory.
  var data: String
  var rows: [[Character]] { data.components(separatedBy: "\n").filter({$0.count > 0}).map({Array($0)}) }
  var field: Field { Field.fromChars(rows) }
  var startCoord: Point {
    let directionRow = rows.enumerated().filter {
      pair in
      pair.element.contains("^")
    }
    .first!
    
    let y = directionRow.offset
    
    let x = directionRow.element.firstIndex(of: "^")!
    return Point(x: x, y: y)
  }
  
  func getVisitedPoints(_ field: Field) -> (StepResult, Set<Point>) {
    let g = Guard(field: field, coordinates: startCoord, direction: DELTA_UP)
    var stepResult: StepResult = .STEPPED
    while stepResult != .REACHED_END_OF_MAP && stepResult != .CYCLE_DETECTED {
      stepResult = g.step()
    }
    return (stepResult, g.visited)
  }

  // Replace this with your solution for the first part of the day's challenge.
  func part1() -> Any {
    let myField = field
    return getVisitedPoints(myField).1.count
  }

  func part2() -> Any {
    let myField = field
    var candidates = getVisitedPoints(myField).1
    
    candidates.remove(startCoord)
    var total = 0
    print("Found \(candidates.count) candidates")
    
    for (idx, candidate) in candidates.enumerated() {
      if candidate.y == 6 && candidate.x == 3 {
        print("here")
      }
      myField.tiles[candidate.y][candidate.x] = .OBSTACLE
      total += getVisitedPoints(myField).0 == .CYCLE_DETECTED ? 1 : 0
      myField.tiles[candidate.y][candidate.x] = .FREE
    }
    return total
  }
}
