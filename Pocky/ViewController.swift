//
//  ViewController.swift
//  Pocky
//
//  Created by Hitoshi Saito on 2015/06/13.
//  Copyright (c) 2015年 CyberZ. All rights reserved.
//

import Foundation
import AppKit

class ViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, NSTextFieldDelegate {
    
    let dataArray : NSMutableArray = []
    
    var selectedIndex : Int?
    
    @IBOutlet weak var nameTextField: NSTextField!
    @IBOutlet weak var tableView: NSTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for i in 0...10 {
            let data : NSDictionary = [
                "title": NSString(format: "title-%d", i),
                "description": NSString(format: "description-%d", i)
            ]
            dataArray.addObject(data)
        }
        
        tableView.target = self
        tableView.action = "doClick:"
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return dataArray.count
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        let data : NSDictionary = dataArray.objectAtIndex(row) as! NSDictionary
        return data.objectForKey("title")
    }
    
    func doClick(sender: AnyObject) {
        NSLog("clickedRow : %d", tableView.clickedRow)
        selectedIndex = tableView.clickedRow
    }
    
    @IBAction func buttonAction(sender: AnyObject) {
        if selectedIndex != nil {
            NSLog("selected : %d  name : %@", selectedIndex!, nameTextField.stringValue)
        } else {
            NSLog("not selected")
        }
        
    }

}