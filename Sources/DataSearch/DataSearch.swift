import Foundation

public typealias DataSearchResult = (_ range: Range<Int>, _ stop: inout Bool, _ stopAll: inout Bool)->()
public class DataSearch {
  var options = [SearchProtocol]()
  public var skipEmpty = true
  public init() {}
  public func find(word: String, result: @escaping DataSearchResult) {
    let searchOptions = WordSearch(pattern: Array(word.utf8), currentStates: [], result: result)
    options.append(searchOptions)
  }
  public func find(between string: String, result: @escaping DataSearchResult) {
    let searchOptions = BeforeWordSearch(pattern: Array(string.utf8), currentStates: [], result: result)
    options.append(searchOptions)
  }
  public func find(between string1: String, and string2: String, result: @escaping DataSearchResult) {
    let searchOptions = BetweenWordsSearch(start: Array(string1.utf8), end: Array(string2.utf8), result: result)
    options.append(searchOptions)
  }
  public func find(data: Data, result: @escaping DataSearchResult) {
    let searchOptions = WordSearch(pattern: Array(data), currentStates: [], result: result)
    options.append(searchOptions)
  }
  public func reset() {
    options.forEach { $0.reset() }
  }
  
  public func search(in string: String) {
    search(in: Data(string.utf8))
  }
  public func search(in string: String, range: PartialRangeFrom<Int>) {
    search(in: Data(string.utf8), range: range)
  }
  public func search(in string: String, range: Range<Int>) {
    search(in: Data(string.utf8), range: range)
  }
  public func search(in data: Data) {
    search(in: data, range: 0..<data.count)
  }
  public func search(in data: Data, range: PartialRangeFrom<Int>) {
    search(in: data, range: range.lowerBound..<data.count)
  }
  public func search(in data: Data, range: Range<Int>) {
    data.withUnsafeBytes { (pointer: UnsafePointer<UInt8>) in
      for i in range.lowerBound..<range.upperBound {
        let byte = pointer[i]
        var o = 0
        for j in 0..<options.count {
          let index = j-o
          let searchOptions = options[index]
          let found = searchOptions.append(byte)
          guard found else { continue }
          let range = searchOptions.resultRange(for: i+1)
          if skipEmpty && range.isEmpty { return }
          var shouldStop = false
          var shouldStopAll = false
          searchOptions.result(range,&shouldStop,&shouldStopAll)
          if shouldStop {
            options.remove(at: index)
            o += 1
          }
          guard !shouldStopAll else { return }
        }
      }
    }
  }
}

