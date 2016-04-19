//
//  City.swift
//  HireTask
//
//  Created by Имал Фарук on 14.04.16.
//  Copyright © 2016 Имал Фарук. All rights reserved.
//

import UIKit


//структура, которая описывает город
struct City {
    var countryCityTitle = String()
    var longitude = Double()
    var latitude = Double()
    var districtTitle = String()
    var cityId = Int()
    var regionTitle = String()
    var stations = [Station]()
}
