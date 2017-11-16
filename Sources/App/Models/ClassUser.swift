import Foundation
import FluentProvider

final class ClassUser: Model, NodeRepresentable {
    
    var classID: Identifier
    var userID: Identifier
    var identity: Int
    
    var `class`: Parent<ClassUser, Class> {
        return parent(id: classID)
    }
    
    var user: Parent<ClassUser, User> {
        return parent(id: userID)
    }
    
    var joinClass: Student<ClassUser, JoinClass> {
        return student()
    }
    
    let storage = Storage()
    
    init(row: Row) throws {
        classID = try row.get("class_id")
        userID = try row.get("user_id")
        identity = try row.get("identity")
    }
    
    init(classID: Identifier, userID: Identifier, identity: Int) {
        self.classID = classID
        self.userID = userID
        self.identity = identity
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("class_id", classID)
        try row.set("user_id", userID)
        try row.set("identity", identity)
        return row
    }
    
    func makeNode(in context: Context?) throws -> Node {
        let user = try self.user.get()
        return try Node(node: [
            "id": id!.string!,
            "classID": classID,
            "userID": userID,
            "identity": identity,
            "user": user.makeNode(in: context)])
    }
}
}
