//
//  XcodeHelpers.swift
//  Cichlid
//
//  Created by Toshihiro Morimoto on 2/29/16.
//  Copyright © 2016 Toshihiro Morimoto. All rights reserved.
//

import Foundation
import AppKit


struct XcodeHelpers {
    
    static func currentWorkSpace() -> AnyObject? {
        guard
        let anyClass = NSClassFromString("IDEWorkspaceWindowController") as? NSObject.Type,
        let windowControllers = anyClass.valueForKey("workspaceWindowControllers") as? [NSObject] else {
            return nil
        }
        
        for controller in windowControllers {
            if
            let isKeyWindow = controller.valueForKeyPath("window.isKeyWindow") as? Bool where isKeyWindow,
            let workspace = controller.valueForKey("_workspace") {
                return workspace
            }
        }
        return nil
    }
    
    static func currentProductName() -> String? {
        guard let workspace = currentWorkSpace() else {
            return nil
        }
        
        return workspace.valueForKey("name") as? String
    }
    
    static func isCleanBuildOperation(object: AnyObject) -> Bool {
        guard
        let targetClass = NSClassFromString("IDEBuildOperation")
        where object.isKindOfClass(targetClass),
        let purpose = object.valueForKey("purpose") as? Int else {
            return false
        }
        
        return purpose == 1
    }
    
        
}
