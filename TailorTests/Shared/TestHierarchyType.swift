import XCTest
import Tailor

class Event: Mappable {
  var name: String = ""

  required init(_ map: [String : AnyObject]) {
    self.name <- map.property("name")
  }
}

class PushEvent: Event {
  var SHA: String = ""

  required init(_ map: [String : AnyObject]) {
    super.init(map)

    self.SHA <- map.property("sha")
  }
}

class IssueEvent: Event {
  var number: Int = 0

  required init(_ map: [String : AnyObject]) {
    super.init(map)

    self.number <- map.property("number")
  }
}

extension Event: HierarchyType {
  static func cluster(_ map: [String : AnyObject]) -> AnyObject {
    let kinds: [String: Event.Type] = [
      "push": PushEvent.self,
      "issue": IssueEvent.self
    ]

    if let kind = map["type"] as? String, let type = kinds[kind] {
      return type.init(map)
    } else {
      return self.init(map)
    }
  }
}

class Notification: Mappable {
  var events: [Event] = []

  required init(_ map: [String : AnyObject]) {
    self.events <- map.relationsHierarchically("events")
  }
}

class TestHierarchyType: XCTestCase {
  func testHierarchyType() {
    let json: [String : AnyObject] = [
      "events": [
        [
          "type": "push",
          "name": "Update README",
          "sha": "a8037a7bda800c51ee1aae557729a9b16e8e57fe"
        ],
        [
          "type": "issue",
          "name": "Add HierarchyType",
          "number": 3
        ]
      ] as AnyObject
    ]

    let notification = Notification(json)

    let push = notification.events[0] as! PushEvent
    XCTAssertEqual(push.name, "Update README")
    XCTAssertEqual(push.SHA, "a8037a7bda800c51ee1aae557729a9b16e8e57fe")

    let issue = notification.events[1] as! IssueEvent
    XCTAssertEqual(issue.name, "Add HierarchyType")
    XCTAssertEqual(issue.number, 3)
  }
}
