//
//  Point.swift
//  AdventOfCode
//
//  Created by Sergey Ivanychev on 08/12/2024.
//

struct Point: Equatable, Hashable {
  let x: Int
  let y: Int
  
  static func zero() -> Point {
    Point(x: 0, y: 0)
  }
  
func step(_ delta: Delta) -> Point {
    Point(x: x + delta.dx, y: y + delta.dy)
  }
}
