//
//  Cichlid.swift
//
//  Created by Toshihiro Morimoto on 2/29/16.
//  Copyright © 2016 Toshihiro Morimoto. All rights reserved.
//

import AppKit

var sharedPlugin: Cichlid?

class Cichlid: NSObject {
    
    var bundle: Bundle

    class func pluginDidLoad(_ bundle: Bundle) {
        if
        let appName = Bundle.main.infoDictionary?["CFBundleName"] as? NSString
        , appName == "Xcode" {
            sharedPlugin = Cichlid(bundle: bundle)
        }
    }

    init(bundle: Bundle) {
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
    
    fileprivate func setupObserver() {
        NotificationCenter.default.addObserver(self,
            selector: #selector(Cichlid.buildOperationDidStop(_:)),
            name: NSNotification.Name(rawValue: "IDEBuildOperationDidStopNotification"),
            object: nil)
        NotificationCenter.default.addObserver(self,
            selector: #selector(Cichlid.xcodeDidFinishLaunching(_:)),
            name: NSNotification.Name.NSApplicationDidFinishLaunching,
            object: nil)
    }
    
    fileprivate func cleanObserver() {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: build operation
    
    func buildOperationDidStop(_ notification: Notification) {
        guard
        let object = notification.object
        , XcodeHelpers.isCleanBuildOperation(object as AnyObject),
        let _ = XcodeHelpers.currentProductName() else {
            return
        }
    
        _ = Cleaner.clearAllDerivedData()
    }
    
    // MARK: menu
    
    func xcodeDidFinishLaunching(_ notification: Notification) {
        NotificationCenter.default.removeObserver(self,
            name: NSNotification.Name.NSApplicationDidFinishLaunching,
            object: nil)
        OperationQueue.main.addOperation {
            self.setupMenu()
        }
    }
    
    fileprivate func setupMenu() {
        func createMenuItem(_ title: String, action selector: Selector, keyEquivalent charCode: String) -> NSMenuItem {
            let item = NSMenuItem(title: title, action: selector, keyEquivalent: charCode)
            item.keyEquivalentModifierMask = NSEventModifierFlags(rawValue: UInt(Int(
                NSEventModifierFlags.shift.rawValue |
                NSEventModifierFlags.control.rawValue)))
            item.target = self
            return item
        }
        
        let submenu = NSMenu(title: "Cichlid")
        submenu.addItem(createMenuItem("Open the DerivedData of Current Project",
            action: #selector(Cichlid.openDeriveDataOfCurrentProject),
            keyEquivalent: ""))
        submenu.addItem(createMenuItem("Delete the DerivedData of Current Project",
            action: #selector(Cichlid.deleteDeriveDataOfCurrentProject),
            keyEquivalent: ""))
        submenu.addItem(createMenuItem("Delete All the DerivedData",
            action: #selector(Cichlid.deleteAllDeriveData),
            keyEquivalent: ""))
        submenu.addItem(createMenuItem("Delete All the Archive",
            action: #selector(Cichlid.deleteAllArchiveData),
            keyEquivalent: ""))
        
        let cichlid = NSMenuItem(title: "Cichlid", action: nil, keyEquivalent: "")
        cichlid.submenu = submenu
        
        let product = NSApp.mainMenu?.item(withTitle: "Product")
        product?.submenu?.addItem(cichlid)
    }
    
    func deleteDeriveDataOfCurrentProject() {
        guard let projectName = XcodeHelpers.currentProductName() else {
            alert("Not found the DerivedData directory")
            return
        }
        
        let success = Cleaner.clearDerivedDataForProject(projectName)
        let message = success ?
            "successful in delete the DelivedData" :
            "failed to delete the DerivedData"
        alert(message)
    }
    
    func openDeriveDataOfCurrentProject() {
        guard
        let projectName = XcodeHelpers.currentProductName(),
        let path = Cleaner.derivedDataPath(projectName) else {
            alert("Not found the DerivedData directory")
            return
        }
        
        let task = Process()
        task.launchPath = "/usr/bin/open"
        task.arguments = [ path.absoluteString ]
        task.standardOutput = Pipe()
        task.launch()
    }
    
    func deleteAllDeriveData() {
        _ = confirm("Are you sure you want to delete?") { success in
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
    
    func deleteAllArchiveData() {
        _ = confirm("Are you sure you want to delete?") { success in
            guard success else {
                return
            }
            
            var success = true
            let path = "\(NSHomeDirectory())/Library/Developer/Xcode/Archives"
            let fileManager = FileManager.default
            do {
                let directories = try fileManager.contentsOfDirectory(atPath: path)
                try directories.forEach { directory in
                    let URL = Foundation.URL(fileURLWithPath: path).appendingPathComponent(directory)
                    try fileManager.removeItem(at: URL)
                    // retry once
                    if fileManager.fileExists(atPath: URL.absoluteString) {
                        try fileManager.removeItem(at: URL)
                    }
                    success = success && !fileManager.fileExists(atPath: URL.absoluteString)
                }
            }
            catch let error {
                success = false
                print("Cichlid: Failed to remove directory: \(path) -> \(error)")
            }
            let message = success ?
                "successful in delete the ArchiveData" :
                "failed to delete the ArchiveData"
            self.alert(message)
        }
    }
    
    // MARK: alert
    
    fileprivate func alert(_ informativeText: String) {
        let alert = NSAlert()
        alert.messageText = "Cichlid"
        alert.informativeText = informativeText
        alert.runModal()
    }
    
    fileprivate func confirm(_ informativeText: String, completion: ((Bool) -> Void)?) -> Bool {
        let alert = NSAlert()
        alert.alertStyle = .warning
        alert.messageText = "Cichlid"
        alert.informativeText = informativeText
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")
        let result = alert.runModal() == NSAlertFirstButtonReturn
        completion?(result)
        return result
    }
    
}
