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
        let classroom = try request.parameters.next(Class.self)
        //if let userID =
                
        return try render("Classes/join-in-class", ["classroom" : classroom], for: request, with: view)
    }
    
    func submitStudent(request: Request) throws -> ResponseRepresentable {
        let classroom = try request.parameters.next(ClassUser.self)
        return try render("Classes/", [:], for: request, with: view)
        
        
        //ถ้ากดรับแล้ว ให้แสดงคำว่า joined
        //if accept 
    }
    
    
    
   
}


