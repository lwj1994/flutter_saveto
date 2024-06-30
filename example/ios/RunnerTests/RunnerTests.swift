import Flutter
import UIKit
import XCTest

@testable import flutter_saveto

// This demonstrates a simple unit test of the Swift portion of this plugin's implementation.
//
// See https://developer.apple.com/documentation/xctest for more information about using XCTest.

class RunnerTests: XCTestCase {

  func testGetPlatformVersion() {
    let plugin = FlutterSavetoPlugin()

      let call = FlutterMethodCall(methodName: "flutter_saveto", arguments: ["name":"测试","mediaType":"image", "filePath":"https://cdnimg103.lizhi.fm/audio_cover/2017/10/14/2630155633573435399_320x320.jpg","isReturnPathOfIOS":true]);

    let resultExpectation = expectation(description: "result block must be called.")
//    plugin.handle(call) { result in
////      XCTAssertEqual(result as! String, "iOS " + UIDevice.current.systemVersion)
//      resultExpectation.fulfill()
//    }
    waitForExpectations(timeout: 1)
  }

}
