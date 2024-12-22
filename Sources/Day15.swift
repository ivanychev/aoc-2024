import Algorithms
import Collections

fileprivate enum SubFieldTile: Character {
  case WALL = "#"
  case OPEN = "."
}

let SUB: Character = "@"
let EMPTY_RILES: Array<Character> = ["O", "[", "]", ".", "@"]

fileprivate func readCommands(_ raw: String) -> [Delta] {
  raw.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "\n", with: "").map {
    char in
    switch char {
    case "^": return .up()
    case "v": return .down()
    case "<": return .left()
    case">": return .right()
    default : assert(false, "Unknown command \(char)")
    }
    return .up()
  }
}

fileprivate struct Box {
  let width: Int
}

fileprivate class SubField {
  var tiles: [[SubFieldTile]]
  var subCoord: Point
  var boxes: [Point: Box]
  
  init(tiles: [[SubFieldTile]], subCoord: Point, boxes: [Point: Box]) {
    self.tiles = tiles
    self.subCoord = subCoord
    self.boxes = boxes
  }
  
  func boxAt(_ coord: Point) -> (Point, Box)? {
    var box = boxes[coord]
    if box != nil { return (coord, box!) }
    box = boxes[coord.left()]
    return box != nil && box?.width == 2 ? (coord.left(), box!) : nil
  }
  
  static func fromRawField(_ field: String) -> SubField {
    var coord: Optional<Point> = nil
    var boxes: [Point: Box] = [:]
    let tiles = field.split(separator: "\n").filter({$0.count > 0}).enumerated().map {
      let yCoord = $0.offset
      return $0.element.enumerated().map { pair in
        let rawTile = pair.element
        let currentPoint = Point(x: pair.offset, y: yCoord)
        switch rawTile {
        case "@":
          coord = currentPoint
        case "O":
          boxes[currentPoint] = Box(width: 1)
        case "[":
          boxes[currentPoint] = Box(width: 2)
        default:
          break
        }
        return EMPTY_RILES.contains(rawTile) ? SubFieldTile.OPEN : SubFieldTile.WALL
      }
    }
    return SubField(tiles: tiles, subCoord: coord!, boxes:boxes)
  }
  
  static func fromRawFieldDoubled(_ field: String) -> SubField {
    var coord: Optional<Point> = nil
    var boxes: [Point: Box] = [:]
    let tiles = field.split(separator: "\n").filter({$0.count > 0}).enumerated().map {
      let yCoord = $0.offset
      return $0.element.enumerated().flatMap { pair in
        let rawTile = pair.element
        let currentPoint = Point(x: pair.offset * 2, y: yCoord)
        switch rawTile {
        case "@":
          coord = currentPoint
        case "O":
          boxes[currentPoint] = Box(width: 2)
        default:
          break
        }
        return EMPTY_RILES.contains(rawTile) ? [SubFieldTile.OPEN, SubFieldTile.OPEN] : [SubFieldTile.WALL, SubFieldTile.WALL]
      }
    }
    return SubField(tiles: tiles, subCoord: coord!, boxes:boxes)
  }
  
  
  func isInsideField(_ p: Point) -> Bool {
    tiles.indices.contains(p.y) && tiles[0].indices.contains(p.x)
  }
  
  func at(_ p: Point) -> SubFieldTile {
    assert(isInsideField(p))
    return tiles[p.y][p.x]
  }
  
  func getDirectionUntilSpace(_ direction: Delta) -> [Point]? {
    var cur = [subCoord.step(direction)]
    if !isInsideField(cur.last!) { return nil }
    while isInsideField(cur.last!) && at(cur.last!) != .WALL && at(cur.last!) != .OPEN {
      cur.append(cur.last!.step(direction))
    }
    
    if !isInsideField(cur.last!) || at(cur.last!) == .WALL { return nil }
    return cur
  }
  
  func swapTiles(_ first: Point, _ second: Point) {
    let temp = tiles[first.y][first.x]
    tiles[first.y][first.x] = tiles[second.y][second.x]
    tiles[second.y][second.x] = temp
  }
  
  func getOffsetTiles(_ boxAt: Point, _ direction: Delta) -> [Point] {
    let boxPoints = (0..<boxes[boxAt]!.width).map {
      boxAt.step(Delta(dx: $0, dy: 0))
    }
    return boxPoints.map{ $0.step(direction) }.filter{!boxPoints.contains($0)}
  }
  
  func isBoxMovable(_ boxAt: Point, _ direction: Delta) -> Bool {
    return getOffsetTiles(boxAt, direction).allSatisfy { isInsideField($0) && at($0) == .OPEN }
  }
  
  func neighbourBoxes(_ at: Point, _ direction: Delta) -> [Point] {
    getOffsetTiles(at, direction).flatMap {
      if let pair = boxAt($0) {
        return [pair.0]
      } else {
        return [Point]()
      }
    }
  }
  
  func executeCommand(_ command: Delta) {
    //    if let direction = getDirectionUntilSpace(command) {
    //      direction.windows(ofCount: 2).reversed().forEach {
    //        pair in
    //        swapTiles(pair.first!, pair.last!)
    //      }
    //      subCoord = subCoord.step(command)
    //    }
    let newCoord = subCoord.step(command)
    if !isInsideField(newCoord) || at(newCoord) == .WALL {
      return
    }
    if let adjacentBox = boxAt(newCoord) {
      var adjacentBoxes: Set<Point> = []
      var deque: Deque<Point> = [adjacentBox.0]
      while !deque.isEmpty {
        let currentBox = deque.removeFirst()
        let result = adjacentBoxes.insert(currentBox)
        if !result.inserted {continue}
        neighbourBoxes(currentBox, command).forEach {
          if !adjacentBoxes.contains($0) {
            deque.append($0)
          }
        }
      }
      let allMovable = adjacentBoxes.allSatisfy {isBoxMovable($0, command)}
      if !allMovable {
        return
      }
      let updatedBoxesMap = boxes.filter{adjacentBoxes.contains($0.key)}.reduce(into: [Point:Box]()) {
        m, pair in
        m[pair.key.step(command)] = pair.value
      }
      adjacentBoxes.forEach {
        boxes.removeValue(forKey: $0)
      }
      boxes.merge(updatedBoxesMap, uniquingKeysWith: {cur, _ in cur})
      subCoord = newCoord
      
    } else {
      subCoord = newCoord
    }
  }
  
  func gpsTotal(_ p: Point) -> Int {
    return p.y * 100 + p.x
  }
  
  func getBoxCoords() -> [Point] {
    Array(boxes.keys)
  }
  
  func render() -> String {
    var rawTiles = tiles.enumerated().map { row in
      let y = row.offset
      let chars = row.element.enumerated().map {
        pair in
        let x = pair.offset
        let currentPoint = Point(x: x, y: y)
        if subCoord == currentPoint {
          return Character("@")
        }
        return at(currentPoint).rawValue
      }
      return chars
    }
    
    boxes.forEach { key, value in
      if value.width == 1 {
        rawTiles[key.y][key.x] = "0"
      } else {
        rawTiles[key.y][key.x] = "["
        rawTiles[key.y][key.x + 1] = "]"
      }
    }
    return rawTiles.map{String($0)}.joined(separator: "\n")
  }
}

struct Day15: AdventDay {
  // Save your data in a corresponding text file in the `Data` directory.
  var data: String
  var rawComponents: [String] { data.components(separatedBy: "\n\n").filter({$0.count > 0}).map({String($0)}) }
  
  // Replace this with your solution for the first part of the day's challenge.
  func part1() -> Any {
    let field = SubField.fromRawField(rawComponents[0])
    let commands = readCommands(rawComponents[1])
    //    print(field.render())
    //    print("Initial")
    var steps = 0
    for command in commands {
      field.executeCommand(command)
      steps += 1
      //      print(field.render())
      //      print("After step \(steps)")
    }
    return field.getBoxCoords().map {field.gpsTotal($0)}.reduce(0, +)
  }
  
  func part2() -> Any {
    let field = SubField.fromRawFieldDoubled(rawComponents[0])
    let commands = readCommands(rawComponents[1])
    //    print(field.render())
    //    print("Initial")
    var steps = 0
    for command in commands {
      field.executeCommand(command)
      steps += 1
      //      print(field.render())
      //      print("After step \(steps)")
    }
    return field.getBoxCoords().map {field.gpsTotal($0)}.reduce(0, +)
  }
}
