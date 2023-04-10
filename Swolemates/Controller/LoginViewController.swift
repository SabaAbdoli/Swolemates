//
//  Swolemates
//


import Foundation
import UIKit
import Supabase

class LoginViewController: UIViewController {
    
    @IBOutlet weak var userName: UITextField!
    
    @IBOutlet weak var passWord: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func loginPressed(_ sender: UIButton) {
        
        
        if let username = userName.text , let password = passWord.text{
            
            let client = UsersTable().client
            
            Task.init {
                do{
                    try await client.auth.signIn(email: username, password: password)
                    performSegue(withIdentifier: "LoginTochat", sender: self)
                    
                }catch{
                    present(ErrorDisplay().errorDisplaying(error.localizedDescription ), animated: true)}
            }
        }
        
    }
    
    
}

