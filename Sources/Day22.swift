import Algorithms


fileprivate struct DigitSequence : Hashable {
  let values: [Int]
}

fileprivate struct PriceChange : Hashable{
  let seq: DigitSequence
  let price: Int
}

struct Day22: AdventDay {
  // Save your data in a corresponding text file in the `Data` directory.
  var data: String
  var rows: [[Character]] { data.components(separatedBy: "\n").filter({$0.count > 0}).map({Array($0)}) }
  
  
  
  func mix(value: Int, secret: Int) -> Int {
    value ^ secret
  }
  
  func prune(secret: Int) -> Int {
    secret % 16777216
  }
  
  func nextSecret(secret: Int) -> Int {
    var val = secret
    val = prune(secret: mix(value: val * 64, secret: val))
    val = prune(secret: mix(value: val / 32, secret: val))
    val = prune(secret: mix(value: val * 2048, secret: val))
    return val
  }
  
  func getSecretNumber(secret: Int, idx: Int) -> Int {
    var value = secret
    for _ in 0..<idx {
      value = nextSecret(secret: value)
    }
    return value
  }
  
  func lastDigit(_ value: Int) -> Int {
    value % 10
  }

  // Replace this with your solution for the first part of the day's challenge.
  func part1() -> Any {
    let secrets = rows.map{Int(String($0))!}
    
    return secrets.map{getSecretNumber(secret:$0, idx:2000)}.reduce(0, +)
  }
  
  fileprivate func generatePriceChanges(secret: Int) -> [DigitSequence:PriceChange] {
    var secret = secret
    var prices = [lastDigit(secret)]
    for _ in 0..<2000 {
      secret = nextSecret(secret: secret)
      prices.append(lastDigit(secret))
    }
    var seqTopriceChanges: [DigitSequence:PriceChange] = [:]
    for window in prices.windows(ofCount: 5) {
      let seq = [
        window[window.startIndex + 1] - window[window.startIndex],
        window[window.startIndex+2] - window[window.startIndex+1],
        window[window.startIndex+3] - window[window.startIndex+2],
        window[window.startIndex+4] - window[window.startIndex+3],
      ]
      let change = PriceChange(seq: DigitSequence(values: seq), price: window[window.startIndex+4])
      if seqTopriceChanges[change.seq] != nil {
        continue
      }
      seqTopriceChanges[change.seq] = change
    }
    return seqTopriceChanges
  }

  func part2() -> Any {
    let secrets = rows.map{Int(String($0))!}
    let priceChanges: [[DigitSequence:PriceChange]] = secrets.map{generatePriceChanges(secret:$0)}
    let merged = priceChanges.reduce(into: [DigitSequence:[PriceChange]]()) {
        result, element in
        for (seq, price) in element {
          result[seq, default: []].append(price)
        }
    }
    return merged.values.map {
      seqs in
      seqs.map{$0.price}.reduce(0, +)
    }.max()!
  }
}
