//
//  ChatViewController.swift
//  Swolemates
//

import UIKit
import SwiftyGif
import Supabase
import RealmSwift
import StoreKit

class ChatViewController: UIViewController, SKPaymentTransactionObserver, UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var imageView: UIImageView!
    
    let realm = try! Realm()
    
    var selectedGroup : GroupSupa? {
        didSet{
            loadMembersAndMessages()
        }
    }
    
    private var messages: [Message] = []
    private var members: [User]=[]
    
    let client = SupabaseClient(supabaseURL: URL(string: Constants.urlString)! , supabaseKey: Constants.apiKey)
    
    let imagePicker = UIImagePickerController()
    let productID = "ProductID"
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        title = selectedGroup?.groupID
        
        MessageTable().fetchingOnlineData(client)
        chatTableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "ReusableCell")
        
        chatTableView.dataSource = self
        collectionView.dataSource = self
        
        gifLoad()
        
        SKPaymentQueue.default().add(self)
        
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
    }
    
    @IBAction func sendPressed(_ sender: UIButton) {
        
        if let messageBody = messageTextField.text,
           let messageSender = client.auth.session?.user.email{
            messageTextField.text = ""
            
            let message = Message(body: messageBody, sender: messageSender, groupID: selectedGroup?.groupID)
            Task.init {
                do{
                    try await  client.database.from("Message").insert(values: message).execute()
                }catch{
                    present(ErrorDisplay().errorDisplaying(error.localizedDescription), animated: true)
                }
            }
        }else{
            present(ErrorDisplay().errorDisplaying("Messaging Problem.Maybe try again later."), animated: true)
        }
    }
    
    @IBAction func gifPressed(_ sender: UIButton) {
        gifLoad()
    }
    
    func gifLoad()  {
        let urlS = Constants.imageURLBank()
        let url = URL(string: urlS)
        let loader = UIActivityIndicatorView(style: .white)
        imageView.setGifFromURL(url!, customLoader: loader)
        imageView.frame = view.bounds
        view.addSubview(imageView)
    }
    //MARK: - New Member
    @IBAction func addPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "New Member", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add", style: .default) { [self] action in
            Task.init{
                do{
                    try await UsersTable().addMember(textField.text!, client, (selectedGroup?.groupID)!)
                }catch{
                    present( ErrorDisplay().errorDisplaying(error.localizedDescription) , animated: true)}
            }
            self.collectionView.reloadData()
        }
        alert.addTextField{alertTextfield in
            textField = alertTextfield
        }
        alert.addAction(action)
        present(alert, animated: true)
    }
    
    @IBAction func takePhotoPressed(_ sender: UIBarButtonItem) {
        if UserDefaults.standard.bool(forKey: productID) {
            imageView.gifImage = nil
            present(imagePicker, animated: true, completion: nil)
        }else{
            Premium().buy()
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            if transaction.transactionState == .purchased {
                imageView.gifImage = nil
                present(imagePicker, animated: true, completion: nil)
                UserDefaults.standard.set(true, forKey: productID)
                SKPaymentQueue.default().finishTransaction(transaction)
            }else if transaction.transactionState == .failed {
                if let error = transaction.error{
                    present( ErrorDisplay().errorDisplaying(error.localizedDescription) , animated: true)}
                SKPaymentQueue.default().finishTransaction(transaction)
            }else if transaction.transactionState == .restored {
                imageView.gifImage = nil
                present(imagePicker, animated: true, completion: nil)
                UserDefaults.standard.set(true, forKey: productID)
                navigationItem.setRightBarButton(nil, animated: true)
                SKPaymentQueue.default().finishTransaction(transaction)
            }
        }
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.editedImage] as? UIImage{
            imageView.image = image
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func restorePressed(_ sender: UIBarButtonItem) {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    //MARK: - Data Manipulation
    func loadMembersAndMessages(){
        
        client.realtime.onMessage { [self] messagrR in
            async {
                do{
                    (messages, members) = try await MessageTable().loadMessageandMembers(client, (selectedGroup?.groupID!)!)
                    chatTableView.reloadData()
                    collectionView.reloadData()
                    let indexPath = IndexPath(row: messages.count-1, section: 0)
                    chatTableView.scrollToRow(at: indexPath, at: .top, animated: false)
                }catch{
                    present(ErrorDisplay().errorDisplaying(error.localizedDescription),animated: true)
                }
            }
        }
    }
}
//MARK: - ChatView extensions
extension ChatViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = chatTableView.dequeueReusableCell(withIdentifier: "ReusableCell", for: indexPath) as! MessageCell
        if messages[indexPath.row].sender == client.auth.session?.user.email  {
            cell.rightView.isHidden = false
            cell.leftView.isHidden = true
        }else{
            cell.leftView.isHidden = false
            cell.rightView.isHidden = true
            cell.leftImageView.text = messages[indexPath.row].sender
        }
        cell.label.text = messages[indexPath.row].body
        
        return cell
    }
}

extension ChatViewController : UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return members.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        collectionView.register(UINib(nibName: "MemberCell", bundle: nil), forCellWithReuseIdentifier: "ReusableCollCell")
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReusableCollCell", for: indexPath) as! MemberCell
        cell.label.text = members[indexPath.row].username
        return cell
    }
}
