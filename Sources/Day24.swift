import Algorithms

fileprivate protocol HasValue {
  func value(_ nameToOp: [String: HasValue]) -> Bool
}

fileprivate struct Input: HasValue {
  let name: String
  let initValue: Bool
  func value(_ nameToOp: [String: HasValue]) -> Bool {
    initValue
  }
}

fileprivate class Or: HasValue {
  var name: String
  let leftName: String
  let rightName: String

  var result: Bool?
  
  init(name: String, left: String, right: String) {
    self.leftName = left < right ? left : right
    self.rightName = left < right ? right : left
    self.name = name
  }
  
  func compute(_ nameToOp: [String: HasValue]) -> Bool {
    nameToOp[leftName]!.value(nameToOp) || nameToOp[rightName]!.value(nameToOp)
  }
  
  func value(_ nameToOp: [String: HasValue]) -> Bool {
    if result == nil {
      result = compute(nameToOp)
    }
    return result!
  }
}

fileprivate class And: Or {
  override func compute(_ nameToOp: [String: HasValue]) -> Bool {
    nameToOp[leftName]!.value(nameToOp) && nameToOp[rightName]!.value(nameToOp)
  }
}

fileprivate class Xor: Or {
  override func compute(_ nameToOp: [String: HasValue]) -> Bool {
    nameToOp[leftName]!.value(nameToOp) != nameToOp[rightName]!.value(nameToOp)
  }
}

fileprivate func parseOperation(_ op: String) -> Or {
  // x00 AND y00 -> z00
  let components = op.components(separatedBy: " ").filter({$0.count > 0})
  let leftName = components[0]
  let rightName = components[2]
  let operationType = components[1]
  let operationName = components[4]
  
  switch operationType {
    case "AND":
    return And(name: operationName, left: leftName, right: rightName)
  case "OR":
    return Or(name: operationName, left: leftName, right: rightName)
  case "XOR":
    return Xor(name: operationName, left: leftName, right: rightName)
  default:
    fatalError("Failed to parse operation \(operationType).")
  }
}

struct Day24: AdventDay {
  // Save your data in a corresponding text file in the `Data` directory.
  var data: String
  var rows: [[Character]] { data.components(separatedBy: "\n").filter({$0.count > 0}).map({Array($0)}) }
  var parts :[String] { data.components(separatedBy: "\n\n").filter({$0.count > 0}) }
  // Replace this with your solution for the first part of the day's challenge.
  
  fileprivate func parseOperations() -> [Or] {
    parts[1].components(separatedBy: "\n")
      .filter({$0.count > 0})
      .map {
        parseOperation($0)
      }
  }
  
  fileprivate func parseInitialValues() -> [Input] {
    parts[0].components(separatedBy: "\n")
      .filter({$0.count > 0})
      .map {
        let components = $0.components(separatedBy: ": ")
        let name = components[0]
        let value = components[1] == "1"
        return Input(name: name, initValue: value)
      }
  }
  
  fileprivate func parseSystem(operations: [Or], initialValues: [Input]) -> [String: HasValue] {
    var nameToOp = [String: HasValue]()
    nameToOp.reserveCapacity(operations.count + initialValues.count)
    initialValues.forEach {
      pair in
      nameToOp[pair.name] = pair
    }
    
    operations.forEach {
      op in
      nameToOp[op.name] = op
    }
    
    return nameToOp
  }
  
  func part1() -> Any {
    let nameToOp = parseSystem(operations: parseOperations(), initialValues: parseInitialValues())
    let zOutputs = nameToOp.keys.filter{$0.starts(with: /z/)}.sorted()
    var result = 0
    for key in zOutputs.reversed() {
      result = result << 1 | (nameToOp[key]!.value(nameToOp) ? 1 : 0)
    }
    
    return result
  }
  
  fileprivate func printOp(nameToOp: [String: HasValue], opPrefix: String) {
    let keys = nameToOp.keys.filter{$0.starts(with: opPrefix)}.sorted(by: <)
    let printed = keys.map {
      nameToOp[$0]!.value(nameToOp) ? "1" : "0"
    }.reversed().joined(separator: "")
    
    print("\(opPrefix): \(printed)")
  }
  
  fileprivate func setXY(nameToOp: [String: HasValue], x: Int, y: Int) -> [String: HasValue] {
    var nameToOpCopy = nameToOp
    for i in 0...44 {
      nameToOpCopy["x\(String(format: "%02d", i))"] = Input(name: "x\(String(format: "%02d", i))", initValue: (x >> i) & 1 == 1)
      nameToOpCopy["y\(String(format: "%02d", i))"] = Input(name: "y\(String(format: "%02d", i))", initValue: (y >> i) & 1 == 1)
    }
    return nameToOpCopy
  }
  
  fileprivate func getXYX(nameToOp: [String: HasValue]) -> (x: Int, y: Int, z: Int) {
    var x = 0
    var y = 0
    var z = 0
    
    for i in (0...45).reversed() {
      if i != 45 {
        x = (x << 1) | (nameToOp["x\(String(format: "%02d", i))"]!.value(nameToOp) ? 1 : 0)
        y = (y << 1) | (nameToOp["y\(String(format: "%02d", i))"]!.value(nameToOp) ? 1 : 0)
      }
      z = (z << 1) | (nameToOp["z\(String(format: "%02d", i))"]!.value(nameToOp) ? 1 : 0)
    }
    return (x:x, y:y, z:z)
  }


  func part2() -> Any {
//    let expectedZ = 0b1001101000101101001101010000000110101001111100
    for i in 0...43 {
      var operations = parseOperations()
      let initialValues = parseInitialValues()
      var nameToOp = parseSystem(operations: operations, initialValues: initialValues)
      nameToOp = setXY(nameToOp: nameToOp, x: 1<<i, y: 1)
//      print("\(nameToOp["z00"]!.value(nameToOp))")
//      printOp(nameToOp: nameToOp, opPrefix: "x")
//      printOp(nameToOp: nameToOp, opPrefix: "y")
//      printOp(nameToOp: nameToOp, opPrefix: "z")
      let res = getXYX(nameToOp: nameToOp)
      if res.z != res.x + res.y {
        print("\(i): \(res)")
        break
      }
    }
    
    
    
//    var ok = true
//    for i in 0...45 {
//      let key = "z\(String(format: "%02d", i))"
//      print("Key: \(key), ok: \(ok)")
//      let actual = nameToOp[key]!.value(nameToOp) ? 1 : 0
//      let expected = expectedZ >> i & 1
//      if actual != expected {
//        ok = false
//        break
//      }
//    }
    
    
    
//    var analyzed = 0
//    var toAnalyze = 0
//    for indexCombination in operations.indices.combinations(ofCount: 8) {
//      for permutation in indexCombination.permutations(ofCount: 8) {toAnalyze+=1}}
//    print("To analyze: \(toAnalyze)")
//    for indexCombination in operations.indices.combinations(ofCount: 8) {
//      for permutation in indexCombination.permutations(ofCount: 8) {
//        analyzed += 1
//        if analyzed % 10000 == 0 {
//          print("Analyzing \(analyzed)")
//        }
//        var temp = operations[permutation[0]].name
//        for i in 0..<4 {
//          let tmp = operations[permutation[2*i]].name
//          operations[permutation[2*i]].name = operations[permutation[2*i + 1]].name
//          operations[permutation[2*i + 1]].name = tmp
//        }
//        
//        
//        var ok = true
//        for i in 0...45 {
//          let key = "z\(String(format: "%02d", i))"
//          let actual = nameToOp[key]!.value(nameToOp) ? 1 : 0
//          let expected = expectedZ >> i & 1
//          if actual != expected {
//            ok = false
//            break
//          }
//        }
//        if ok {
//          let ops = permutation.map{operations[$0]}
//          print("permutation: \(permutation)")
//          print("ops: \(ops)")
//        }
//        
//        for i in 0..<4 {
//          let tmp = operations[permutation[2*i]].name
//          operations[permutation[2*i]].name = operations[permutation[2*i + 1]].name
//          operations[permutation[2*i + 1]].name = tmp
//        }
//      }
//    }
    return 0
  }
}
