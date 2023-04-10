//
//  MyWorkoutTableViewController.swift
//  Swolemates
//
//  Created by Apple on 12/21/22.
//

import Foundation
import UIKit
import CoreData
import ChameleonFramework

class MyWorkoutTableViewController: SwipeTableViewController {
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("Workouts.plist")
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private var workouts = [WorkOut]()
    
    var selectedDay : Day? {
        didSet{
            loadItems()
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadItems()
        
        
       // tableView.reloadData()
    
    }
    override func viewWillAppear(_ animated: Bool) {
    
            title = selectedDay!.name
        
            }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return workouts.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.textLabel?.text = workouts[indexPath.row].title
        cell.accessoryType = workouts[indexPath.row].done ? .checkmark : .none
        
        if let color = UIColor(hexString: selectedDay!.color!)?.darken(byPercentage: CGFloat(indexPath.row)/CGFloat(workouts.count)){
            cell.backgroundColor = color
            cell.textLabel?.textColor = ContrastColorOf(cell.backgroundColor ?? FlatBlack(), returnFlat: true)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        workouts[indexPath.row].done = !workouts[indexPath.row].done
            
        tableView.deselectRow(at: indexPath, animated: true)
        saveItems()
        
    }
    
    @IBAction func addPressed(_ sender: Any) {
        var textField = [UITextField(),UITextField()]
        let alert = UIAlertController(title: "New workout", message: "Enter new workout", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add", style: .default) { action in

            let newItem = WorkOut(context: self.context)

            newItem.title = textField[0].text!
            newItem.done = false
            newItem.dateCreated = Date()
            newItem.parentDays = self.selectedDay
            
            self.workouts.append(newItem)
            self.saveItems()
            self.loadItems()
        }
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Enter the name"

            textField[0] = alertTextField
        }
    
        
        
//        alert.addTextField { alertTextField in
//            alertTextField.placeholder = "Enter the day"
//
//            textField[1] = alertTextField
//        }
//        alert.addTextField { alertTextField in
//            alertTextField.placeholder = "Enter the duration in day"
//
//            textField[2] = alertTextField
//        }

        alert.addAction(action)
        present(alert, animated: true)

       // query()
        
    }
    
//MARK: - Mode Manupulation Methods
    
    func saveItems() {
        do{
            try context.save()
        }catch{print("errrrr\(error)")}
        self.tableView.reloadData()
            }
    
    func loadItems()  {
        let request: NSFetchRequest<WorkOut> = WorkOut.fetchRequest()
        let predicate = NSPredicate(format: "parentDays.name MATCHES %@", selectedDay!.name!)
        
        request.predicate = predicate
        
        request.sortDescriptors = [NSSortDescriptor(key: "dateCreated", ascending: false)]
        do{
           workouts = try context.fetch(request)
        }catch{
            print(error)
        }
        
    }
    
    override func updateModel(at indexPath: IndexPath) {
        context.delete(workouts[indexPath.row])
        workouts.remove(at: indexPath.row)
        try! context.save()
    }

//MARK : - Search Method
//    func query() {
//        let request : NSFetchRequest<WorkOut> = WorkOut.fetchRequest()
//        request.predicate = NSPredicate(format: "title CONTAINS[cd] %@", "h")
//        do{
//            workouts = try context.fetch(request)
//        }catch{
//            print(error)
//        }
//        tableView.reloadData()
//    }




}
 
