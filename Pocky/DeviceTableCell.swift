//
//  DeviceTableCell.swift
//  Pocky
//
//  Created by Hitoshi Saito on 2015/07/05.
//  Copyright (c) 2015年 Hitoshi Saito. All rights reserved.
//

import Cocoa

protocol DeviceTableCellDelegate {
    func favoriteButtonPushed(deviceId: String, isFavorite: Bool)
}

class DeviceTableCell: NSTableCellView {
    
    var delegate: DeviceTableCellDelegate! = nil
    
    private var deviceId: String = ""
    private var isFavorite: Bool = false
    
    @IBOutlet weak private var favoriteButton: NSButton!
    @IBOutlet weak private var deviceLabel: NSTextField!
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
        // Drawing code here.
    }
    
    func setCellData(deviceId: String, deviceString: String, isFavorite: Bool) {
        self.deviceId = deviceId
        self.isFavorite = isFavorite
        
        setFavoriteButtonState(isFavorite)
        
        deviceLabel.stringValue = deviceString
    }
    
    @IBAction private func favoriteButtonAction(sender: AnyObject) {
        isFavorite = !isFavorite
        setFavoriteButtonState(isFavorite)
        
        delegate.favoriteButtonPushed(deviceId, isFavorite: isFavorite)
    }
    
    private func setFavoriteButtonState(isFavorite: Bool) {
        var favoriteImageName: String = "star-outline"
        if isFavorite {
            favoriteImageName = "star"
        }
        let image = NSImage(named: favoriteImageName)
        
        favoriteButton.image = image
    }
}
