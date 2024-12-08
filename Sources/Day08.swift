import Algorithms

nonisolated(unsafe) fileprivate let antennaPattern = /[a-zA-Z0-9]/

fileprivate struct Antenna: Hashable {
  let value: Character
}

fileprivate enum AntennaTile: Hashable {
  case empty
  case antenna(_ antenna: Antenna)
  
  func isAntenna() -> Bool {
    switch self {
    case .antenna: return true
    default: return false
    }
  }
}

fileprivate class AntennaField {
  let tiles: [[AntennaTile]]
  let tileToPoints: [AntennaTile: [Point]]
  
  init(tiles: [[AntennaTile]], tileToPoints: [AntennaTile: [Point]]) {
    self.tiles = tiles
    self.tileToPoints = tileToPoints
  }
  
  static func fromChars(_ rows: [[Character]]) -> AntennaField {
    let tiles = rows.map {
      (row) in
      row.map {
        (char) in
        
        if let match = String(char).wholeMatch(of: antennaPattern) {
          return AntennaTile.antenna(Antenna(value: char))
        } else {
          return AntennaTile.empty
        }
      }
    }
    
    let tileToPoints = tiles.enumerated().flatMap {
      (y, row) in row.enumerated().filter({$1.isAntenna()}).map {
        (x, tile) in (tile, Point(x: x, y: y))
      }
    }.reduce(into: [AntennaTile: [Point]]()) {
      (m, pair) in
      m[pair.0, default: []].append(pair.1)
    }
    
    return AntennaField(tiles: tiles, tileToPoints: tileToPoints)
  }
  
  func isPointInField(_ point: Point) -> Bool {
    return tiles.indices.contains(point.y) && tiles[0].indices.contains(point.x)
  }
  
  func getAntiNodesOfPair(first: Point, second: Point) -> Array<Point> {
    let xDiff = first.x - second.x
    let yDiff = first.y - second.y
    
    let firstAntinode = Point(x: second.x + xDiff + xDiff, y: second.y + yDiff + yDiff)
    let secondAntinode = Point(x: second.x - xDiff, y: second.y - yDiff)
    return [firstAntinode, secondAntinode].filter(isPointInField)
  }
  
  func getAntiNodesOfPairPart2(first: Point, second: Point) -> Array<Point> {
    let xDiff = first.x - second.x
    let yDiff = first.y - second.y
    var antiNodes: Array<Point> = []
    
    var curr = second
    while isPointInField(curr) {
      antiNodes.append(curr)
      curr = curr.step(Delta(dx: xDiff, dy: yDiff))
    }
    
    curr = second.step(Delta(dx: -xDiff, dy: -yDiff))
    while isPointInField(curr) {
      antiNodes.append(curr)
      curr = curr.step(Delta(dx: -xDiff, dy: -yDiff))
    }
    return antiNodes
  }
}



struct Day08: AdventDay {
  // Save your data in a corresponding text file in the `Data` directory.
  var data: String
  var rows: [[Character]] { data.components(separatedBy: "\n").filter({$0.count > 0}).map({Array($0)}) }
  
  // Replace this with your solution for the first part of the day's challenge.
  func part1() -> Any {
    let field = AntennaField.fromChars(rows)
    var antiNodes = Set<Point>()
    for (tile, points) in field.tileToPoints {
      for pointPair in points.combinations(ofCount: 2) {
        antiNodes.formUnion(field.getAntiNodesOfPair(first: pointPair[0], second: pointPair[1]))
      }
    }
    
    return antiNodes.count
  }
  
  func part2() -> Any {
    let field = AntennaField.fromChars(rows)
    var antiNodes = Set<Point>()
    for (tile, points) in field.tileToPoints {
      for pointPair in points.combinations(ofCount: 2) {
        antiNodes.formUnion(field.getAntiNodesOfPairPart2(first: pointPair[0], second: pointPair[1]))
      }
    }
    
    return antiNodes.count
  }
}
