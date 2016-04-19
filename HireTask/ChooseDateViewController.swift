//
//  ChooseDateViewController.swift
//  HireTask
//
//  Created by Имал Фарук on 18.04.16.
//  Copyright © 2016 Имал Фарук. All rights reserved.
//

import UIKit


class ChooseDateViewController: UIViewController {
    var dateSting : String?
    let dateFormatter = NSDateFormatter()
    
    //DatePicker для выбора даты
    @IBOutlet weak var datePicker: UIDatePicker!

    //Кнопка отмены
    @IBAction func cancelButton(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //Кнопка "Готово" сохраняет новую дату, отправляет уведомление, что дата изменилась и нужно обновить ее
    @IBAction func doneButton(sender: UIButton) {
        NSUserDefaults.standardUserDefaults().setObject(dateSting, forKey: "DateLabel")
        NSNotificationCenter.defaultCenter().postNotificationName("LoadDateLabel", object: nil)
        //Выход из данного view
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
  
    override func viewDidLoad() {
        super.viewDidLoad()
        //Выбираем режим отображения dataPicker'a, в данном случае это дата
        datePicker.datePickerMode = UIDatePickerMode.Date
        //Отслеживаем событие, когда значение dataPicker'a изменяется, после чего выполнится селектор
        datePicker.addTarget(self, action: #selector(datePickerChangeAction), forControlEvents: UIControlEvents.ValueChanged)
        
        //Устанавливаем формат отображения даты на российский лад
        dateFormatter.dateFormat = "dd-MM-YYYY"
        
        
        
    }
    
    @IBAction func datePickerChangeAction(sender: UIDatePicker) {
        //Если значение datePicker'a меняется, то присваиваем его переменной
        dateSting = dateFormatter.stringFromDate(sender.date)
    }
    
    
}
