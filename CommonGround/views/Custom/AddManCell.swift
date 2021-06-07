//
//  AddManCell.swift
//  CommonGround
//
//  Created by Gavin Craft on 6/4/21.
//

import UIKit
protocol AddManCellDelegate: AnyObject{
    func addButtonPressed()
}
class AddManCell:UICollectionViewCell{
    weak var delegate: AddManCellDelegate?
    @IBAction func pressButton(_ sender: Any) {
        delegate?.addButtonPressed()
    }
   
}
