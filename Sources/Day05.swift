import Algorithms

struct Ordering {
  let first: Int
  let second: Int
  
  static func fromString(_ string: String) -> Ordering {
    let components = string.split(separator: "|").map({Int($0)!})
    return Ordering(first: components[0], second: components[1])
  }
}

struct Pages {
  var indices: [Int]
  var pageToIndex: [Int:Int]
  
  static func fromString(_ string: String) -> Pages {
    let components = string.split(separator: ",").map({Int($0)!})
    
    let pageToIndex = components.enumerated().reduce(into: [Int: Int]()) {
      (acc, pair) in
      acc[pair.element] = pair.offset
    }
    return Pages(indices: components, pageToIndex: pageToIndex)
  }
  
  func middlePage() -> Int {indices[indices.count / 2]}
  
  mutating func swapPages(_ first: Int, _ second: Int) {
    let firstIndex = pageToIndex[first]!
    let secondIndex = pageToIndex[second]!
    
    pageToIndex[first] = secondIndex
    pageToIndex[second] = firstIndex
    
    indices[firstIndex] = second
    indices[secondIndex] = first
  }
}

struct Day05: AdventDay {
  // Save your data in a corresponding text file in the `Data` directory.
  var data: String
  var parts: [String] { data.components(separatedBy: "\n\n")}
  var orderings: [Ordering] {
    parts[0]
      .components(separatedBy: "\n")
      .filter({$0.count > 0})
      .map(Ordering.fromString)
  }
  var pageToOrderings: [Int: [Ordering]] { orderings.reduce(into: [Int: [Ordering]]()) {
    (acc, ordering) in
    acc[ordering.first, default: []].append(ordering)
    acc[ordering.second, default: []].append(ordering)
  }
  }
  var pages: [Pages] {
    parts[1]
      .components(separatedBy: "\n")
      .filter({$0.count > 0})
      .map(Pages.fromString)
  }
  
  func findUnconformingOrdering(_ page: Pages) -> Ordering? {
    for pageIndex in page.indices {
      let orderings = pageToOrderings[pageIndex] ?? []
      for ordering in orderings {
        let firstIndex = page.pageToIndex[ordering.first]
        let secondIndex = page.pageToIndex[ordering.second]
        if firstIndex == nil || secondIndex == nil {
          continue
        }
        if firstIndex! > secondIndex! {
          return ordering
        }
      }
    }
    return nil
  }
  
  func conformOrderings(_ page: Pages) -> Bool {
    return findUnconformingOrdering(page) == nil
  }



  // Replace this with your solution for the first part of the day's challenge.
  func part1() -> Any {
    var total = 0
    
    for page in pages {
      if conformOrderings(page) {
        total += page.middlePage()
      }
    }
    
    return total
  }

  func part2() -> Any {
    var total = 0
    
    for (idx, page) in pages.enumerated() {
      var mutablePage = page
      var valid = true
      var ops = 0
      while let ordering = findUnconformingOrdering(mutablePage) {
        mutablePage.swapPages(ordering.first, ordering.second)
        if valid == true || ops%1000 == 0 {
          valid = false
          print("Processing \(idx) \(mutablePage), ops: \(ops)")
        }
        ops += 1
      }
      if !valid {
        total += mutablePage.middlePage()
      }
    }
    return total
  }
  
  
}
