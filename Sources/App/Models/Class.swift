import FluentProvider

final class Class: Model {
    var name: String
    var events: String
    var users: String
    
    let storage = Storage()
    
    init(row: Row) throws {
        name = try row.get("name")
        events = try row.get("events")
        users = try row.get("users")
        
    }
    
    init(name: String, events: String, users: String) {
        self.name = name
        self.events = events
        self.users = users
        
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("name", name)
        try row.set("events", events)
        try row.set("users", users)
        
        return row
    }
}


extension Class: NodeRepresentable {
    func makeNode(in context: Context?) throws -> Node {
        var node = Node(context)
        try node.set("name", name)
        try node.set("events", events)
        try node.set("users", users)
        
        
        return node
    }
}

extension Class: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string("name")
            builder.string("events")
            builder.string("users")
            
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}
