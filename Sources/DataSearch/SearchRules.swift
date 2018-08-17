//
//  SearchRules.swift
//  DataSearch
//
//  Created by Dmitry on 8/17/18.
//

import Foundation

protocol SearchProtocol: class {
  var result: DataSearchResult { get }
  func append(_ byte: UInt8) -> Bool
  func resultRange(for index: Int) -> Range<Int>
  func reset()
}

class WordSearchBlank: SearchProtocol {
  var pattern: [UInt8]
  var currentStates: [Int]
  var result: DataSearchResult { return { _,_,_ in } }
  init(pattern: [UInt8], currentStates: [Int]) {
    self.pattern = Array(pattern)
    self.currentStates = currentStates
  }
  func append(_ byte: UInt8) -> Bool {
    var found = false
    var offset = 0
    for j in 0..<currentStates.count {
      let index = j-offset
      let state = currentStates[index]
      if byte == pattern[state] {
        if state == pattern.count - 1 {
          found = true
          currentStates.remove(at: index)
          offset += 1
        } else {
          currentStates[index] += 1
        }
      } else {
        currentStates.remove(at: index)
        offset += 1
      }
    }
    if byte == pattern[0] {
      if pattern.count == 1 {
        return true
      } else {
        currentStates.append(1)
      }
    }
    return found
  }
  func resultRange(for index: Int) -> Range<Int> {
    return index - pattern.count ..< index
  }
  func reset() {
    currentStates.removeAll()
  }
}

class WordSearch: WordSearchBlank {
  var _result: DataSearchResult
  override var result: DataSearchResult { return _result }
  init(pattern: [UInt8], currentStates: [Int], result: @escaping DataSearchResult) {
    self._result = result
    super.init(pattern: pattern, currentStates: currentStates)
  }
}


class BeforeWordSearch: WordSearch {
  var startIndex = 0
  override func append(_ byte: UInt8) -> Bool {
    guard !super.append(byte) else { return true }
    startIndex += 1
    return false
  }
  override func resultRange(for index: Int) -> Range<Int> {
    let result: Range<Int> = index-startIndex-1..<index-pattern.count
    startIndex = 0
    return result
  }
  override func reset() {
    super.reset()
    startIndex = 0
  }
}

class BetweenWordsSearch: SearchProtocol {
  let start: WordSearchBlank
  let end: WordSearchBlank
  var started = false
  var startOffset = 0
  var result: DataSearchResult
  init(start: [UInt8], end: [UInt8], result: @escaping DataSearchResult) {
    self.start = WordSearchBlank(pattern: start, currentStates: [])
    self.end = WordSearchBlank(pattern: end, currentStates: [])
    self.result = result
  }
  func append(_ byte: UInt8) -> Bool {
    if start.append(byte) {
      end.reset()
      started = true
      startOffset = 0
    } else if started {
      startOffset += 1
    }
    guard started else { return false }
    guard end.append(byte) else { return false }
    started = false
    return true
  }
  func resultRange(for index: Int) -> Range<Int> {
    let count = startOffset - end.pattern.count
    let start = index - count
    return start-1..<index-1
  }
  func reset() {
    start.reset()
    end.reset()
    started = false
    startOffset = 0
  }
}
