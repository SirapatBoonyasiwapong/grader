import Foundation
import FluentProvider

final class ClassUser: Model, NodeRepresentable {
    
    var classID: Identifier
    var userID: Identifier
    var status: String

    
    var classroom: Parent<ClassUser, Class> {
        return parent(id: classID)
    }
    
    var user: Parent<ClassUser, User> {
        return parent(id: userID)
    }
    
    let storage = Storage()
    
    init(row: Row) throws {
        classID = try row.get("class_id")
        userID = try row.get("user_id")
        status = try row.get("status")

    }
    
    init(classID: Identifier, userID: Identifier, status: String) {
        self.classID = classID
        self.userID = userID
        self.status = status
     
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("class_id", classID)
        try row.set("user_id", userID)
        try row.set("status", status)

        return row
    }
    
    func makeNode(in context: Context?) throws -> Node {
        let user = try self.user.get()
        return try Node(node: [
            "id": id!.string!,
            "classID": classID,
            "userID": userID,
            "status": status,
            "user": user.makeNode(in: context)])
    }
}
