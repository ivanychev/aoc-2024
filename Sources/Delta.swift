//
//  Delta.swift
//  AdventOfCode
//
//  Created by Sergey Ivanychev on 08/12/2024.
//

struct Delta: Equatable, Hashable {
  let dx: Int
  let dy: Int
  
  func opposite() -> Delta {
    Delta(dx: -dx, dy: -dy)
  }
  
  func turnClockwise() -> Delta {
    Delta(dx: -dy, dy: dx)
  }
  
  func isOpposite(_ other: Delta) -> Bool {
    return (dx == other.dx && dx == 0 && dy == -other.dy && abs(dy) == 1) ||
    (dy == other.dy && dy == 0 && dx == -other.dx && abs(dx) == 1)
  }
  
  static func up() -> Delta {
    DELTA_UP
  }
  
  static func down() -> Delta {
    DELTA_DOWN
  }
  
  static func left() -> Delta {
    DELTA_LEFT
  }
  
  static func right() -> Delta {
    DELTA_RIGHT
  }
}

let DELTA_UP = Delta(dx: 0, dy: -1)
let DELTA_DOWN = Delta(dx: 0, dy: 1)
let DELTA_LEFT = Delta(dx: -1, dy: 0)
let DELTA_RIGHT = Delta(dx: 1, dy: 0)
