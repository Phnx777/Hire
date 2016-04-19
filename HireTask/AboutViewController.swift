//
//  AboutViewController.swift
//  HireTask
//
//  Created by Имал Фарук on 18.04.16.
//  Copyright © 2016 Имал Фарук. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {

    @IBOutlet weak var worthyLabel: UILabel!
    
    override func viewDidLoad() {
        worthyLabel.adjustsFontSizeToFitWidth = true
    }
}
