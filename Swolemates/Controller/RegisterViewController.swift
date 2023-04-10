import UIKit
import Supabase


class RegisterViewController : UIViewController {
    
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var passWord: UITextField!
        
    override func viewDidLoad() {
        super.viewDidLoad()
       
    }
    
    @IBAction func registerPressed(_ sender: UIButton) {
        if let username = userName.text , let password = passWord.text{
            let supUsers = UsersTable()
            let client = supUsers.client
            
            Task.init(operation: {
                do{
                    try await client.auth.signUp(email: username, password: password)
                    
                    var user = User()
                    user.username = username
                    
                    try await supUsers.insert(client, user)
                   
                    performSegue(withIdentifier: "toLogin", sender: self)
                }catch{
                    present( ErrorDisplay().errorDisplaying(error.localizedDescription) , animated: true)
                }
            })

        }
        
    }
}
