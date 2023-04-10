//
//  ErrorDisplay.swift
//  Swolemates
//
//  Created by Apple on 4/5/23.
//

import UIKit

struct ErrorDisplay {
    
    func errorDisplaying(_ error: String) -> UIAlertController{
    let alert = UIAlertController(title: "", message: "\(error)", preferredStyle: .alert)
        
    let closeAct = UIAlertAction(title: "Close", style: .default) { action in
        alert.dismiss(animated: true)
    }
    
    alert.addAction(closeAct)
    return alert
}
}
