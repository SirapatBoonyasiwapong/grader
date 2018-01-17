import Vapor
import HTTP
import AuthProvider
import Flash

final class LoginController {
    
    let homepage = "/classes"
    
    let view: ViewRenderer
    
    init(_ view: ViewRenderer) {
        self.view = view
    }
    
    /// Landing
    ///
    /// - Parameter request: Request
    /// - Returns: Response
    public func landing(request: Request) -> Response {
        if request.auth.isAuthenticated(User.self) {
            return Response(redirect: homepage)
        }
        else {
            return Response(redirect: "/login")
        }
    }
    
    /// Login page
    public func loginForm(request: Request) throws -> ResponseRepresentable {
        return try render("Auth/login", for: request, with: view)
    }

    /// Login page submission
    func login(_ request: Request) throws -> ResponseRepresentable {
        
        guard let email = request.data["email"]?.string,
            let password = request.data["password"]?.string else {
                throw Abort.badRequest
        }
        
        let credentials = Password(username: email, password: password)
        do {
            let user = try User.authenticate(credentials)
            try request.auth.authenticate(user, persist: true)
            return Response(redirect: homepage)
        } catch {
            return Response(redirect: "/login").flash(.error, "Wrong email or password.")
        }
    }
    
    /// Register page
    public func registerForm(request: Request) throws -> ResponseRepresentable {
        return try render("Auth/register", for: request, with: view)
    }

    /// Register page submission
    func register(_ request: Request) throws -> ResponseRepresentable {
        guard let email = request.data["email"]?.string,
            let password = request.data["password"]?.string,
     
            let name = request.data["name"]?.string else {
                
                throw Abort.badRequest
        }
        
       // let role = request.data["role"]?.int.flatMap { raw in Role(rawValue: raw) }
        
        let user = User(name: name, username: email, password: password, role: .student)
       // let user = User(name: name, username: email, password: password, role: role!)
        try user.save()
        
        
        if let imageUser = request.formData?["image"] {
            let path = "\(uploadPath)\(user.id!.string!).jpg"
            _ = save(bytes: imageUser.bytes!, path: path)
        }
        
        
        let credentials = Password(username: email, password: password)
        do {
            let user = try User.authenticate(credentials)
            try request.auth.authenticate(user, persist: true)
            return Response(redirect: homepage)
        } catch {
            
            return Response(redirect: "/register").flash(.error, "Something bad happened.")
        }
    }
    
    func changePasswordForm(request: Request) throws -> ResponseRepresentable {

        return try render("change-password", [:], for: request, with: view)

    }
    
    func changePassword(request: Request) throws -> ResponseRepresentable {
        guard let oldPassword = request.data["oldpassword"]?.string,
            let newPassword = request.data["newpassword"]?.string,
            let confirmPassword = request.data["confirmpassword"]?.string else {
                throw Abort.badRequest
        }
        
        let user = request.user!
        
        guard let verifier = User.passwordVerifier,
            let oldHashedPassword = user.hashedPassword,
            let oldPasswordMatches = try? verifier.verify(password: oldPassword.makeBytes(), matches: oldHashedPassword.makeBytes()) else {
            throw Abort.serverError
        }
        
        if !oldPasswordMatches {
            return Response(redirect: "/changepassword").flash(.error, "Incorrect existing password")
        }
        
//        if !User.passwordMeetsRequirements(newPassword) {
//            return Response(redirect: "/changepassword").flash(.error, "Password does not meet requirements (4 or more characters)")
//        }
    
        if newPassword != confirmPassword {
            return Response(redirect: "/changepassword").flash(.error, "New password does not match confirmed password")
        }
        user.setPassword(newPassword)
        try user.save()
        
        return Response(redirect: "/profile")
    }
}
    

