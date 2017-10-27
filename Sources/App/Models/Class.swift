import FluentProvider

final class Class: Model {
    var name: String
    var events: String

    let storage = Storage()
    
    init(row: Row) throws {
        name = try row.get("name")
        events = try row.get("events")
    
    }
    
    init(name: String, events: String) {
        self.name = name
        self.events = events

    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("name", name)
        try row.set("events", events)
   
        return row
    }
}


extension Class: NodeRepresentable {
    func makeNode(in context: Context?) throws -> Node {
        var node = Node(context)
        try node.set("name", name)
        try node.set("events", events)
      
        
        return node
    }
}

extension Class: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string("name")
            builder.string("events")
        
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}




