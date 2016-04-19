//
//  ViewController.swift
//  HireTask
//
//  Created by Имал Фарук on 14.04.16.
//  Copyright © 2016 Имал Фарук. All rights reserved.
//

import UIKit
//Если import SwiftyJSON подсвечивается как ошибка, то либо запустите проект, либо нажмите cmd + B
import SwiftyJSON

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    //Searchbar для поиска места отправления
    @IBOutlet weak var searchFrom: UISearchBar!
    //Searchbar для поиска места прибытия
    @IBOutlet weak var searchTo: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    //Label, в котором будет храниться информация о выбраной дате
    @IBOutlet weak var chooseDateLabel: UILabel!
 
    //Булевские переменные, которые хранят данные, с каким именно UISearchBar пользователь работает
    var searchFromActive = false
    var searchToActive = false
    
    //Переменная defaults нужна для того, чтобы загружать сохраненные дату, станцию отправления и станцию прибытия
    var defaults = NSUserDefaults.standardUserDefaults()
    
    //Заносим данные из файла в константу
    let jsonDataFile = JSON(data: NSData(contentsOfFile: NSBundle.mainBundle().pathForResource("allStations", ofType: "json")!)!)
    
    //Массивы, хранящие данные структуры City отправления и прибытия, а также массив с найденными данными по поиску
    var citiesFromArray = [City]()
    var citiesToArray = [City]()
    var filteredCitiesArray = [City]()
    
    //Массив, хранящий данные структуры Station
    var stationArray = [Station]()
    

    


    override func viewDidLoad() {
        super.viewDidLoad()
        //Вызовы методов, которые загружают и заполняют SearchBar'ы и Label с датой при включении приложения
        loadStationTitleDataFrom()
        loadStationTitleDataTo()
        loadChooseDateLabel()
        
        //Центры уведомлений, которые ожидают обновления даты и названия станций
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(loadChooseDateLabel), name: "LoadDateLabel", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(loadStationTitleDataFrom), name: "loadStationTitleDataFrom", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(loadStationTitleDataTo), name: "loadStationTitleDataTo", object: nil)
        
        //Вызовы методов, которые обрабатывают данные для каж
        processData("citiesFrom")
        processData("citiesTo")

    }
    
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        //Проверка на то, какой именно SearchBar активен
        if searchBar == searchTo {
            searchToActive = true
            searchFromActive = false
        } else if searchBar == searchFrom {
            searchFromActive = true
            searchToActive = false
        }
        //Перезагрузка таблицы. Это нужно для начального случая, когда пользователь нажал на SearchBar после чего TableView выведет весь список (город, страна) для данного SearchBar
        tableView.reloadData()
    }
    
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        //При нажатии на кнопку "Найти" клавиатура уберется с экрана
        if searchBar == searchTo {
            searchTo.resignFirstResponder()
        } else if searchBar == searchFrom {
            searchFrom.resignFirstResponder()
        }
    }
    
    
    func loadStationTitleDataFrom() {
        //Проверка, если данные не пустые, то присвоится данное имя станции, если данных нет, то SearchBar будет пустым
        if defaults.objectForKey("StationTitleFrom") != nil {
            searchFrom.text = (defaults.objectForKey("StationTitleFrom") as? String)!
            print("StationTitleFrom = \(searchFrom.text)")
        } else {
            print("StationTitleFrom is empty")
        }
        tableView.reloadData()
    }
    

    func loadStationTitleDataTo() {
        //проверка, если данные не пустые, то присвоится данное имя станции, если данных нет, то SearchBar будет пустым
        if defaults.objectForKey("StationTitleTo") != nil {
            searchTo.text = (defaults.objectForKey("StationTitleTo") as? String)!
            print("stationTitle = \(searchTo.text)")
        } else {
            print("stationTitle is empty")
        }
        tableView.reloadData()
    }

    func loadChooseDateLabel() {
        //проверка, если данные не пустые, то присвоится данная дата, если данных нет, то Label будет пустым
        if defaults.objectForKey("DateLabel") != nil {
            chooseDateLabel.text = (defaults.objectForKey("DateLabel") as? String)!
            print("chooseDateLabel = \(chooseDateLabel.text)")
        } else {
            print("chooseDateLabel is empty")
        }
    }
    
    //Для парсинга использован SwiftyJSON, так как это упрощает работу, не нужно проверять данные на равенство nil, что уменьшает количество кода и упращает работу.
    //метод для обработки json-данных, принимает на вход либо "citiesFrom", либо "citiesTo"(см allStations.json)
    func processData(citiesDirection: String) {
        //записываем в citiesDirectionJsonArray массив[JSON], который содержит все данные из "citiesFrom" : [  ] или "citiesTo" : [  ] из предоставленного файла
        if let citiesDirectionJsonArray = jsonDataFile[citiesDirection].array {
            //цикл for in проходит по всем элементам citiesDirectionJsonArray, заполняя константы запрошенными данными.
            for cityDictionary in citiesDirectionJsonArray {
                //countryCityTitle - именно здесь и будет проходить поиск. Я решил здесь объединить в формате "Город, Страна", так как в задании сказано, что должнен выводиться список именно в таком формате.
                let countryCityTitle : String = cityDictionary["cityTitle"].stringValue + ", " + cityDictionary["countryTitle"].stringValue
                //Многие данные можно было и не обрабатывать, сделал на перспективу. Вдруг, пригодятся.
                let longitude : Double = cityDictionary["point"]["longitude"].doubleValue
                let latitude : Double = cityDictionary["point"]["latitude"].doubleValue
                let districtTitle : String = cityDictionary["districtTitle"].stringValue
                let cityId : Int = cityDictionary["cityId"].intValue
                let regionTitle : String = cityDictionary["regionTitle"].stringValue
               //Делаю тоже самое для данных по ключу "stations", заполняю stationsInfoJsonArray массивом json-данных из "stations"
                if let stationsInfoJsonArray = cityDictionary["stations"].array {
                    //Цикл for in проходит по всем элементам stationsInfoJsonArray, заполняя константы запрошенными данными.
                    for station in stationsInfoJsonArray {
                        let stationCountryTitle : String = station["countryTitle"].stringValue
                        let stationLongitude : Double = station["point"]["longitude"].doubleValue
                        let stationLatitude : Double = station["point"]["latitude"].doubleValue
                        let stationDistrictTitle = station["districtTitle"].stringValue
                        let stationCityId : Int = station["cityId"].intValue
                        let stationCityTitle : String = station["cityTitle"].stringValue
                        let stationRegionTitle : String = station["regionTitle"].stringValue
                        let stationId : Int = station["stationId"].intValue
                        let stationTitle : String = station["stationTitle"].stringValue
                        //Создаю экземпляр и заполняю его данными
                        let stationStruct = Station(countryTitle: stationCountryTitle, longitude: stationLongitude, latitude: stationLatitude, districtTitle: stationDistrictTitle, cityId: stationCityId, cityTitle: stationCityTitle, regionTitle: stationRegionTitle, stationId: stationId, stationTitle: stationTitle)
                        //После окончания цикла в массиве stationArray будут находиться все станции определенного для элемента формата "Город, Страна"
                        stationArray.append(stationStruct)
                    }
                }
                //Теперь элемент готов полностью
                let cityStruct = City(countryCityTitle: countryCityTitle, longitude: longitude, latitude: latitude, districtTitle: districtTitle, cityId: cityId, regionTitle: regionTitle, stations: stationArray)
                //Проверка входной строки для того, чтобы записать данные в нужный массив.
                if citiesDirection == "citiesFrom" {
                    citiesFromArray.append(cityStruct)
                } else if citiesDirection == "citiesTo" {
                    citiesToArray.append(cityStruct)
                }
                //Элемент готов полностью и уже в нужном массиве. Теперь нужно очистить массив со станциями(если не очистить, то с каждым городом они будут суммироваться и при выборе последнего элемента вылезет список ВООБЩЕ ВСЕХ СТАНЦИЙ, что нам не нужно)
                stationArray.removeAll()
            }
        }
    }
    
    //Зарезервированный метод для заполнение ячеек таблицы
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellId = "Cell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellId, forIndexPath: indexPath)
       //Варианты отображения данных в ячейках
        if searchFromActive && searchFrom.text == "" {
            //Если выбран SearchBar отправления и там ничего не введено, то ячейки заполнятся массивом citiesFromArray
            cell.textLabel?.text = citiesFromArray[indexPath.row].countryCityTitle
        } else if searchToActive && searchTo.text == "" {
           //Если выбран SearchBar прибытия и там ничего не введено, то ячейки заполнятся массивом citiesToArray
            cell.textLabel?.text = citiesToArray[indexPath.row].countryCityTitle
        } else {
            //В случаях, если введено что-либо, то будут выводиться элементы из массива, который содержит найденные данные
            cell.textLabel?.text = filteredCitiesArray[indexPath.row].countryCityTitle
        }
        return cell
    }
    
    //Зарезервированный метод, в котом записывается количество ячеек
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //Варианты расчета ячеек
        if searchFromActive && searchFrom.text == "" {
            //Если выбран SearchBar отправления и там ничего не введено, то количество ячеек = количество элементов массива citiesFromArray
            return citiesFromArray.count
        } else if searchFromActive && searchFrom.text != "" {
            //Если выбран SearchBar отправления и там что-либо введено, то количество ячеек = количество элементов массива filteredCitiesArray
            return filteredCitiesArray.count
        } else  if searchToActive && searchTo.text == "" {
            //Если выбран SearchBar прибытия и там ничего не введено, то количество ячеек = количество элементов массива citiesToArray
            return citiesToArray.count
        } else if searchToActive && searchTo.text != "" {
            //Если выбран SearchBar прибытия и там что-либо введено, то количество ячеек = количество элементов массива filteredCitiesArray
            return filteredCitiesArray.count
        }
        //Пришлось обработать все частные случаи, так как если пользователь только включил приложение, то ни один из SearchBar'ов не будет активен, поэтому количество ячеек будет равно нулю
        return 0
        
        
    }
    //Метод, в котором описан поиск
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchFrom.text == "" && searchFromActive {
            //вариант, когда пользователь ищет город отправления и удаляет содержимое SearchBar'a, тогда таблица перезагружается(Будут выведены все элементы массива citiesFromArray)
            tableView.reloadData()
        } else if searchTo.text == "" && searchToActive {
            //вариант, когда пользователь ищет город прибытия и удаляет содержимое SearchBar'a, тогда таблица перезагружается(Будут выведены все элементы массива citiesToArray)
            tableView.reloadData()
        } else if searchFrom.text != "" && searchFromActive {
            //поиск в массиве отправления
            //очистка массива filteredCitiesArray на случай, если поиск был проведен раннее.
            filteredCitiesArray.removeAll()
            //цикл for in проходит все элементы массива citiesFromArray
            for i in 0..<citiesFromArray.count {
                //Сравнение citiesFromArray[i].countryCityTitle и searchFrom.text, если элемент citiesFromArray[i].countryCityTitle содержит searchFrom.text, то добавляется в массив
                if citiesFromArray[i].countryCityTitle.lowercaseString.rangeOfString(searchFrom.text!.lowercaseString) != nil {
                    filteredCitiesArray.append(citiesFromArray[i])
                }
            }
            //После свершение поиска таблица перезагружается(В таблице будут все элементы, содержащие searchFrom.text)
            tableView.reloadData()
        } else if searchTo.text != "" && searchToActive {
            //поиск в массиве прибытия
            //очистка массива filteredCitiesArray на случай, если поиск был проведен раннее.
            filteredCitiesArray.removeAll()
            //цикл for in проходит все элементы массива citiesToArray
            for i in 0..<citiesToArray.count {
                //Сравнение citiesToArray[i].countryCityTitle и searchTo.text, если элемент citiesToArray[i].countryCityTitle содержит searchTo.text, то добавляется в массив
                if citiesToArray[i].countryCityTitle.lowercaseString.rangeOfString(searchTo.text!.lowercaseString) != nil {
                    filteredCitiesArray.append(citiesToArray[i])
                }
            }
            //После свершение поиска таблица перезагружается(В таблице будут все элементы, содержащие searchTo.text)
            tableView.reloadData()
        }
    }
    
    
    
    //Дополнительный метод кастомизации появления ячеек. Я решил от себя добавить появление ячейки с поворотом на 15% градусов, чтобы выглядело более солидно, но при это не мешало скролить большой список
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let rotationAngle = CGFloat(M_PI/12)
        let rotationTransform = CATransform3DMakeRotation(rotationAngle, 0, 0, 1)
        cell.layer.transform = rotationTransform
        UIView.animateWithDuration(0.15, animations: {cell.layer.transform = CATransform3DIdentity})
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //Одна секция в tableView в приложении
     func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    //Перенос данных для заполнения ячеек + измениение флага
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "CellDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let destinationController = segue.destinationViewController as! DetailsTableViewController
                //заполнение массива station и строки switchDefaultsString, изменение строки нужно, чтобы подать сигнал, с каким ключом сохранять и какое уведомление отправлять на загрузку названия станции. 
                if searchFromActive && searchFrom.text == "" {
                    destinationController.station = citiesFromArray[indexPath.row].stations
                    destinationController.switchDefaultsString = "switchDefaultsFrom"
                } else if searchToActive && searchTo.text == "" {
                    destinationController.station = citiesToArray[indexPath.row].stations
                    destinationController.switchDefaultsString = "switchDefaultsTo"
                } else if searchToActive && searchTo.text != "" {
                    destinationController.station = filteredCitiesArray[indexPath.row].stations
                    destinationController.switchDefaultsString = "switchDefaultsTo"
                } else if searchFromActive && searchFrom.text != "" {
                    destinationController.station = filteredCitiesArray[indexPath.row].stations
                    destinationController.switchDefaultsString = "switchDefaultsFrom"
                }
            }
        }
    }
}

