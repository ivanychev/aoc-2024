import Algorithms


struct Day19: AdventDay {
  // Save your data in a corresponding text file in the `Data` directory.
  var data: String
  var rows: [[Character]] { data.components(separatedBy: "\n").filter({$0.count > 0}).map({Array($0)}) }
  
  func numVariants(towel: String, patterns: [String]) -> Int? {
    var suffixToMinTowels = [String(""): 1]
    let towelChars = Array(towel)
    for suffixSize in 1...towelChars.count {
      let suffix = towelChars[(towelChars.count - suffixSize)..<towelChars.count]
      let suffixStr = String(suffix)
      for pattern in patterns {
        if !suffix.starts(with: pattern) {
          continue
        }
        assert(pattern.count <= suffix.count)
        let left = (pattern.count < suffix.count) ? String(suffix[(suffix.startIndex + pattern.count)..<suffix.endIndex]): ""
        let length = suffixToMinTowels[left]
        guard length != nil else {
          continue
        }
        
        suffixToMinTowels[suffixStr, default: 0] += length!
      }
    }
    return suffixToMinTowels[towel]
  }
  
  // Replace this with your solution for the first part of the day's challenge.
  func part1() -> Any {
    let patterns = String(rows[0]).components(separatedBy: ", ")
    let towels = rows[1...].map{String($0)}
    
    var total = 0
    for towel in towels.enumerated() {
      if numVariants(towel: towel.element, patterns: patterns) != nil {
        total += 1
      }
    }
    
    return total
  }
  
  func part2() -> Any {
    let patterns = String(rows[0]).components(separatedBy: ", ")
    let towels = rows[1...].map{String($0)}
    
    var total = 0
    for towel in towels.enumerated() {
      if let num = numVariants(towel: towel.element, patterns: patterns) {
        total += num
      }
    }
    
    return total
  }
}
