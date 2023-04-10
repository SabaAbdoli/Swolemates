//
//  StartViewController.swift
//  Swolemates
//
//  Created by Apple on 12/14/22.
//

import Foundation
import UIKit

class StartViewController: UIViewController {
    
    @IBOutlet weak var workouttLabel: UILabel!
    private var i : Double = 1
    
    override func viewDidLoad() {
        
        for letter in "🧗Workout Together!"
        {
            Timer.scheduledTimer(withTimeInterval: 0.1*i, repeats: false) { timer in
                self.workouttLabel.text?.append(letter)
            
            }
            i+=1
        }
    }

}

