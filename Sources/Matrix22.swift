//
//  Matrix22.swift
//  AdventOfCode
//
//  Created by Sergey Ivanychev on 13/12/2024.
//

func closeToZero(_ value: Double) -> Bool {
  return value.magnitude < 0.0000001
}

struct Matrix22 {
  var values: [[Double]]
  
  func determinant() -> Double? {
    let d = values[0][0] * values[1][1] - values[1][0] * values[0][1]
    return closeToZero(d) ? nil : d
  }
  
  func inverted() -> Matrix22? {
    let determinant = self.determinant()
    guard let determinant else { return nil }
    let invDet = 1.0 / determinant
    
    return Matrix22(
      values: [[invDet *  values[1][1], invDet * -values[0][1]],
               [invDet * -values[1][0], invDet *  values[0][0]]]
    )
  }
}
