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
        let windowControllers = anyClass.value(forKey: "workspaceWindowControllers") as? [NSObject] else {
            return nil
        }
        
        for controller in windowControllers {
            if
            let isKeyWindow = controller.value(forKeyPath: "window.isKeyWindow") as? Bool , isKeyWindow,
            let workspace = controller.value(forKey: "_workspace") {
                return workspace as AnyObject?
            }
        }
        return nil
    }
    
    static func currentProductName() -> String? {
        guard let workspace = currentWorkSpace() else {
            return nil
        }
        
        return workspace.value(forKey: "name") as? String
    }
    
    static func isCleanBuildOperation(_ object: AnyObject) -> Bool {
        guard
        let targetClass = NSClassFromString("IDEBuildOperation")
        , object.isKind(of: targetClass),
        let purpose = object.value(forKey: "purpose") as? Int else {
            return false
        }
        
        return purpose == 1
    }
    
    static func derivedDataPath() -> String? {
        guard let workspace = currentWorkSpace() else {
            return nil
        }
        
        let workspaceArena = workspace.value(forKeyPath: "_workspaceArena")
        return (workspaceArena as AnyObject).value(forKeyPath: "derivedDataLocation._pathString") as? String
    }
    
}
