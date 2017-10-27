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
    func classForm(request: Request) throws ->  ResponseRepresentable {
        guard let name = request.data["name"]?.string,
        let events = request.data["events"]?.string else {
            throw Abort.badRequest
        }
        
        let classes = Class(name: name, events: events)
        try classes.save()
        
        return Response(redirect: "/classes")
    }
    
}
