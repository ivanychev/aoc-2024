import Algorithms

fileprivate enum FileRange {
  case empty(size: Int)
  case file(size: Int, id: Int)
  
  func getSize() -> Int? {
    switch self {
    case .empty:
      return nil
    case .file(size: let size, id: _):
      return size
    }
  }
  
  func getId() -> Int? {
    switch self {
    case .empty:
      return nil
    case .file(size: _, id: let id):
      return id
    }
  }
  
}

fileprivate func parseInput(_ input: String) -> [FileRange] {
  let rawFiles = Array(input.trimmingCharacters(in: .whitespacesAndNewlines))
  var ranges = [FileRange]()
  var currentFileId = 0
  for i in 0..<rawFiles.count {
    if i % 2 == 0 {
      ranges.append(.file(size: Int(String(rawFiles[i]))!, id: currentFileId))
      currentFileId += 1
    } else {
      ranges.append(.empty(size: Int(String(rawFiles[i]))!))
    }
  }
  return ranges
}

fileprivate struct FileConsumptionState {
  var consumed: Int
  var index: Int
  var size: Int
  var id: Int
  
  func leftToPut() -> Int {
    size - consumed
  }
}

fileprivate func defragRanges(_ ranges: [FileRange]) -> [FileRange] {
  var latestFileIdx = ranges.lastIndex {
    switch $0 {
    case .empty:
      return false
      case .file:
      return true
    }
  }!
  
  var fileConsState = FileConsumptionState(consumed: 0, index: latestFileIdx, size: ranges[latestFileIdx].getSize()!, id: ranges[latestFileIdx].getId()!)
  
  var currentPtr = 0
  var defragged = [FileRange]()
  while currentPtr <= fileConsState.index {
    switch ranges[currentPtr] {
    case .file:
      let size = ranges[currentPtr].getId()! == fileConsState.id ? fileConsState.leftToPut() : ranges[currentPtr].getSize()!
      defragged.append(.file(size: size, id: ranges[currentPtr].getId()!))
      currentPtr += 1
    case .empty(size: var size):
      while size > 0 && currentPtr < fileConsState.index {
        let newChunkSize = min(size, fileConsState.leftToPut())
        defragged.append(.file(size: newChunkSize, id: fileConsState.id))
        fileConsState.consumed += newChunkSize
        size -= newChunkSize
        if fileConsState.leftToPut() == 0 {
          fileConsState = FileConsumptionState(
            consumed: 0,
            index: fileConsState.index - 2,
            size: ranges[fileConsState.index - 2].getSize()!,
            id: ranges[fileConsState.index - 2].getId()!)
        }
      }
      currentPtr += 1
    }
  }
  return defragged
  
}

fileprivate func renderDefraggedRanges(_ ranges: [FileRange]) -> String {
  var chars = [String]()
  for range in ranges {
    switch range {
      case let .empty(size):
      chars.append(String(repeating: ".", count: size))
      case let .file(size, id):
      chars.append(String(repeating: String(id), count: size))
    }
  }
  return chars.joined(separator: "")
}

fileprivate func defragFiles(_ ranges: [FileRange]) -> [FileRange] {
  var ranges = ranges
  let ids = ranges.map({$0.getId()}).flatMap({$0 != nil ? [$0!] : [Int]()}).reversed()
//  print(" - \(renderDefraggedRanges(ranges))")
  outerLoop: for id in ids {
    let fileIdx = ranges.lastIndex(where: { $0.getId() == id })!
    let fileSize = ranges[fileIdx].getSize()!
    for placeIdx in 0..<fileIdx {
      guard case let .empty(emptySize) = ranges[placeIdx] else {continue}
      guard emptySize >= fileSize else {
        continue
      }
      ranges[placeIdx] = ranges[fileIdx]
      ranges[fileIdx] = .empty(size: fileSize)
      if emptySize > fileSize {
        ranges.insert(.empty(size: emptySize - fileSize), at: placeIdx + 1)
      }
//      print(" - \(renderDefraggedRanges(ranges))")
      continue outerLoop
    }
  }
  return ranges
}

struct Day09: AdventDay {
  // Save your data in a corresponding text file in the `Data` directory.
  var data: String
  
  fileprivate func computeSum(defragged: [FileRange]) -> Int {
    var idx: Int = 0
    var total: Int = 0
    for range in defragged {
      switch range {
      case let .empty(size):
        idx += size
      case let .file(size, id):
        total += id * (size * ((idx + idx + size - 1)) / 2)
        idx += size
      }
    }
    return total
  }


  // Replace this with your solution for the first part of the day's challenge.
  func part1() -> Any {
    let ranges = parseInput(data)
    print("Ranges count: \(ranges.count)")
    let defragged = defragRanges(ranges)
    print(renderDefraggedRanges(defragged))
    return computeSum(defragged: defragged)
  }

  func part2() -> Any {
    let ranges = parseInput(data)
    print("Ranges count: \(ranges.count)")
    let defragged = defragFiles(ranges)
    print(renderDefraggedRanges(defragged))
    return computeSum(defragged: defragged)
  }
}
