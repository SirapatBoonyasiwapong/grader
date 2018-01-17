import Foundation
import FluentProvider

final class Class: Model {
    var name: String
    var ownerID: Identifier
    
    let storage = Storage()
    static let entity = "classes"
    
    init(row: Row) throws {
        name = try row.get("name")
        ownerID = try row.get("ownerID")
        
    }
    
    init(name: String, ownerID: Identifier) {
        self.name = name
        self.ownerID = ownerID
        
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("name", name)
        
        return row
    }
}


extension Class: NodeRepresentable {
    func makeNode(in context: Context?) throws -> Node {
        var node = Node(context)
        try node.set("id", id?.string ?? "")
        try node.set("name", name)

        return node
    }
}

extension Class: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string("name")
            builder.int("ownerID")
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
    
    func isVisible(to user: User) -> Bool {
        let isMember = ((try? ClassUser.makeQuery().filter("user_id", user.id!).count()) ?? 0) > 0
        return user.has(role: .admin) || user.id ==  ownerID || isMember
    }
    
    
}
