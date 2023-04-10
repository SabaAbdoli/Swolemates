//
//  ViewController.swift
//  Swolemates
//


import UIKit
import Supabase
import RealmSwift
import ChameleonFramework


class ListViewController: SwipeTableViewController {
    let client = SupabaseClient(supabaseURL: URL(string: Constants.urlString)!, supabaseKey: Constants.apiKey )
    
    let realm = try! Realm()
    
    private var groupsArray: Results<Group>!
    
    private var groupArray: [GroupSupa] = []
    
    //var me: User!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        loadGroups()
    }
    
    //MARK: - logout
    @IBAction func logOutPressed(_ sender: UIBarButtonItem) {
        Task.init {
            do{
                try await client.auth.signOut()
                navigationController?.popToRootViewController(animated: true)
            }catch{
                present(ErrorDisplay().errorDisplaying(error.localizedDescription), animated: true)
            }
        }
    }
        
    //MARK: - Add New group
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "New Group", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add", style: .default) { [self] action in
            let newGroup = Group()
            newGroup.color = UIColor.randomFlat().hexValue()
            newGroup.name = textField.text!
            saveGroup(newGroup)
            
        }
        let closeAct = UIAlertAction(title: "Close", style: .default) { action in
            alert.dismiss(animated: true)
        }
        
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Enter a group ID"
            
            textField = alertTextField
        }
        
        alert.addAction(closeAct)
        alert.addAction(action)
        present(alert, animated: true)
    }
    
    //MARK: - Tableview Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (groupArray.count)-1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.textLabel?.text = groupArray[indexPath.row+1].groupID
        cell.textLabel?.textColor = ContrastColorOf(UIColor(hexString: groupsArray[indexPath.row].color)!, returnFlat: true)
        cell.backgroundColor = UIColor(hexString: groupsArray[indexPath.row].color)
        return cell
    }
    
    
    //MARK: - Tableview Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "ToSession", sender: self)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destinationVC = segue.destination as! ChatViewController
        
        if let indexPath = tableView.indexPathForSelectedRow{
            destinationVC.selectedGroup = groupArray[indexPath.row+1]
        }
    }
    //MARK: - Data Manipulation
    func saveGroup(_ newGroup: Group) {
        var user = User()
        user.username = client.auth.session?.user.email
        user.groupID = newGroup.name
        
        Task.init{
            do{
                
                let newGP = try await client.database.from("users").select().eq(column: "groupID", value: newGroup.name).execute().decoded(to: [User].self)
                
                try await client.database.from("users").insert(values: user).execute()
                
                if newGP.isEmpty{
                    let initialMessage = Message(body: "This group was created by \(user.username ?? "")", sender: user.username, groupID: newGroup.name)
                    
                    try await client.database.from("Message").insert(values: initialMessage).execute()
                }
                
                try realm.write {
                    realm.add(newGroup)}
                loadGroups()
                
            }catch{
                present(ErrorDisplay().errorDisplaying(error.localizedDescription), animated: true)}
        }
        
    }
    func delGroup(_ deletingGroup: Group) {
        var user = User()
        user.username = client.auth.session?.user.email
        user.groupID = deletingGroup.name
        
        Task.init{
            do{
                try await client.database.from("users").delete().eq(column: "username", value: user.username!).eq(column: "groupID", value: user.groupID!).execute()
            }catch{
                present(ErrorDisplay().errorDisplaying(error.localizedDescription), animated: true)}
        }
        
    }
    
    func loadGroups() {
        groupsArray = realm.objects(Group.self)
        
        Task.init{
            do{
                
                groupArray = try await client.database.from("users").select(columns: "groupID").equals(column: "username", value: (client.auth.session?.user.email)!).order(column: "created_at").execute().decoded(to: [GroupSupa].self)
                
                if groupArray.count>groupsArray.count {
                    for i in groupsArray.count...groupArray.count-1 {
                        let newGroup = Group()
                        newGroup.color = UIColor.randomFlat().hexValue()
                        newGroup.name = groupArray[i].groupID!
                        try realm.write {
                            realm.add(newGroup)}
                    }
                    
                }
                tableView.reloadData()
                
            }catch{
                present(ErrorDisplay().errorDisplaying(error.localizedDescription), animated: true)
            }
            
        }
        
    }
    
    override func updateModel(at indexPath: IndexPath) {
        let DeletingGroup = groupsArray[indexPath.row]
        
        do{
            try realm.write{
                delGroup(DeletingGroup)
                realm.delete(DeletingGroup)
                groupArray.remove(at: indexPath.row)
                
                
            }
            
        }catch{
            present(ErrorDisplay().errorDisplaying(error.localizedDescription), animated: true)
        }
    }
}











