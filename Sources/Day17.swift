import Algorithms
import Collections
import Darwin

func intPower(_ radix: Int, _ power: Int) -> Int {
  return Int(pow(Double(radix), Double(power)))
}

fileprivate class Machine {
  var registerA: Int
  var registerB: Int
  var registerC: Int
  var program: [Int]
  var instructionPointer: Int = 0
  var output: [Int] = []
  let onOutput: (Machine) -> Void
  
  init(registerA: Int, registerB: Int, registerC: Int, program: [Int],
       onOutput: @escaping (Machine) -> Void) {
    self.registerA = registerA
    self.registerB = registerB
    self.registerC = registerC
    self.program = program
    self.onOutput = onOutput
  }
  
  func getComboOperand(operand: Int) -> Int {
    switch operand {
    case 0...3:
      return operand
    case 4:
      return registerA
    case 5:
      return registerB
    case 6:
      return registerC
    default:
      fatalError("Invalid operand: \(operand)")
    }
  }
  
  func getLiteralOperand(operand: Int) -> Int {
    return operand
  }
  
  func _dv(operand: Int) -> Int {
    registerA / intPower(2, getComboOperand(operand: operand))
  }
  
  func adv(operand: Int) {
    registerA = _dv(operand: operand)
  }
  
  func bxl(operand: Int) {
    registerB = registerB ^ getLiteralOperand(operand: operand)
  }
  
  func bst(operand: Int) {
    registerB = getComboOperand(operand: operand) % 8
  }
  
  func jnz(operand: Int) -> Bool {
    if registerA == 0 {
      return false
    }
    instructionPointer = getLiteralOperand(operand: operand)
    return true
  }
  
  func bxc(operand: Int) {
    registerB = registerB ^ registerC
  }
  
  func out(operand: Int) {
    output.append(getComboOperand(operand: operand) % 8)
    self.onOutput(self)
  }
  
  func bdv(operand: Int) {
    registerB = _dv(operand: operand)
  }
  
  func cdv(operand: Int) {
    registerC = _dv(operand: operand)
  }
  
  func execNextInstruction() -> Bool {
    guard instructionPointer < program.count else { return false }
    let instruction = program[instructionPointer]
    switch instruction {
    case 0:
      adv(operand: program[instructionPointer + 1])
      instructionPointer += 2
    case 1:
      bxl(operand: program[instructionPointer + 1])
      instructionPointer += 2
    case 2:
      bst(operand: program[instructionPointer + 1])
      instructionPointer += 2
    case 3:
      let jumped = jnz(operand: program[instructionPointer + 1])
      if !jumped { instructionPointer += 2 }
    case 4:
      bxc(operand: program[instructionPointer + 1])
      instructionPointer += 2
    case 5:
      out(operand: program[instructionPointer + 1])
      instructionPointer += 2
    case 6:
      bdv(operand: program[instructionPointer + 1])
      instructionPointer += 2
    case 7:
      cdv(operand: program[instructionPointer + 1])
      instructionPointer += 2
    default:
      fatalError("Unknown instruction \(instruction)")
      break
    }
    return true
  }
  
  
  static func fromStrings(rawMachine: [String], onOutput: @escaping (Machine) -> Void) -> Machine {
    let registerA = Int(rawMachine[0].components(separatedBy: ": ")[1])!
    let registerB = Int(rawMachine[1].components(separatedBy: ": ")[1])!
    let registerC = Int(rawMachine[2].components(separatedBy: ": ")[1])!
    let program = rawMachine[3].components(separatedBy: ": ")[1].split(separator: ",").map {Int($0)!}
    return Machine(registerA: registerA, registerB: registerB, registerC: registerC, program: program, onOutput:onOutput)
  }
  
  func cloneWithRegisterA(_ newRegisterA: Int, _ newOnOutput: @escaping (Machine) -> Void) -> Machine {
    Machine(registerA: newRegisterA, registerB: registerB, registerC: registerC, program: program,
            onOutput:newOnOutput)
  }
}

struct Day17: AdventDay {
  // Save your data in a corresponding text file in the `Data` directory.
  var data: String
  var rows: [[Character]] { data.components(separatedBy: "\n").filter({$0.count > 0}).map({Array($0)}) }
  
  // Replace this with your solution for the first part of the day's challenge.
  func part1() -> Any {
    let machine = Machine.fromStrings(rawMachine: rows.map {String($0)},
                                      onOutput: {m in})
    while machine.execNextInstruction() {}
    return machine.output.map {String($0)}.joined(separator: ",")
  }
  
  func part2() -> Any {
    let machinePrototype = Machine.fromStrings(rawMachine: rows.map {String($0)},
                                               onOutput: {m in})
    var candidates = Set<Int>()
    for a in 0...255 {
      let machineClone = machinePrototype.cloneWithRegisterA(a) {machine in}
      while machineClone.execNextInstruction() {}
      if machineClone.output == [machinePrototype.program.last!] {
        candidates.insert(a)
      }
    }
    
    print("Initial candidates \(candidates)")
    for i in (0...(machinePrototype.program.count - 2)).reversed() {
      print("Checking program code at index \(i) with value \(machinePrototype.program[i]), candidates size \(candidates.count)")
      var updatedCandidates = Set<Int>()
      for part in 0...7 {
        for candidate in candidates {
          let value = candidate << 3 | part
          var seenOut = false
          let machineClone = machinePrototype.cloneWithRegisterA(value) {
            machine in
            assert(machine.output.count == 1)
            seenOut = true
            if machine.output.last! == machinePrototype.program[i] && candidates.contains(machine.registerA) {
              updatedCandidates.insert(value)
            }
          }
          while !seenOut && machineClone.execNextInstruction() {}
        }
      }
      print("After \(i), candidates \(updatedCandidates)")
      candidates = updatedCandidates
    }
    
    return candidates.min()!
  }
}
