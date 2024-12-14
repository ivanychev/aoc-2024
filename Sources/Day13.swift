import Algorithms

let OFFSET = 10000000000000

func getFirstGroup(_ input: String, _ pattern: Regex<(Substring, Substring)>) -> String? {
  if let m = try! pattern.firstMatch(in: input) {
    return String(m.output.1)
  }
  return nil
}

fileprivate struct Steps {
  let a: Int
  let b: Int
  
  func costs() -> Int {
    return 3*a + b
  }
}

fileprivate struct CaseBuilder {
  let xPlus = /X([+-]\d+)/
  let yPlus = /Y([+-]\d+)/
  let xEquals = /X\=([+-]?\d+)/
  let yEquals = /Y\=([+-]?\d+)/
  
  func fromRawCase(_ rawCase: String, offset: Int) -> Case {
    let parts = rawCase.split(separator: "\n").map(String.init)
    let buttonA = Delta(dx: Int(getFirstGroup(parts[0], xPlus)!)!,
                        dy: Int(getFirstGroup(parts[0], yPlus)!)!)
    let buttonB = Delta(dx: Int(getFirstGroup(parts[1], xPlus)!)!,
                        dy: Int(getFirstGroup(parts[1], yPlus)!)!)
    let prizeAt = Delta(dx: Int(getFirstGroup(parts[2], xEquals)!)! + offset,
                        dy: Int(getFirstGroup(parts[2], yEquals)!)! + offset)
    return Case(buttonA: buttonA, buttonB: buttonB, prizeAt: prizeAt)
  }
}

func isInt(_ val: Double) -> Bool {
  let roundedVal = val.rounded(.toNearestOrAwayFromZero)
  return closeToZero(roundedVal - val)
}

fileprivate struct Case {
  let buttonA: Delta
  let buttonB: Delta
  let prizeAt: Delta
  
  func steps() -> Steps? {
    let dx1 = Double(buttonA.dx)
    let dy1 = Double(buttonA.dy)
    let dx2 = Double(buttonB.dx)
    let dy2 = Double(buttonB.dy)
    let x = Double(prizeAt.dx)
    let y = Double(prizeAt.dy)
    
    let b: Double = (dy1 * x - y * dx1) / (dx2 * dy1 - dy2 * dx1)
    let a: Double = (x - dx2 * b) / dx1
    print("A: \(a), B: \(b)")
    
    if isInt(a) && isInt(b) && a >= 0 && b >= 0 {
      return Steps(a: Int(a.rounded(.toNearestOrAwayFromZero)), b: Int(b.rounded(.toNearestOrAwayFromZero)))
    }
    
    return nil
  }
  
}

struct Day13: AdventDay {
  // Save your data in a corresponding text file in the `Data` directory.
  var data: String
  var cases: [String] { data.components(separatedBy: "\n\n").filter({$0.count > 0}) }

  // Replace this with your solution for the first part of the day's challenge.
  func part1() -> Any {
    let builder = CaseBuilder()
    let cases = cases.map({builder.fromRawCase($0, offset: 0)})
    let steps = cases.map({ $0.steps()})
    return steps.map {
      steps in
      steps.map({$0.costs()}) ?? 0
    }.reduce(0, +)
  }

  func part2() -> Any {
    let builder = CaseBuilder()
    let cases = cases.map({builder.fromRawCase($0, offset: OFFSET)})
    let steps = cases.map({ $0.steps()})
    return steps.map {
      steps in
      steps.map({$0.costs()}) ?? 0
    }.reduce(0, +)
  }
}
