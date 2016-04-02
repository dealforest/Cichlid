//
//  Cichlid.swift
//
//  Created by Toshihiro Morimoto on 2/29/16.
//  Copyright © 2016 Toshihiro Morimoto. All rights reserved.
//

import AppKit

var sharedPlugin: Cichlid?

class Cichlid: NSObject {
    
    var bundle: NSBundle

    class func pluginDidLoad(bundle: NSBundle) {
        if
        let appName = NSBundle.mainBundle().infoDictionary?["CFBundleName"] as? NSString
        where appName == "Xcode" {
            sharedPlugin = Cichlid(bundle: bundle)
        }
    }

    init(bundle: NSBundle) {
        self.bundle = bundle
        super.init()
        
        setupObserver()
    }

    deinit {
        cleanObserver()
    }
    
}

extension Cichlid {
    
    private func setupObserver() {
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "buildOperationDidStop:",
            name: "IDEBuildOperationDidStopNotification",
            object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "xcodeDidFinishLaunching:",
            name: NSApplicationDidFinishLaunchingNotification,
            object: nil)
    }
    
    private func cleanObserver() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: clean
    
    func buildOperationDidStop(notification: NSNotification) {
        guard
        let object = notification.object
        where XcodeHelpers.isCleanBuildOperation(object),
        let projectName = XcodeHelpers.currentProductName() else {
            return
        }
    
        Cleaner.clearDerivedDataForProject(projectName)
    }
    
    // MARK: menu
    
    func xcodeDidFinishLaunching(notification: NSNotification) {
        NSNotificationCenter.defaultCenter().removeObserver(self,
            name: NSApplicationDidFinishLaunchingNotification,
            object: nil)
        NSOperationQueue.mainQueue().addOperationWithBlock {
            self.setupMenu()
        }
    }
    
    private func setupMenu() {
        func createMenuItem(title: String, action selector: Selector, keyEquivalent charCode: String) -> NSMenuItem {
            let item = NSMenuItem(title: title, action: selector, keyEquivalent: charCode)
            item.keyEquivalentModifierMask = Int(
                NSEventModifierFlags.ShiftKeyMask.rawValue |
                NSEventModifierFlags.ControlKeyMask.rawValue)
            item.target = self
            return item
        }
        
        let submenu = NSMenu(title: "Cichlid")
        submenu.addItem(createMenuItem("Open the DerivedData of Current Project",
            action: "openDeriveDataOfCurrentProject",
            keyEquivalent: ""))
        submenu.addItem(createMenuItem("Delete All DerivedData",
            action: "deleteAllDeriveData",
            keyEquivalent: ""))
        
        let cichlid = NSMenuItem(title: "Cichlid", action: nil, keyEquivalent: "")
        cichlid.submenu = submenu
        
        let product = NSApp.mainMenu?.itemWithTitle("Product")
        product?.submenu?.addItem(cichlid)
    }
    
    func openDeriveDataOfCurrentProject() {
    }
    
    func deleteAllDeriveData() {
    }
    
}
