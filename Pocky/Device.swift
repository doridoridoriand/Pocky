//
//  device.swift
//  Pocky
//
//  Created by Hitoshi Saito on 2015/06/20.
//  Copyright (c) 2015年 Hitoshi Saito. All rights reserved.
//

struct Device {
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
    
    init(type: String, label: String, carrier: String, model: String, modelNumber: String, os: String) {
        self.type = type;
        self.label = label;
        self.carrier = carrier;
        self.model = model;
        self.modelNumber = modelNumber;
        self.os = os;
    }
}