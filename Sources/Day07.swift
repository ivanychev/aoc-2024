import Algorithms
import BigInt

struct BridgeCase {
  let expected: Int
  let operands: [Int]
  var operatorSlots: Int {
    operands.count - 1
  }
  
  static func fromString(_ string: String) -> BridgeCase {
    let components = string.components(separatedBy: ": ")
    let expected = Int(components[0])!
    let operands = components[1].split(separator: " ").map({Int($0)!})
    
    return BridgeCase(expected: expected, operands: operands)
  }
}

typealias BridgeSearchState = (value: Int, usedOperators: Int)

protocol Day07Operator {
  func binaryOperate(_ lhs: Int, _ rhs: Int) throws -> Int
}

enum Day07Error: Error {
    case overflow
}

struct PlusOperator: Day07Operator {
  func binaryOperate(_ lhs: Int, _ rhs: Int) throws -> Int {
    let res = lhs.addingReportingOverflow(rhs)
    if res.overflow {
      throw Day07Error.overflow
    }
    
    return res.partialValue
  }
}

struct MultipleOperator: Day07Operator {
  func binaryOperate(_ lhs: Int, _ rhs: Int) throws-> Int {
    let res = lhs.multipliedReportingOverflow(by: rhs)
    if res.overflow {
      throw Day07Error.overflow
    }
    
    return res.partialValue
  }
}

struct ConcatOperator: Day07Operator {
  func binaryOperate(_ lhs: Int, _ rhs: Int) throws -> Int {
    let value = BigInt("\(lhs)\(rhs)", radix: 10)!
    
    if value <= BigInt(Int.max) && value >= BigInt(Int.min) {
      return Int(value)
    }
    throw Day07Error.overflow
  }
}

struct Day07: AdventDay {
  // Save your data in a corresponding text file in the `Data` directory.
  var data: String
  var rows: [String] { data.components(separatedBy: "\n").filter({$0.count > 0}) }

  func part1bridgeBfs(c: BridgeCase, operators: [Day07Operator]) -> Int {
    var queue = Deque<BridgeSearchState>([
      BridgeSearchState(value: c.operands[0], usedOperators: 0)
    ])
    
    while queue.isEmpty == false {
      let state = queue.removeFirst()
      if state.value == c.expected && state.usedOperators == c.operatorSlots {
        return c.expected
      }
      if state.usedOperators == c.operatorSlots {
        continue
      }
      let nextOperandIdx = state.usedOperators + 1
      for op in operators {
        let newValue = (try? op.binaryOperate(state.value, c.operands[nextOperandIdx]))!
        if newValue <= c.expected {
          queue.append(BridgeSearchState(value: newValue, usedOperators: state.usedOperators + 1))
        }
      }
    }
    return 0
  }

  // Replace this with your solution for the first part of the day's challenge.
  func part1() -> Any {
    var total = Int(0)
    for row in rows {
      let bridgeCase = BridgeCase.fromString(row)
      total += part1bridgeBfs(c: bridgeCase, operators: [PlusOperator(), MultipleOperator()])
    }
    return total
  }

  func part2() -> Any {
    var total = Int(0)
    for row in rows {
      let bridgeCase = BridgeCase.fromString(row)
      total += part1bridgeBfs(c: bridgeCase, operators: [PlusOperator(), MultipleOperator(), ConcatOperator()] )
    }
    return total
  }
}
