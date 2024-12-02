import Algorithms

struct MonotReduce {
  var prev: Optional<Int>
  var yet: Bool
}

func differOk(_ a: Int, _ b: Int) -> Bool {
  let diff = abs(a - b)
  return (1...3).contains(diff)
}

func getMonotReducer(op: @escaping (Int, Int) -> Bool) -> (inout MonotReduce, Int) -> () {
  return { (result: inout MonotReduce, level: Int) in
    if result.prev == nil {
      result.prev = level
      result.yet = true
      return
   }
    let prev = level
    let yet = result.yet && op(result.prev!, level)
    result.prev = prev
    result.yet = yet
 }
}

struct Report {
  let levels: [Int]
  
  func isSafe() -> Bool {
    let isNonIncreasing = levels.reduce(into: MonotReduce(prev: nil, yet: true), getMonotReducer(op: <=))
    let isNonDecreasing = levels.reduce(into: MonotReduce(prev: nil, yet: true), getMonotReducer(op: >=))
    let isNonRapid = levels.reduce(into: MonotReduce(prev: nil, yet: true), getMonotReducer(op: differOk))
    return isNonRapid.yet && (isNonDecreasing.yet || isNonIncreasing.yet)
  }
  
  func isSafeWithSubreports() -> Bool {
    self.isSafe() || self.subreports().reduce(false, {(now, report) in now || report.isSafe()})
  }
  
  func subreports() -> [Report] {
    Array(0..<self.levels.count).map({index in
      let newLevels = levels.indices.filter({$0 != index}).map({levels[$0]})
      return Report(levels: newLevels)
    })
  }
}

struct Day02: AdventDay {
  // Save your data in a corresponding text file in the `Data` directory.
  var data: String

  // Splits input data into its component parts and convert from string.
  var reports: [Report] {
    data.components(separatedBy: "\n").filter {!$0.isEmpty}.map {
      let components: [Int] = $0.split(separator: " ").map {
        Int($0)!
      }
      
      return Report(levels: components)
    }
  }

  // Replace this with your solution for the first part of the day's challenge.
  func part1() -> Any {
    print(reports.filter({$0.isSafe()}).count)
  }

  // Replace this with your solution for the second part of the day's challenge.
  func part2() -> Any {
    print(reports.filter({$0.isSafeWithSubreports()}).count)
  }
}
