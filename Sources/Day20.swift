import Algorithms

fileprivate class RaceField {
  var tiles: [[Character]]
  let start: Point
  let end: Point
  var cheat: Cheat?
  
  init(tiles: [[Character]], start: Point, end: Point) {
    self.tiles = tiles
    self.start = start
    self.end = end
  }
  
  func isEmptyTile(_ point: Point) -> Bool {
    tiles.indices.contains(point.y) && tiles[0].indices.contains(point.x) && tiles[point.y][point.x] == "."
  }
  
  func getNeighbors(_ p: Point) -> [Point] {
    [
      p.up(),
      p.down(),
      p.left(),
      p.right(),
    ].filter(isEmptyTile)
  }
  
  func filterCoords(predicate: (Point, Character) -> Bool) -> [Point] {
    tiles.enumerated().flatMap {
      rowAndY in
      rowAndY.element.enumerated().flatMap {
        elemAndX in
        let point = Point(x: elemAndX.offset, y: rowAndY.offset)
        if predicate(point, tiles[rowAndY.offset][elemAndX.offset]) {
          return [point]
        } else {
          return []
        }
      }
    }
  }
  
  func getWallCoords() -> [Point] {
    filterCoords {
      (point, char) in char == "#"
    }
  }
  
  func getEmptyCoords() -> [Point] {
    filterCoords {
      (point, char) in char == "."
    }
  }
  
  static func fromChars(_ chars: [[Character]]) -> RaceField {
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
    return RaceField(tiles: tiles, start: start!, end: end!)
  }
  
  func getDuration() -> Int {
    var queue = Deque<(pos:Point, cost:Int, usedCheat:Bool)>([(pos:start, cost:0, usedCheat:false)])
    var visited: Set<Point> = []
    while !queue.isEmpty {
      let current = queue.removeFirst()
      if current.pos == end { return current.cost }
      let res = visited.insert(current.pos)
      guard res.inserted else { continue }
      for n in getNeighbors(current.pos) {
        queue.append( (n, current.cost + 1, current.usedCheat) )
      }
      if cheat != nil && current.usedCheat == false && current.pos == cheat!.from {
        queue.append((cheat!.to, current.cost + cheat!.cost(), true))
      }
    }
    fatalError("Unreachable")
  }
  
  func getDurationWithCheat(_ c: Cheat) -> Int {
    cheat = c
    let dur = getDuration()
    cheat = nil
    return dur
  }
}

fileprivate struct Cheat {
  let from: Point
  let to: Point
  
  func cost() -> Int {
    from.manhattanDistance(to: to)
  }
}

fileprivate struct CheatGenerator: Sequence, IteratorProtocol {
  let spaces: [Point]
  let maxDistance: Int
  let windowSeq: any Sequence<Cheat>
  var windowIter: any IteratorProtocol<Cheat>
  
  init(spaces: [Point], maxDistance: Int) {
    self.spaces = spaces
    self.maxDistance = maxDistance
    self.windowSeq = spaces.combinations(ofCount: 2).lazy.filter {
      combination in
      let dist = combination[0].manhattanDistance(to: combination[1])
      return 0 < dist && dist <= maxDistance
    }.flatMap {
      combination in
      [
        Cheat(from: combination[0], to: combination[1]),
        Cheat(from: combination[1], to: combination[0]),
      ]
    }
    self.windowIter = windowSeq.makeIterator()
  }
  
  mutating func next() -> Cheat? {
    windowIter.next()
  }
  
}

struct Day20: AdventDay {
  // Save your data in a corresponding text file in the `Data` directory.
  var data: String
  var rows: [[Character]] { data.components(separatedBy: "\n").filter({$0.count > 0}).map({Array($0)}) }

  fileprivate func getSizeGen(_ gen: CheatGenerator) -> Int {
    gen.count { e in true }
  }
  
  // Replace this with your solution for the first part of the day's challenge.
  func part1() -> Any {
    let field = RaceField.fromChars(rows)
    let baseResult = field.getDuration()
    let size = getSizeGen(CheatGenerator(spaces: field.getEmptyCoords(), maxDistance: 2))
    print("Size of gen: \(size)")
    let cheatGenerator = CheatGenerator(spaces: field.getEmptyCoords(), maxDistance: 2)
    var iters = 0
    var total = 0
    for cheat in cheatGenerator {
      if iters % 100 == 0 { print("iteration: \(iters), completed: \(String(format: "%.2f", Double(iters) / Double(size) * 100))%") }
      iters += 1
      let result = field.getDurationWithCheat(cheat)
      if baseResult - result >= 100 {
        total += 1
      }
    }
    return total
  }

  func part2() -> Any {
    let field = RaceField.fromChars(rows)
    let baseResult = field.getDuration()
    let size = getSizeGen(CheatGenerator(spaces: field.getEmptyCoords(), maxDistance: 20))
    print("Size of gen: \(size)")
    let cheatGenerator = CheatGenerator(spaces: field.getEmptyCoords(), maxDistance: 20)
    var iters = 0
    var total = 0
    for cheat in cheatGenerator {
      if iters % 100 == 0 { print("iteration: \(iters), completed: \(String(format: "%.2f", Double(iters) / Double(size) * 100))%") }
      iters += 1
      let result = field.getDurationWithCheat(cheat)
      if baseResult - result >= 100 {
        total += 1
      }
    }
    return total
  }
}
