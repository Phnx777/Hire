//
//  DetailsTableViewController.swift
//  HireTask
//
//  Created by Имал Фарук on 16.04.16.
//  Copyright © 2016 Имал Фарук. All rights reserved.
//

import UIKit

class DetailsTableViewController: UITableViewController {
    
    var station = [Station]()
    var switchDefaultsString = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //Кнопка "Готово", при нажатии на нее, мы возвращаемся на предыдущее view и еще отправляется уведомление на то, чтобы загрузить новое значение станции в нужном SearchBar'е
    @IBAction func doneBarButton(sender: UIBarButtonItem) {
        if switchDefaultsString == "switchDefaultsFrom" {
            //Отправляем уведомление, что значение станции отправления изменилось и нужно его обновить(см ViewController)
            NSNotificationCenter.defaultCenter().postNotificationName("loadStationTitleDataFrom", object: nil)
        } else if switchDefaultsString == "switchDefaultsTo" {
            //Отправляем уведомление, что значение станции прибытия изменилось и нужно его обновить(см ViewController)
            NSNotificationCenter.defaultCenter().postNotificationName("loadStationTitleDataTo", object: nil)
        }
        
        navigationController!.popViewControllerAnimated(true)
    }

   
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return station.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //При нажатии на ячейку сохраняется название станции, которое относится к данной ячейке
        //Проверяется строка, которая была послана с помощью метода prepareForSegue для того, чтобы узнать, в какой SearchBar сохранять название станции.
        if switchDefaultsString == "switchDefaultsFrom" {
            NSUserDefaults.standardUserDefaults().setObject(station[indexPath.row].stationTitle, forKey: "StationTitleFrom")
        } else if switchDefaultsString == "switchDefaultsTo" {
            NSUserDefaults.standardUserDefaults().setObject(station[indexPath.row].stationTitle, forKey: "StationTitleTo")
        }
    }
    
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellID = "CellStation"
        //Я сделал кастомную ячейку, содержащую 3 поля:
        //Название станции
        //ID станции
        //Ее полный адрес
        let cell = tableView.dequeueReusableCellWithIdentifier(cellID, forIndexPath: indexPath) as! CustomTableViewCell
        cell.stationNameLabel.text = station[indexPath.row].stationTitle
        cell.stationInfo.text = "Идентификационный номер станции: \(station[indexPath.row].stationId)"
        
        //Я немного проглядел json-файл и заметил, что есть станции, у которых нет района или региона, либо и того, и того, поэтому расписал варианты
        if station[indexPath.row].districtTitle != "" && station[indexPath.row].regionTitle != "" {
            //Случай, когда все поля есть: район, город, регион, страна
            cell.placeInfo.text = "район: \(station[indexPath.row].districtTitle), \(station[indexPath.row].cityTitle), регион: \(station[indexPath.row].regionTitle), \(station[indexPath.row].countryTitle)"
        } else if station[indexPath.row].districtTitle == "" && station[indexPath.row].regionTitle != "" {
            //Случай, когда нет района: город, регион, страна
            cell.placeInfo.text = "\(station[indexPath.row].cityTitle), регион: \(station[indexPath.row].regionTitle), \(station[indexPath.row].countryTitle)"
        }  else if station[indexPath.row].districtTitle == "" && station[indexPath.row].regionTitle == "" {
            //Случай, когда нет региона и района: город, страна
            cell.placeInfo.text = "\(station[indexPath.row].cityTitle), \(station[indexPath.row].countryTitle)"
        } else if station[indexPath.row].districtTitle != "" && station[indexPath.row].regionTitle == "" {
            //Случай, когда нет региона: район, город, страна
            cell.placeInfo.text = "район: \(station[indexPath.row].districtTitle), \(station[indexPath.row].cityTitle), \(station[indexPath.row].countryTitle)"
        }

        return cell
    }
    
    //Тоже добавил метод кастомного появления ячеек, так как станций намного меньше и скролить там не особо много, чем городов решил сделать поворот на 90 градусов
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let rotationAngle = CGFloat(M_PI/2)
        let rotationTransform = CATransform3DMakeRotation(rotationAngle, 0, 0, 1)
        cell.layer.transform = rotationTransform
        UIView.animateWithDuration(0.5, animations: {cell.layer.transform = CATransform3DIdentity})
    }
    
}


