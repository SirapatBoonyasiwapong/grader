import Foundation
import FluentProvider

final class GroupEvent: Model, NodeRepresentable {
    
    var groupID: Identifier
    var eventID: Identifier
    
    var classroom: Parent<GroupEvent, Group> {
        return parent(id: groupID)
    }
    
    var events: Parent<GroupEvent, Event> {
        return parent(id: eventID)
    }
    
    let storage = Storage()
    
    init(row: Row) throws {
        groupID = try row.get("group_id")
        eventID = try row.get("event_id")
    }
    
    init(groupID: Identifier, eventID: Identifier) {
        self.groupID = groupID
        self.eventID = eventID
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("group_id", groupID)
        try row.set("event_id", eventID)
        
        return row
    }
    
    func makeNode(in context: Context?) throws -> Node {
        let events = try self.events.get()
        return try Node(node: [
            "id": id!.string!,
            "groupID": groupID,
            "eventID": eventID,
            "events": events.makeNode(in: context)])
    }
}

extension GroupEvent: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.parent(Group.self, optional: false)
            builder.parent(Event.self, optional: false)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}
