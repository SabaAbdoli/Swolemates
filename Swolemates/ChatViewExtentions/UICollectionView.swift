//
//  UICollectionView.swift
//  Swolemates
//
//  Created by Apple on 4/9/23.
//

import Foundation
import UIKit
//let supUsers = QueryFromUsersTable()
//let client = supUsers.client

extension ChatViewController : UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ChatViewController().members.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        collectionView.register(UINib(nibName: "MemberCell", bundle: nil), forCellWithReuseIdentifier: "ReusableCollCell")
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReusableCollCell", for: indexPath) as! MemberCell
        cell.label.text = members[indexPath.row].username
        return cell
        
    }
}
