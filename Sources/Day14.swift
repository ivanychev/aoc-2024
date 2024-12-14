import Algorithms
import Foundation


fileprivate func mathMod(_ a: Int, _ b: Int) -> Int {
  let res = a % b
  return res < 0 ? res + b : res
}

fileprivate struct RobotReader {
  let pattern = /p=([-+]?\d+),([-+]?\d+) v=([-+]?\d+),([-+]?\d+)/
  var idx = 0
  
  mutating func parseRow(_ row: String) -> Robot? {
    if let match = row.firstMatch(of: pattern) {
      defer {
        idx += 1
      }
      return Robot(id: idx, coord: Point(x: Int(match.output.1)!, y: Int(match.output.2)!), velocity: Delta(dx: Int(match.output.3)!, dy: Int(match.output.4)!))
    }
    return nil
  }
}

fileprivate struct RobotField {
  let xSize: Int
  let ySize: Int
  
  var xMiddle: Int {
    xSize / 2
  }
  var yMiddle: Int {
    ySize / 2
  }
  
  func renderField(_ robots: [Robot]) -> String {
    let pointToCount = robots.reduce(into: [Point: Int]()) {
      (map, robot) in
      map[robot.coord, default: 0] += 1
    }
    
    let desc: String = (0..<ySize).map {
      y in
      (0..<xSize).map {
        x in
        let count = pointToCount[Point(x: x, y: y), default: 0]
        switch count {
        case 0..<1:
          return " "
        case 1...9:
          return String(count)
        default:
          return "^"
        }
      }.joined()
    }.joined(separator: "\n")
    return desc
  }
  
  func makeSteps(_ robot: Robot, steps: Int) -> Robot {
    Robot(
      id: robot.id,
      coord: Point(
        x: mathMod(robot.coord.x + mathMod(steps, xSize) * mathMod(robot.velocity.dx, xSize), xSize),
        y: mathMod(robot.coord.y + mathMod(steps, ySize) * mathMod(robot.velocity.dy, ySize), ySize)
      ),
      velocity: robot.velocity
    )
  }
  
  func getQuadrantIdx(_ robot: Robot) -> Int {
    switch (robot.coord.x, robot.coord.y) {
    case (xMiddle..<xMiddle+1, _):
      return 0
    case (_, yMiddle..<yMiddle+1):
      return 0
    case (0..<xMiddle, 0..<yMiddle):
      return 1
    case (0..<xMiddle, (yMiddle + 1)...):
      return 2
    case ((xMiddle + 1)..., 0..<yMiddle):
      return 3
    case ((xMiddle + 1)..., (yMiddle + 1)...):
      return 4
    default:
      assert(false)
    }
  }
}

fileprivate struct Robot: CustomStringConvertible {
  let id: Int
  var coord: Point
  var velocity: Delta
  
  var description: String {
    "p=\(coord.x),\(coord.y) v=\(velocity.dx),\(velocity.dy) id=\(id)"
  }
}

struct Day14: AdventDay {
  // Save your data in a corresponding text file in the `Data` directory.
  var data: String
  var rows: [String] { data.components(separatedBy: "\n").filter({$0.count > 0}) }

  // Replace this with your solution for the first part of the day's challenge.
  func part1() -> Any {
    var reader = RobotReader()
    let field = RobotField(xSize: 101, ySize: 103)
    let steps = 100
    let robots = rows.map({reader.parseRow($0)!})
    let steppedRobots = robots.map {
      field.makeSteps($0, steps: steps)
    }
    let quadrants = steppedRobots.map(field.getQuadrantIdx).reduce(into: [Int: Int](),  { partialResult, q in
      partialResult[q, default: 0] += 1
    })
    return quadrants[1, default: 0] * quadrants[2, default: 0] * quadrants[3, default: 0] * quadrants[4, default: 0]
  }

  func part2() -> Any {
    var reader = RobotReader()
//    let field = RobotField(xSize: 11, ySize: 7)
    let field = RobotField(xSize: 101, ySize: 103)
    let robots = rows.map({reader.parseRow($0)!})
    let filename = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask)[0]
      .appendingPathComponent("output.txt")
    var renderedSteps = [String]()
    
//    let steps = (0...100000).filter {
//      $0 % 101 ==
//    }
    
    for steps in 7500...7600 {
      let steppedRobots = robots.map {
        field.makeSteps($0, steps: steps)
      }
//      print("Steps: \(steps)")
      let rendered = field.renderField(steppedRobots)
      
      renderedSteps.append("Steps: \(steps)\n\(rendered)\n")
    }
    
    do {
      try renderedSteps.joined(separator: "\n").write(to: filename, atomically: true, encoding: String.Encoding.utf8)
    } catch {
        // failed to write file – bad permissions, bad filename, missing permissions, or more likely it can't be converted to the encoding
    }
    
    return 0
  }
}
