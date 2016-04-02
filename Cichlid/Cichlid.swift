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
    
    // MARK: notification
    
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
    
    // MARK: build operation
    
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
        guard
        let projectName = XcodeHelpers.currentProductName(),
        let path = Cleaner.derivedDataPath(projectName) else {
            alert("Not found the DerivedData directory")
            return
        }
        
        let task = NSTask()
        task.launchPath = "/usr/bin/open"
        task.arguments = [ path.absoluteString ]
        task.standardOutput = NSPipe()
        task.launch()
    }
    
    func deleteAllDeriveData() {
        confirm("Are you sure you want to delete?") { success in
            guard success else {
                return
            }
            
            let success = Cleaner.clearAllDerivedData()
            let message = success ?
                "successful in delete the DelivedData" :
                "failed to delete the DerivedData"
            self.alert(message)
        }
    }
    
    // MARK: alert
    
    private func alert(informativeText: String) {
        let alert = NSAlert()
        alert.messageText = "Cichlid"
        alert.informativeText = informativeText
        alert.runModal()
    }
    
    private func confirm(informativeText: String, completion: (Bool -> Void)?) -> Bool {
        let alert = NSAlert()
        alert.alertStyle = .WarningAlertStyle
        alert.messageText = "Cichlid"
        alert.informativeText = informativeText
        alert.addButtonWithTitle("OK")
        alert.addButtonWithTitle("Cancel")
        let result = alert.runModal() == NSAlertFirstButtonReturn
        completion?(result)
        return result
    }
    
}