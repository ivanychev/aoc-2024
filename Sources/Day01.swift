import Algorithms

struct Coord {
  var first: Int
  var second: Int
}

struct Day01: AdventDay {
  // Save your data in a corresponding text file in the `Data` directory.
  var data: String

  // Splits input data into its component parts and convert from string.
  var entities: [Coord] {
    data.components(separatedBy: "\n").filter {!$0.isEmpty}.map {
      let components: Array<Int> = $0.split(separator: " ").map {
        Int($0)!
      }
//      print(data)
//      print($0)
//      print(components)
      
      return Coord(first: components[0], second: components[1])
    }
  }

  // Replace this with your solution for the first part of the day's challenge.
  func part1() -> Any {
    let firstIds = entities.map(\.first).sorted()
    let secondIds = entities.map(\.second).sorted()
    
    return zip(firstIds, secondIds).map{
      abs($0.0 - $0.1)
    }.reduce(0, +)
  }

  // Replace this with your solution for the second part of the day's challenge.
  func part2() -> Any {
    let firstIds = entities.map(\.first)
    let secondIds = entities.map(\.second).sorted()
    let secondCounters = Dictionary(grouping: secondIds, by: \.self).mapValues(\.count)
    print(secondIds)
    print(secondCounters)
    
    return firstIds.map {
      $0 * (secondCounters[$0] ?? 0)
    }.reduce(0, +)
  }
}
