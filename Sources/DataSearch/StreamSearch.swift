//
//  StreamSearch.swift
//  DataSearch
//
//  Created by Dmitry on 8/17/18.
//

import Foundation

public class StreamSearch {
  let searchOptions: WordSearchBlank
  public init(beacon: Data) {
    searchOptions = WordSearchBlank(pattern: Array(beacon), currentStates: [])
  }
  public func search(in data: Data, offset: Int) -> Range<Int>? {
    var range: Range<Int>?
    data.withUnsafeBytes { (bytes: UnsafePointer<UInt8>) in
      for i in offset..<data.count {
        guard searchOptions.append(bytes[i]) else { continue }
        range = searchOptions.resultRange(for: i+1)
      }
    }
    return range
  }
  public func reset() {
    searchOptions.reset()
  }
}
