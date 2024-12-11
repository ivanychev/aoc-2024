import Algorithms
import LRUCache


fileprivate struct StoneInput: Hashable {
  let stone: Int
  let blinks: Int
}

fileprivate class Solver {
  var cache: LRUCache<StoneInput, Int>
  
  init() {
    cache = LRUCache(countLimit: 1000_000)
  }
  
  func solve(_ input: StoneInput) -> Int {
//    print("\(input)")
    return cache.value(forKey: input) ?? {
      if input.blinks == 0 {
        return 1
      }
      var resultStones = 0
      
      let stoneStr = String(input.stone)
      if input.stone == 0 {
        resultStones = solve(StoneInput(
          stone: 1,
          blinks: input.blinks - 1
        ))
      }
      else if stoneStr.count % 2 == 0 {
        let firstNumIndex = stoneStr.index(stoneStr.startIndex, offsetBy: stoneStr.count / 2)
        let secondNumIndex = stoneStr.index(stoneStr.endIndex, offsetBy: -stoneStr.count / 2)
        
        let firstSubstone = Int(stoneStr[..<firstNumIndex])!
        let secondSubstone = Int(stoneStr[secondNumIndex...])!
        
        resultStones = solve(StoneInput(
          stone: firstSubstone,
          blinks: input.blinks - 1
        )) + solve(StoneInput(
          stone: secondSubstone,
          blinks: input.blinks - 1
        ))
      } else {
        resultStones = solve(StoneInput(
          stone: input.stone * 2024,
          blinks: input.blinks - 1
        ))
      }
      
      cache.setValue(resultStones, forKey: input)
      return resultStones
    }()
  }
  
}

struct Day11: AdventDay {
  // Save your data in a corresponding text file in the `Data` directory.
  var data: String
  var numbers: [Int] { data.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: " ").map({Int($0)!})}

  // Replace this with your solution for the first part of the day's challenge.
  func part1() -> Any {
    let solver = Solver()
    
    return numbers.map({solver.solve(StoneInput(stone: $0, blinks: 25))}).reduce(0, +)
  }

  func part2() -> Any {
    let solver = Solver()
    
    return numbers.map({solver.solve(StoneInput(stone: $0, blinks: 75))}).reduce(0, +)
  }
}
