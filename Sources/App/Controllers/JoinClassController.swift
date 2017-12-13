import Vapor
import AuthProvider

public final class JoinClassController {
    
    let view: ViewRenderer
    
    init(_ view: ViewRenderer) {
        self.view = view
    }
 
    //GET Join in class Teacher
    func showUserInClass(request: Request) throws -> ResponseRepresentable {
        
        let classObj = try request.parameters.next(Class.self)
        let classUsers = try ClassUser.makeQuery().filter("class_id", classObj.id!).all()
        
        return try render("Classes/join-in-class", ["class": classObj, "classUsers": classUsers], for: request, with: view)
    }
    
    //GET Accept user
    func acceptUser(request: Request) throws -> ResponseRepresentable {
        
        let classObj = try request.parameters.next(Class.self)
        let user = try request.parameters.next(User.self)
        
        if let classUser = try ClassUser.makeQuery().filter("class_id", classObj.id!).filter("user_id", user.id!).first() {
            classUser.status = "Joined"
            try classUser.save()
        }
        
        return Response(redirect:"/classes/\(classObj.id!.string!)")
    }
    
    //Get Delete user
    func deleteUser(request: Request) throws -> ResponseRepresentable {
        
        let classObj = try request.parameters.next(Class.self)
        let user = try request.parameters.next(User.self)
        
        try ClassUser.makeQuery().filter("class_id", classObj.id!).filter("user_id", user.id!).delete()
        
        return Response(redirect: "/classes/\(classObj.id!.string!)")
    }
    
    //scores in class
    func rankingClass(request: Request) throws -> ResponseRepresentable {
        
        let classObj = try request.parameters.next(Class.self)
        
        guard let user = request.user, classObj.isVisible(to: user) else {
            throw Abort.unauthorized
        }
        
        let scores = try User.database!.raw("SELECT x.user_id, u.name, SUM(x.score) score, SUM(x.attempts) attempts, COUNT(1) problems FROM users u JOIN (SELECT s.user_id, s.event_problem_id, MAX(s.score) score, COUNT(1) attempts FROM submissions s JOIN class_users cu ON cu.class_user_id = cu.id JOIN classes c ON cu.class_id = c.id JOIN event_problems ep ON s.event_problem_id = ep.id JOIN events e ON ep.event_id = e.id WHERE ep.event_id = ? AND (s.created_at > e.starts_at OR e.starts_at is null) AND (s.created_at < e.ends_at OR e.ends_at is null) GROUP BY user_id, event_problem_id) x ON u.id = x.user_id WHERE u.role = 1 GROUP BY x.user_id, u.name ORDER BY score DESC, attempts ASC, problems DESC", [classObj.id!])
        
        return try render("Classes/class-ranking",["class": classObj, "scores": scores], for: request, with: view)
        
    }
}



