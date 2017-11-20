import Vapor
import AuthProvider

public final class JoinClassController {
    
    let view: ViewRenderer
    
    init(_ view: ViewRenderer) {
        self.view = view
    }
    
    //Teacher submit student
    //GET classes/#(class.id)
    func studentJoin(request: Request) throws -> ResponseRepresentable {
        let classID = try request.parameters.next(Int.self)
        let classroom = try Class.find(classID)
        
        return try render("Classes/join-in-class", ["classroom" : classroom], for: request, with: view)
    }
    
    //GET /classes/class.id/join
//    func submitClass(request: Request) throws -> ResponseRepresentable {
//        let classID = try request.parameters.next(Class.self)
//        
//        guard let user = request.user, classID.isVisible(to: user) else {
//            throw Abort.unauthorized
//        }
//        
//        let sql: String = [
//            "SELECT p.*, ep.status, IFNULL(s.score,0) score, IFNULL(s.attempts,0) attempts",
//            "FROM class_users ep",
//            "JOIN users p ON ep.user_id = p.id",
//            "LEFT JOIN (",
//            "SELECT s.user_id, s.class_user_id, MAX(s.score) score, COUNT(1) attempts",
//         //   "FROM submissions s",
//            "GROUP BY user_id, class_user_id) s ON ep.id = s.class_user_id AND s.class_id = ?",
//            "WHERE ep.user_id = ?",
//            "ORDER BY ep.status"
//            ].joined(separator: " ")
//        
//        let users = try Class.database!.raw(sql, [user.id!, classID.id!])
//        
//        return try render("Classes/join-class", [
//            "classID": classID,
//            "userID": user
//            ], for: request, with: view)
//    }
    
    
}


