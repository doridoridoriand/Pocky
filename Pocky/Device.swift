//
//  device.swift
//  Pocky
//
//  Created by Hitoshi Saito on 2015/06/20.
//  Copyright (c) 2015年 Hitoshi Saito. All rights reserved.
//

struct Device {
    var id: String
    var sort: Int
    var type: String
    var label: String
    var carrier: String
    var model: String
    var modelNumber: String
    var os: String
    var displayName: String {
        get {
            return String(format: "%@ %@ %@", label, model, modelNumber)
        }
    }
    
    init(id: String, sort: String, type: String, label: String, carrier: String, model: String, modelNumber: String, os: String) {
        self.id = id
        self.sort = sort.toInt()!
        self.type = type
        self.label = label
        self.carrier = carrier
        self.model = model
        self.modelNumber = modelNumber
        self.os = os
    }
}