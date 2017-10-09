import Vapor
import AuthProvider

public final class ProfileController {
    
    let view: ViewRenderer
    
    init(_ view: ViewRenderer) {
        self.view = view
    }
    
    /**
     * Logout, will logout auther user and redirect back to login
     *
     * - param: Request
     * - return: Response
     */
    public func logout(request: Request) throws -> ResponseRepresentable {
        try request.auth.unauthenticate()
        return Response(redirect: "/").flash(.error, "User is logged out")
    }

        
    func profile(request: Request) throws -> ResponseRepresentable {
        let user = request.user!
        return try render("profile", ["user": user], for: request, with: view)
    }
    
    func editForm(request: Request) throws -> ResponseRepresentable {
        
        let user = request.user!
        return try view.make("edit-user", ["editUser": user])
    }
    
    func edit(request: Request) throws -> ResponseRepresentable {
        guard let name =  request.data["name"]?.string,
            let username =  request.data["username"]?.string,
            let password =  request.data["password"]?.string else {
                throw Abort.badRequest
                
        }
        
        // get the Post model and save to DB

        let user = request.user!
        user.name = name
        user.username = username
        if password != "" {
            user.setPassword(password)
        }
        try user.save()
        
        return Response(redirect: "/profile")
        
    }
  
}