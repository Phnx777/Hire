//
//  CustomTableViewCell.swift
//  HireTask
//
//  Created by Имал Фарук on 17.04.16.
//  Copyright © 2016 Имал Фарук. All rights reserved.
//

import UIKit
//Класс, описывающий кастомную ячейку
class CustomTableViewCell: UITableViewCell {
    
    @IBOutlet weak var stationNameLabel: UILabel!
    @IBOutlet weak var stationInfo: UILabel!
    @IBOutlet weak var placeInfo: UILabel!
   
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        //Указываем свойство, которое автоматически уменьшает шрифт Label'a, если название будет слишком длинное и не влезет в Label
        stationInfo.adjustsFontSizeToFitWidth = true
        stationNameLabel.adjustsFontSizeToFitWidth = true
        placeInfo.adjustsFontSizeToFitWidth = true
    }
    
}
