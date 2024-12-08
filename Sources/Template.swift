import Algorithms

struct Template: AdventDay {
  // Save your data in a corresponding text file in the `Data` directory.
  var data: String
  var rows: [[Character]] { data.components(separatedBy: "\n").filter({$0.count > 0}).map({Array($0)}) }

  // Replace this with your solution for the first part of the day's challenge.
  func part1() -> Any {
    return 0
  }

  func part2() -> Any {
    return 0
  }
}
