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
        let appName = NSBundle.mainBundle().infoDictionary?["CFBundleName"] as? NSString
        if appName == "Xcode" {
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
            selector: "notificationListener:",
            name: "IDEBuildOperationDidStopNotification",
            object: nil)
    }
    
    private func cleanObserver() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func notificationListener(notification: NSNotification) {
        guard
        let object = notification.object
        where XcodeHelpers.isCleanBuildOperation(object),
        let projectName = XcodeHelpers.currentProductName() else {
            return
        }
    
        Cleaner.clearDerivedDataForProject(projectName)
    }
    
}
