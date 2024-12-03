import Algorithms

let DO = "do()"
let DONT = "don't()"

struct Day03: AdventDay {
  // Save your data in a corresponding text file in the `Data` directory.
  var data: String


  // Replace this with your solution for the first part of the day's challenge.
  func part1() -> Any {
    let mulRe = /mul\(([-+]?\d+),([-+]?\d+)\)/
    let res = data.matches(of: mulRe).map({(m) in
      let first = Int(m.output.1)!
      let second = Int(m.output.2)!
      
//      print("\(first) * \(second) = \(first * second)")
      
      return first * second
    }).reduce(0, +)
    
    return res
  }

  // Replace this with your solution for the second part of the day's challenge.
  func part2() -> Any {
    let pattern = /(mul\(([-+]?\d+),([-+]?\d+)\))|(do\(\))|(don't\(\))/
    let matches = data.matches(of: pattern)
    var total = 0
    var enabled = true
    for match in matches {
      print(match.output)
      switch match.output.0 {
      case DO:
        enabled = true
      case DONT:
        enabled = false
      default :
        if enabled {
          print(match.output)
          total += Int(match.output.2!)! * Int(match.output.3!)!
        }
      }
    }
    return total
  }
}
