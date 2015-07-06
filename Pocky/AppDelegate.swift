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
//        NSEvent.addGlobalMonitorForEventsMatchingMask() { (event) -> Void in
//            
//        }
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
    @IBAction func resetMenuAction(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName(CommonConst.notificationMenuReset, object: nil)
    }
}