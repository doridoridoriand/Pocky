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
let recentTableViewTag : Int = 1
let favoriteTableViewTag : Int = 2
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
    @IBOutlet weak var recentTableView: NSTableView!
    @IBOutlet weak var favoriteTableView: NSTableView!
    @IBOutlet weak var selectedTitleLabel: NSTextFieldCell!
    @IBOutlet weak var deviceListSearchField: NSSearchField!
    
    var dataDic = [String : Device]()
    var displayArray = [String]()
    var recentArray = [String]()
    var favoriteArray = [String]()
    var selectedSet : NSMutableOrderedSet = []
    var borrowingSet : NSMutableOrderedSet = []
    var currentMode : Mode = Mode.Borrow
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        deviceListTableView.action = "deviceListTableViewClicked:"
        recentTableView.action = "deviceListTableViewClicked:"
        favoriteTableView.action = "deviceListTableViewClicked:"
        selectedTableView.action = "selectedTableViewClicked:"
        borrowingTableView.action = "borrowingTableViewClicked:"
        
        // 検索機能
        NSNotificationCenter.defaultCenter().addObserverForName(NSControlTextDidChangeNotification, object: deviceListSearchField, queue:NSOperationQueue.mainQueue()) { (notification: NSNotification!) -> Void in
            
            let inputString = self.deviceListSearchField.stringValue
            
            self.displayArray.removeAll()
            if count(inputString) > 0 {
                for device in self.dataDic.values {
                    if let r = device.displayName.rangeOfString(inputString, options:.CaseInsensitiveSearch) {
                        self.displayArray.append(device.id)
                    }
                }
            } else {
                for deviceId in self.dataDic.keys {
                    self.displayArray.append(deviceId)
                }
            }
            self.sortArray(&self.displayArray)
            
            self.deviceListTableView.reloadData()
        }
        
        let ud = NSUserDefaults.standardUserDefaults()
        let name = ud.stringForKey("name")
        if let unwrappedName = name {
            nameTextField.stringValue = unwrappedName
        }
        
        Alamofire
            .request(.GET, CommonConst.requestURLDeviceList)
            .responseJSON(options: NSJSONReadingOptions.AllowFragments) { (request, response, jsondata, error) -> Void in
//                println(String(format: "request : %@", request))
//                println(String(format: "response : %@", response!))
                let jsonDic = jsondata as! NSDictionary
                let deviceList = jsonDic["devices"] as! NSArray
                println(jsonDic["version"])
                
                for deviceInfo in deviceList {
                    let device = Device(id: deviceInfo["id"] as! String, sort: deviceInfo["sort"] as! String, type: deviceInfo["type"] as! String, label: deviceInfo["label"] as! String, carrier: deviceInfo["carrier"] as! String, model: deviceInfo["model"] as! String, modelNumber: deviceInfo["modelnum"] as! String, os: deviceInfo["os"] as! String)
                    self.dataDic[device.id] = device
                }
                
                for deviceId in self.dataDic.keys {
                    self.displayArray.append(deviceId)
                }
                self.sortArray(&self.displayArray)
                
                let ud = NSUserDefaults.standardUserDefaults()
                var borrowList : Array! = ud.arrayForKey("borrow")
                if let unwrappedBorrowList = borrowList {
                    for deviceId in unwrappedBorrowList {
                        self.borrowingSet.addObject(deviceId)
                    }
                }
                
                var recentList : Array! = ud.arrayForKey("recent")
                if let unwrappedRecentList = recentList {
                    for deviceId in unwrappedRecentList {
                        self.recentArray.append(deviceId as! String)
                    }
                }

                self.deviceListTableView.reloadData()
                self.recentTableView.reloadData()
                self.favoriteTableView.reloadData()
                self.borrowingTableView.reloadData()
            }
        
    }
    
    func sortArray(inout array: [String]) {
        sort(&array) {
            (str1 : String, str2 : String) -> Bool in
            let device1 = self.dataDic[str1]
            let device2 = self.dataDic[str2]
            return device1!.sort < device2!.sort
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
        
        saveName()

    }
    
    func saveBorrowingSet() {
        let ud = NSUserDefaults.standardUserDefaults()
        var borrowArray : [String] = []
        for deviceId in borrowingSet {
            borrowArray.append(deviceId as! String)
        }
        ud.setObject(borrowArray, forKey: "borrow")
        
        ud.synchronize()
    }
    
    func saveRecentSet() {
        let ud = NSUserDefaults.standardUserDefaults()
        ud.setObject(recentArray, forKey: "recent")
        
        ud.synchronize()
    }
    
    func saveName() {
        if !(count(nameTextField.stringValue) > 0) {
            return
        }
        let ud = NSUserDefaults.standardUserDefaults()
        ud.setObject(nameTextField.stringValue, forKey: "name")
        ud.synchronize()
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        switch tableView.tag {
        case deviceListTableViewTag:
            return displayArray.count
        case recentTableViewTag:
            return recentArray.count
        case favoriteTableViewTag:
            return favoriteArray.count
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
            let deviceId = displayArray[row] as String
            let device = dataDic[deviceId]
            return device!.displayName
        case recentTableViewTag:
            let deviceId = recentArray[row] as String
            let device = dataDic[deviceId]
            return device!.displayName
        case favoriteTableViewTag:
            let deviceId = favoriteArray[row] as String
            let device = dataDic[deviceId]
            return device!.displayName
        case selectedTableViewTag:
            let deviceId = selectedSet[row] as! String
            let device = dataDic[deviceId]
            return device!.displayName
        case borrowingTableViewTag:
            let deviceId = borrowingSet[row] as! String
            let device = dataDic[deviceId]
            return device!.displayName
        default:
            return nil
        }
    }
    
    
    func deviceListTableViewClicked(tableView: NSTableView) {
        if !(tableView.clickedRow >= 0) {
            return
        }
        
        if currentMode != Mode.Borrow {
            currentMode = Mode.Borrow
            selectedSet.removeAllObjects()
        }
        
        selectedTitleLabel.title = "借用候補"
        
        println(String(format: "clickedRow : %d", tableView.clickedRow))
        
        switch tableView.tag {
        case 0:
            selectedSet.addObject(displayArray[tableView.clickedRow])
        case 1:
            selectedSet.addObject(recentArray[tableView.clickedRow])
        case 2:
            selectedSet.addObject(favoriteArray[tableView.clickedRow])
        default:
            break
        }
        
        selectedTableView.reloadData()
    }
    
    func selectedTableViewClicked(sender: AnyObject) {
        if !(selectedSet.count >= 0) {
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
            for selectedDeviceId in selectedSet {
                let device = dataDic[selectedDeviceId as! String]
                textString += String(format: "[借用]%@\n", device!.displayName)
            }
            
            println(textString)
            
            requestSlack(textString)
            
            for deviceId in selectedSet {
                borrowingSet.addObject(deviceId)
            }
            
            for deviceId in selectedSet {
                // 配列内の同じdeviceIdを削除
                recentArray = recentArray.filter({ (deviceIdInArray) -> Bool in
                    return deviceIdInArray != deviceId as! String
                })
                
                recentArray.insert(deviceId as! String, atIndex: 0)
                
                if recentArray.count > 10 {
                    recentArray.removeLast()
                }
            }
            
            saveRecentSet()
            saveBorrowingSet()
            
            selectedSet.removeAllObjects()

            recentTableView.reloadData()
            selectedTableView.reloadData()
            borrowingTableView.reloadData()
        } else {
            println("not selected")
        }
        
    }
    
    @IBAction func returnButtonAction(sender: AnyObject) {
        if currentMode == Mode.Return && selectedSet.count > 0 {
            var textString : String = ""
            for selectedDeviceId in selectedSet {
                let device = dataDic[selectedDeviceId as! String]
                textString += String(format: "[返却]%@\n", device!.displayName)
            }
            
            println(textString)
            
            requestSlack(textString)

            for device in selectedSet {
                borrowingSet.removeObject(device)
            }
            
            saveBorrowingSet()

            selectedSet.removeAllObjects()

            borrowingTableView.reloadData()
            selectedTableView.reloadData()
        }
    }
    
    @IBAction func allReturnButtonAction(sender: AnyObject) {
        if borrowingSet.count > 0 {
            var textString : String = ""
            for borrowingDeviceId in borrowingSet {
                let device = dataDic[borrowingDeviceId as! String]
                textString += String(format: "[返却]%@\n", device!.displayName)
            }
            
            println(textString)
            
            requestSlack(textString)
            
            borrowingSet.removeAllObjects()
            
            saveBorrowingSet()
            
            borrowingTableView.reloadData()
        }
    }
    
}