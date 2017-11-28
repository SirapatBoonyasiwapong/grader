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
    
    //GET Join in class Student
    func joinClass(request: Request) throws -> ResponseRepresentable {

        let className = try request.parameters.next(Class.self)
        
        guard let user = request.user, className.isVisible(to: user) else {
            throw Abort.unauthorized
        }
        var query = try JoinClass.makeQuery()
            .join(ClassUser.self, baseKey: "class_user_id", joinedKey: "id")
            .filter(ClassUser.self, "class_id", className.id).sort("created_at", .descending).limit(20)
        
        if user.role == .student{
            query = try query.filter(JoinClass.self, "user_id", request.user!.id)
        }
        
        let joinedClasses = try query.all()
        
        var shouldRefreshPageAutomatically = false
        
        var joinedClass: [Node] = []
        for joinClass in joinedClasses {
            var joinedClasses = try joinClass.makeNode(in: nil)
            let user = try joinClass.user.get()!
            let classroom = try joinClass.classUser.get()!.user.get()!
            joinedClasses["className"] = classroom.name.makeNode(in: nil)
            joinedClasses["userName"] = user.name.makeNode(in: nil)
            joinedClass.append(joinedClasses)
            
//            if joinClass.state == .joined || joinClass.state == .waiting {
//                shouldRefreshPageAutomatically = true
//            }
        }
        return try render("Classes/join-class", ["class": className,
                                                 "joinedClasses": joinedClasses,
                                                 "shouldRefresh": shouldRefreshPageAutomatically],
                          for: request, with: view)
    }
    
    //GET Join in class Teacher
//    func joinInClassTeacher(request: Request) throws -> ResponseRepresentable {
//        let className = try request.parameters.next(Class.self)
//        let user = try User.all()
//        
//        return try render("Classes/join-in-class", ["class": className,"users": user], for: request, with: view)
//
//    }
//    
//    func acceptUser(request: Request) throws -> ResponseRepresentable {
//        let userID = try request.parameters.next(Int.self)
//        if let user = try Class.find(userID){
//             let user = request.data["user"]?.string
//             let classes = Class(name: "", events: "", users: user!)
//             try classes.save()
//        }
//             return Response(redirect: "/classes/#(class.id)/join")
//    
//}
//    
//    func cancelUser(request: Request) throws -> ResponseRepresentable {
//        let userID = try request.parameters.next(Int.self)
//        if let user = try Class.find(userID){
//            try user.delete()
//        }
//        
//        return Response(redirect: "/classes/#(class.id)/join")
//    }
    
}


