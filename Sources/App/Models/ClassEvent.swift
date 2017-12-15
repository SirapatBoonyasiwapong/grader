import Foundation
import FluentProvider

final class ClassEvent: Model, NodeRepresentable {
    
    var classID: Identifier
    var eventID: Identifier
    
    
    var classroom: Parent<ClassEvent, Class> {
        return parent(id: classID)
    }
    
    var events: Parent<ClassEvent, Event> {
        return parent(id: eventID)
    }
    
    let storage = Storage()
    
    init(row: Row) throws {
        classID = try row.get("class_id")
        eventID = try row.get("event_id")
    }
    
    init(classID: Identifier, eventID: Identifier) {
        self.classID = classID
        self.eventID = eventID
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("class_id", classID)
        try row.set("event_id", eventID)
        
        return row
    }
    
    func makeNode(in context: Context?) throws -> Node {
        let events = try self.events.get()
        return try Node(node: [
            "id": id!.string!,
            "classID": classID,
            "eventID": eventID,
            "events": events.makeNode(in: context)])
    }
}

extension ClassEvent: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.parent(Class.self, optional: false)
            builder.parent(Event.self, optional: false)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}
