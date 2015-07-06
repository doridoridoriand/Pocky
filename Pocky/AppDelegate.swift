//
//  AppDelegate.swift
//  Pocky
//
//  Created by Hitoshi Saito on 2015/06/13.
//  Copyright (c) 2015年 Hitoshi Saito. All rights reserved.
//

import AppKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate  {
    
    func applicationDidFinishLaunching(notification: NSNotification) {
        var EditMenu = NSApplication.sharedApplication().mainMenu!.itemWithTitle("Edit")
        if (EditMenu != nil) {
            var Count: Int = EditMenu!.submenu!.numberOfItems
            if (EditMenu!.submenu!.itemAtIndex(Count - 1)!.title == "Emoji & Symbols") {
                EditMenu!.submenu!.removeItemAtIndex(Count - 1)
            }
            if (EditMenu!.submenu!.itemAtIndex(Count - 2)!.title == "Start Dictation…") {
                EditMenu!.submenu!.removeItemAtIndex(Count - 2)
            }
            if (EditMenu!.submenu!.itemAtIndex(Count - 3)!.title == "") {
                EditMenu!.submenu!.removeItemAtIndex(Count - 3)
            }
        }
    }
    
    func applicationWillTerminate(notification: NSNotification) {
        
    }
    
    func applicationShouldHandleReopen(sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if flag {
            return false
        } else {
            for window in sender.windows {
                window.makeKeyAndOrderFront(self)
            }
            return true
        }
    }
    
    @IBAction func closeWindowMenuAction(sender: AnyObject) {
        NSApp.windows[0].close()
    }
    
    @IBAction func borrowMenuAction(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName(CommonConst.notificationMenuBorrow, object: nil)
    }
    
    @IBAction func returnMenuAction(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName(CommonConst.notificationMenuReturn, object: nil)
    }
    
    @IBAction func allReturnMenuAction(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName(CommonConst.notificationMenuAllReturn, object: nil)
    }
    
    @IBAction func resetMenuAction(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName(CommonConst.notificationMenuReset, object: nil)
    }

}