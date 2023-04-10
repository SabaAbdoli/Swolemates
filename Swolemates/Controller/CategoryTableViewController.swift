//
//  CategoryTableViewController.swift
//  Swolemates
//


import UIKit
import CoreData
import ChameleonFramework

class CategoryTableViewController: SwipeTableViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private var days = [Day]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadDays()
        
        tableView.separatorStyle = .none
    }
    
    
    @IBAction func addPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add Day", message: "Add a Day", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add", style: .default) { [self] action in
            let newDay = Day(context: context)
            newDay.name = textField.text
            newDay.color = UIColor.randomFlat().hexValue()
            days.append(newDay)
            
            saveDay()
        }
        alert.addTextField{ alertTextField in
            alertTextField.placeholder = "Enter a day"
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true)
        
    }
    
    //MARK: -TableView DataSource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return days.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        cell.textLabel?.text = days[indexPath.row].name
        
        cell.backgroundColor = UIColor(hexString: days[indexPath.row].color!)
        
        cell.textLabel?.textColor = ContrastColorOf(UIColor(hexString: days[indexPath.row].color!) ?? FlatBlack(), returnFlat: true)
        
        return cell
    }
    
    //MARK: -TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "goToWorkoutsOfThatDay", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! MyWorkoutTableViewController
        
        if let indexPath = tableView.indexPathForSelectedRow{
            destinationVC.selectedDay = days[indexPath.row]
        }
    }
    
    //MARK: -Data Manipulation
    func saveDay() {
        do{
            try context.save()
        }catch{
            present(ErrorDisplay().errorDisplaying(error.localizedDescription),animated: true)
        }
        tableView.reloadData()
    }
    func loadDays() {
        let request: NSFetchRequest<Day> = Day.fetchRequest()
        do{
            days = try context.fetch(request)
            
        }catch{
            present(ErrorDisplay().errorDisplaying(error.localizedDescription),animated: true)
        }
        tableView.reloadData()
    }
    
    
    override func updateModel(at indexPath: IndexPath) {
        context.delete(days[indexPath.row])
        days.remove(at: indexPath.row)
        do {
            try context.save()
        }catch{
            present(ErrorDisplay().errorDisplaying(error.localizedDescription),animated: true)
        }
    }
    
    
}



