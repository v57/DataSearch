import XCTest
@testable import DataSearch

final class DataSearchTests: XCTestCase {
  func testExample() {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct
    // results.
    let text = "Hello World. ??? Look at this tag <SomeTag>. You should Find it using search.find(between:and:)<AnotherTag> ???. Hello world"
    let search = DataSearch()
    search.find(word: "Hello") { range, _, _ in
      print("[Hello] Found \(text[range.lowerBound..<range.upperBound]) in range \(range.lowerBound)..<\(range.upperBound)")
      XCTAssertEqual(text[range.lowerBound..<range.upperBound], "Hello")
    }
    search.find(data: Data("Hello".utf8)) { range, _, _ in
      print("[Hello] Found \(text[range.lowerBound..<range.upperBound]) in range \(range.lowerBound)..<\(range.upperBound)")
      XCTAssertEqual(text[range.lowerBound..<range.upperBound], "Hello")
    }
    search.find(between: "???") { range, _, _ in
      let result = text[range.lowerBound..<range.upperBound]
      let result1 = "Hello World. "
      let result2 = " Look at this tag <SomeTag>. You should Find it using search.find(between:and:)<AnotherTag> "
      print("[???] Found \n\"\(text[range])\"\n in range \(range.lowerBound)..<\(range.upperBound)")
      XCTAssert(result == result1 || result == result2, result)
    }
    search.find(between: "<", and: ">") { range, _, _ in
      let result = text[range.lowerBound..<range.upperBound]
      let result1 = "SomeTag"
      let result2 = "AnotherTag"
      print("[<*>] Found <\(text[range])> in range \(range.lowerBound)..<\(range.upperBound)")
      XCTAssert(result == result1 || result == result2, result)
    }
    for _ in 0..<2 {
      search.search(in: text)
      search.reset()
    }
  }
  func testContext() {
    let search = DataSearch()
    search.find(between: "<stop>") { range, stop, stopAll in
      stop = true
      stopAll = true
    }
    
    for _ in 0..<2 {
      var text = ".sdf.ds..fsd.f...... <st"
      search.search(in: text)
      let index = text.count
      text += "op>.....dfs....f.ad."
      search.search(in: text, range: index...)
      search.reset()
    }
  }
  func testEmptySearch() {
    var text = "???"
    let search = DataSearch()
    search.skipEmpty = true
    search.find(between: "???") { range, stop, stopAll in
      
    }
    search.search(in: text)
    search.reset()
    text = ""
    search.search(in: text)
    search.search(in: text, range: 0..<0)
    
    var a = false
    var b = false
    WordSearchBlank(pattern: [], currentStates: []).result(0..<0,&a,&b)
  }
  func testStreamSearch() {
    let beacon = Data(bytes: [0x14,0x88])
    let streamSearch = StreamSearch(beacon: beacon)
    for _ in 0..<2 {
      var data = Data(bytes: [0x00,0x14,0x00,0x88,0x00,0x14])
      var offset = 0
      var range = streamSearch.search(in: data, offset: offset)
      XCTAssertNil(range)
      offset = data.count
      data.append(Data(bytes: [0x00,0x14,0x88,0x00,0x00,0x00]))
      range = streamSearch.search(in: data, offset: offset)
      XCTAssertNotNil(range)
      XCTAssertEqual(range!, Range<Int>(7..<9))
      streamSearch.reset()
    }
  }
  
  static var allTests = [
    ("testExample", testExample),
    ]
}

extension String {
  subscript (bounds: Range<Int>) -> String {
    let start = index(startIndex, offsetBy: bounds.lowerBound)
    let end = index(startIndex, offsetBy: bounds.upperBound)
    return String(self[start..<end])
  }
}
