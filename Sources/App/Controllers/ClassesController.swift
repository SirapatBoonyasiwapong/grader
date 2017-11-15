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
        
        let classes = Class(name: name, events: "", users: "")
        try classes.save()
        
        return Response(redirect: "/")
    }
    
    //GET Join in class
    func joinClass(request: Request) throws -> ResponseRepresentable {
        let className = try request.parameters.next(Class.self)
        return try render("Classes/join-class", ["class": className], for: request, with: view)
    }

    func joinInClass(request: Request) throws -> ResponseRepresentable {
        let className = try request.parameters.next(Class.self)
        let user = try User.all()
        
        return try render("Classes/join-in-class", ["class": className, "users": user], for: request, with: view)

    }
    
    func acceptUser(request: Request) throws -> ResponseRepresentable {
        let userID = try request.parameters.next(Int.self)
        if let user = try Class.find(userID){
             let user = request.data["user"]?.string
             let classes = Class(name: "", events: "", users: user!)
             try classes.save()
        }
             return Response(redirect: "/classes/#(class.id)/join")
    
}
    
    func cancelUser(request: Request) throws -> ResponseRepresentable {
        let userID = try request.parameters.next(Int.self)
        if let user = try Class.find(userID){
            try user.delete()
        }
        
        return Response(redirect: "/classes/#(class.id)/join")
    }
}


