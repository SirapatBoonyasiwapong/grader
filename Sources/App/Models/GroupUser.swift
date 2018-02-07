import Foundation
import FluentProvider

final class GroupUser: Model, NodeRepresentable {
    
    var groupID: Identifier
    var userID: Identifier
    var status: String
 
    var classes: Parent<GroupUser, Group> {
        return parent(id: groupID)
    }
    
    var user: Parent<GroupUser, User> {
        return parent(id: userID)
    }
    
    let storage = Storage()
    
    init(row: Row) throws {
        groupID = try row.get("group_id")
        userID = try row.get("user_id")
        status = try row.get("status")

    }
    
    init(groupID: Identifier, userID: Identifier, status: String) {
        self.groupID = groupID
        self.userID = userID
        self.status = status
     
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("group_id", groupID)
        try row.set("user_id", userID)
        try row.set("status", status)

        return row
    }
    
    func makeNode(in context: Context?) throws -> Node {
        let user = try self.user.get()
        return try Node(node: [
            "id": id!.string!,
            "groupID": groupID,
            "userID": userID,
            "status": status,
            "user": user.makeNode(in: context)])
    }
}


extension GroupUser: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.parent(Group.self, optional: false)
            builder.parent(User.self, optional: false)
            builder.string("status")
            
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }

}
