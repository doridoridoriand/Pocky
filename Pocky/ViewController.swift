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
let borrowingTableViewTag : Int = 20

class ViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, NSTextFieldDelegate {

    enum Mode {
        case Borrow, Return
    }

    @IBOutlet weak var nameTextField: NSTextField!
    @IBOutlet weak var deviceListTableView: NSTableView!
    @IBOutlet weak var selectedTableView: NSTableView!
    @IBOutlet weak var borrowingTableView: NSTableView!
    @IBOutlet weak var selectedTitleLabel: NSTextFieldCell!
    @IBOutlet weak var deviceListSearchField: NSSearchField!
    
    var dataArray = [Device]()
    var selectedSet : NSMutableOrderedSet = []
    var borrowingSet : NSMutableOrderedSet = []
    var currentMode : Mode = Mode.Borrow
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        deviceListTableView.target = self
        deviceListTableView.action = "deviceListTableViewClicked:"
        selectedTableView.action = "selectedTableViewClicked:"
        borrowingTableView.action = "borrowingTableViewClicked:"
        
        deviceListTableView.headerView = nil
        selectedTableView.headerView = nil
        borrowingTableView.headerView = nil
        
        Alamofire
            .request(.GET, CommonConst.requestURLDeviceList)
            .responseJSON(options: NSJSONReadingOptions.AllowFragments) { (request, response, jsondata, error) -> Void in
//                println(String(format: "request : %@", request))
//                println(String(format: "response : %@", response!))
                let jsonDic = jsondata as! NSDictionary
                let deviceList = jsonDic["devices"] as! NSArray
                println(jsonDic["version"])
                
                for deviceInfo in deviceList {
                    let device = Device(type: deviceInfo["type"] as! String, label: deviceInfo["label"] as! String, carrier: deviceInfo["carrier"] as! String, model: deviceInfo["model"] as! String, modelNumber: deviceInfo["modelnum"] as! String, os: deviceInfo["os"] as! String)
                    self.dataArray.append(device)
                }
                
                let ud = NSUserDefaults.standardUserDefaults()
                var borrowList : Array! = ud.arrayForKey("borrow")
                for device in borrowList {
                    self.borrowingSet.addObject(device)
                }

                self.deviceListTableView.reloadData()
                self.borrowingTableView.reloadData()
            }
        
    }
    
    func requestSlack(textString: String) {
//        Alamofire.request(
//            .POST
//            , CommonConst.requestURLSlackWebhook
//            , parameters: [
//                "channel": "#rental"
//                , "username": nameTextField.stringValue
//                , "text": textString
//            ]
//            , encoding: .JSON)
    }
    
    func saveBorrowingSet() {
        let ud = NSUserDefaults.standardUserDefaults()
        var array : [Int] = []
        for device in borrowingSet {
            array.append(device as! Int)
        }
        
        ud.setObject(array, forKey: "borrow")
        ud.synchronize()
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        switch tableView.tag {
        case deviceListTableViewTag:
            return dataArray.count
        case selectedTableViewTag:
            return selectedSet.count
        case borrowingTableViewTag:
            return borrowingSet.count
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
            let selectedIndex = selectedSet[row] as! Int
            let device : Device = dataArray[selectedIndex]
            return device.displayName
        case borrowingTableViewTag:
            let selectedIndex = borrowingSet[row] as! Int
            let device : Device = dataArray[selectedIndex]
            return device.displayName
        default:
            return nil
        }
    }
    
    func deviceListTableViewClicked(sender: AnyObject) {
        if currentMode != Mode.Borrow {
            currentMode = Mode.Borrow
            selectedSet.removeAllObjects()
        }
        
        selectedTitleLabel.title = "借用候補"
        
        println(String(format: "clickedRow : %d", deviceListTableView.clickedRow))
        selectedSet.addObject(deviceListTableView.clickedRow)
        
        selectedTableView.reloadData()
    }
    
    func selectedTableViewClicked(sender: AnyObject) {
        if !(selectedSet.count > 0) {
            return
        }
        
        let clickedRow = selectedTableView.clickedRow
        println(String(format: "clickedRow : %d", clickedRow))
        if clickedRow < 0 || clickedRow > selectedSet.count - 1 {
            return
        }
        
        selectedSet.removeObjectAtIndex(clickedRow)
        
        selectedTableView.reloadData()
    }
    
    func borrowingTableViewClicked(sender: AnyObject) {
        if !(borrowingSet.count > 0) {
            return
        }

        let clickedRow = borrowingTableView.clickedRow
        println(String(format: "clickedRow : %d", clickedRow))
        if clickedRow < 0 || clickedRow > borrowingSet.count - 1 {
            return
        }
        
        if currentMode != Mode.Return {
            currentMode = Mode.Return
            selectedSet.removeAllObjects()
        }
        
        selectedTitleLabel.title = "返却候補"
        
        selectedSet.addObject(borrowingSet[clickedRow])
        
        selectedTableView.reloadData()
    }
    
    @IBAction func bollowButtonAction(sender: AnyObject) {
        if currentMode == Mode.Borrow && selectedSet.count > 0 {
            
            var textString : String = ""
            for selectedIndex in selectedSet {
                let device : Device = dataArray[selectedIndex as! Int]
                textString += String(format: "[借用]%@\n", device.displayName)
            }
            
            println(textString)
            
            requestSlack(textString)
            
            for device in selectedSet {
                borrowingSet.addObject(device)
            }
            selectedSet.removeAllObjects()
            
            saveBorrowingSet()

            selectedTableView.reloadData()
            borrowingTableView.reloadData()
        } else {
            println("not selected")
        }
        
    }
    
    @IBAction func returnButtonAction(sender: AnyObject) {
        if currentMode == Mode.Return && selectedSet.count > 0 {
            var textString : String = ""
            for index in selectedSet {
                let device : Device = dataArray[index as! Int]
                textString += String(format: "[返却]%@\n", device.displayName)
            }
            
            println(textString)
            
            requestSlack(textString)

            for device in selectedSet {
                borrowingSet.removeObject(device)
            }
            
            selectedSet.removeAllObjects()
            
            saveBorrowingSet()

            borrowingTableView.reloadData()
            selectedTableView.reloadData()
        }
    }
    
    @IBAction func allReturnButtonAction(sender: AnyObject) {
        if borrowingSet.count > 0 {
            var textString : String = ""
            for index in borrowingSet {
                let device : Device = dataArray[index as! Int]
                textString += String(format: "[返却]%@\n", device.displayName)
            }
            
            println(textString)
            
            requestSlack(textString)
            
            borrowingSet.removeAllObjects()
            
            saveBorrowingSet()
            
            borrowingTableView.reloadData()
        }
    }
    
}