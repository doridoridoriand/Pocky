//
//  ViewController.swift
//  Pocky
//
//  Created by Hitoshi Saito on 2015/06/13.
//  Copyright (c) 2015年 Hitoshi Saito. All rights reserved.
//

import Foundation
import AppKit
import Alamofire

let deviceNameKey : NSString = "deviceName"

let deviceListTableViewTag : Int = 0
let selectedTableViewTag : Int = 10

class ViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, NSTextFieldDelegate {

    @IBOutlet weak var nameTextField: NSTextField!
    @IBOutlet weak var deviceListTableView: NSTableView!
    @IBOutlet weak var selectedTableView: NSTableView!
    
    let dataArray : NSMutableArray = []
    var selectedSet : NSMutableOrderedSet = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        deviceListTableView.target = self
        deviceListTableView.action = "doClick:"
        
        Alamofire
            .request(.GET, CommonConst.requestURLDeviceList)
            .responseJSON(options: NSJSONReadingOptions.AllowFragments) { (request, response, jsondata, error) -> Void in
                NSLog("request : %@", request)
                NSLog("response : %@", response!)
                let jsonDic : NSDictionary = jsondata as! NSDictionary
                println(jsonDic["version"])
                let deviceList : NSArray = jsonDic["devices"] as! NSArray
                for device in deviceList {
                    let data : NSDictionary = [
                        deviceNameKey: device
                    ]
                    self.dataArray.addObject(data)
                }
                self.deviceListTableView.reloadData()
            }
        
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        switch tableView.tag {
            case deviceListTableViewTag:
                return dataArray.count
            case selectedTableViewTag:
                return selectedSet.count
            default:
                return 0
        }
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        switch tableView.tag {
            case deviceListTableViewTag:
                let data : NSDictionary = dataArray.objectAtIndex(row) as! NSDictionary
                return data.objectForKey(deviceNameKey)
            case selectedTableViewTag:
                let selectedIndex : Int = selectedSet[row] as! Int
                let data : NSDictionary = dataArray.objectAtIndex(selectedIndex) as! NSDictionary
                return data.objectForKey(deviceNameKey)
            default:
                return nil
        }
    }
    
    func doClick(sender: AnyObject) {
        NSLog("clickedRow : %d", deviceListTableView.clickedRow)
        selectedSet.addObject(deviceListTableView.clickedRow)
        
        selectedTableView.reloadData()
    }
    
    @IBAction func bollowButtonAction(sender: AnyObject) {
        if selectedSet.count > 0 {
            
            var textString : String = ""
            for selectedIndex in selectedSet {
                let data : NSDictionary = dataArray.objectAtIndex(selectedIndex as! Int) as! NSDictionary
                let deviceName : String = data.objectForKey(deviceNameKey) as! String
                textString += "[借用]" + deviceName + "\n"
            }
            
            println(textString)
            
            Alamofire.request(
                .POST
                , CommonConst.requestURLSlackWebhook
                , parameters: [
                    "channel": "#rental"
                    , "username": nameTextField.stringValue
                    , "text": textString
                ]
                , encoding: .JSON)
        } else {
            NSLog("not selected")
        }
        
    }

    @IBAction func returnButtonAction(sender: AnyObject) {
        
    }
}