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

let deviceListTableViewTag : Int = 0
let selectedTableViewTag : Int = 10

class ViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, NSTextFieldDelegate {

    @IBOutlet weak var nameTextField: NSTextField!
    @IBOutlet weak var deviceListTableView: NSTableView!
    @IBOutlet weak var selectedTableView: NSTableView!
    
    var dataArray = [Device]()
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
                let jsonDic = jsondata as! NSDictionary
                let deviceList = jsonDic["devices"] as! NSArray
                println(jsonDic["version"])
                
                for deviceInfo in deviceList {
                    let device = Device(type: deviceInfo["type"] as! String, label: deviceInfo["label"] as! String, carrier: deviceInfo["carrier"] as! String, model: deviceInfo["model"] as! String, modelNumber: deviceInfo["modelnum"] as! String, os: deviceInfo["os"] as! String)
                    self.dataArray.append(device)
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
                let device : Device = dataArray[row]
                return device.displayName
            case selectedTableViewTag:
                let selectedIndex : Int = selectedSet[row] as! Int
                let device : Device = dataArray[selectedIndex]
                return device.displayName
            default:
                return nil
        }
    }
    
    func doClick(sender: AnyObject) {
        println(String(format: "clickedRow : %d", deviceListTableView.clickedRow))
        selectedSet.addObject(deviceListTableView.clickedRow)
        
        selectedTableView.reloadData()
    }
    
    @IBAction func bollowButtonAction(sender: AnyObject) {
        if selectedSet.count > 0 {
            
            var textString : String = ""
            for selectedIndex in selectedSet {
                let device : Device = dataArray[selectedIndex as! Int]
                textString += String(format: "[借用]%@\n", device.model)
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
            println("not selected")
        }
        
    }

    @IBAction func returnButtonAction(sender: AnyObject) {
        
    }
}