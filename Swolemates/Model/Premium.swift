//
//  Premium.swift
//  Swolemates
//
//  Created by Apple on 4/9/23.
//

import Foundation
import StoreKit

struct Premium {
    let productID = "ProductID"
    
    func buy() {
        if SKPaymentQueue.canMakePayments(){
            let paymentReq = SKMutablePayment()
            paymentReq.productIdentifier = productID
            SKPaymentQueue.default().add(paymentReq)
        }
    }
}
