import Vapor
import AuthProvider

public final class ClassesController {
    
    let view: ViewRenderer
    
    init(_ view: ViewRenderer) {
        self.view = view
    }
    
    //Create class
    func createClass(request: Request) throws -> ResponseRepresentable {
        
        return try render("create-class", [:], for: request, with: view)

    }
  
    
}

