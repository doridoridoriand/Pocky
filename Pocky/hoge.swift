//
//  hoge.swift
//  Pocky
//
//  Created by Hitoshi Saito on 2015/06/12.
//  Copyright (c) 2015年 CyberZ. All rights reserved.
//

import Foundation
import AppKit

class Hoge: NSObject {
    var name: String
    var image: NSImage!
    
    override init() {
        self.name = "test"
        self.image = NSImage(named: "moriyaman.png")
    }
}