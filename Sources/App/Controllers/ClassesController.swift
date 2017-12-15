import Vapor
import AuthProvider

public final class ClassesController {
    
    let view: ViewRenderer
    
    init(_ view: ViewRenderer) {
        self.view = view
    }
    
    //Show class
    func showClasses(request: Request) throws -> ResponseRepresentable {
        let classes = try Class.all()
        return try render("Classes/classes", ["classes": classes], for: request, with: view)

    }
    
    //GET Create class
    func createClassForm(request: Request) throws -> ResponseRepresentable {
        
        return try render("Classes/class-new", [:], for: request, with: view)

    } 
    
    //POST Create class
    func classForm(request: Request) throws -> ResponseRepresentable {
        guard let name = request.data["name"]?.string
            
            else{
                
                throw Abort.badRequest
        }
        let classes = Class(name: name, events: "", users: "", ownerID: request.user!.id!)
        try classes.save()
        
        return Response(redirect: "/")
    }
    
    //GET Show all the events for a class
    func showClassEvents(request: Request) throws -> ResponseRepresentable {
        
        let classObj = try request.parameters.next(Class.self)
        
        let events = try Event.makeQuery().join(ClassEvent.self, baseKey: "id", joinedKey: "event_id").filter(ClassEvent.self, "class_id", classObj.id!).all()
        
        return try render("Classes/events", ["class": classObj, "events": events], for: request, with: view)
    }
    
    //GET Show all the students in the class
    func showClassUsers(request: Request) throws -> ResponseRepresentable {

        let classObj = try request.parameters.next(Class.self)
        
        let classUser = try ClassUser.makeQuery().filter("user_id", request.user!.id!)
            .filter("class_id", classObj.id!).first()
        
        return try render("Classes/join-class", ["class": classObj, "classUser": classUser], for: request, with: view)
    }
    
    //GET Join class status waiting
    func joinClass(request: Request) throws -> ResponseRepresentable {
        
        let classObj = try request.parameters.next(Class.self)
        
        let classUserObj = ClassUser(classID: classObj.id!, userID: request.user!.id!, status: "Waiting")
        try classUserObj.save()
        
        return Response(redirect: "/classes/\(classObj.id!.string!)")
        
    }
    
    //GET Show all the events for a class
    func showClassRanking(request: Request) throws -> ResponseRepresentable {
        
        let classObj = try request.parameters.next(Class.self)
        
        guard let user = request.user, classObj.isVisible(to: user) else {
            throw Abort.unauthorized
        }
        
        let scores = try User.database!.raw("SELECT x.user_id, u.name, SUM(x.score) score, SUM(x.attempts) attempts, COUNT(1) problems FROM users u JOIN (SELECT s.user_id, s.event_problem_id, MAX(s.score) score, COUNT(1) attempts FROM submissions s JOIN class_users cu ON cu.user_id = s.user_id JOIN classes c ON cu.class_id = c.id JOIN event_problems ep ON s.event_problem_id = ep.id JOIN events e ON ep.event_id = e.id WHERE cu.class_id = ? AND (s.created_at > e.starts_at OR e.starts_at is null) AND (s.created_at < e.ends_at OR e.ends_at is null) AND (s.language = e.language_restriction OR e.language_restriction is null) GROUP BY s.user_id, event_problem_id) x ON u.id = x.user_id WHERE u.role = 1 GROUP BY x.user_id, u.name ORDER BY score DESC, attempts ASC, problems DESC", [classObj.id!])
        
        return try render("Classes/class-ranking", ["class": classObj, "scores": scores], for: request, with: view)
    }
}


