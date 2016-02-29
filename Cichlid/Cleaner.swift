//
//  Cleaner.swift
//  Cichlid
//
//  Created by Toshihiro Morimoto on 2/29/16.
//  Copyright © 2016 Toshihiro Morimoto. All rights reserved.
//

import Foundation

struct Cleaner {
    
    static func clearDerivedDataForProject(projectName: String) {
        let name = projectName.stringByReplacingOccurrencesOfString(" ", withString: "_")
        let prefix = "\(name)-"
        let paths = derivedDataPaths(prefix)
        removeDirectoriesAtPaths(paths)
    }
    
}

extension Cleaner {
    
    private static func derivedDataPaths(prefix: String? = nil) -> [NSURL] {
        var paths = [NSURL]()
        if let derivedDataPath = derivedDataLocation() {
            do {
                let directories = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(derivedDataPath)
                directories.forEach { directory in
                    let path = NSURL(fileURLWithPath: derivedDataPath).URLByAppendingPathComponent(directory)
                    if let prefix = prefix where directory.hasPrefix(prefix) {
                        paths.append(path)
                    }
                    else if prefix == nil {
                        paths.append(path)
                    }
                }
            }
            catch {
                print("Cichlid: Failed to fetching derived data directories: \(derivedDataPath)")
            }
        }
        return paths
    }
    
    private static func derivedDataLocation() -> String? {
        guard let workspace = XcodeHelpers.currentWorkSpace() else {
            return nil
        }
        
        let workspaceArena = workspace.valueForKeyPath("_workspaceArena")
        return workspaceArena?.valueForKeyPath("derivedDataLocation._pathString") as? String
    }
    
    private static func removeDirectoriesAtPaths(paths: [NSURL]) -> Bool {
        var success = true
        paths.forEach { path in
            success = success && removeDirectoryAtPath(path)
        }
        return success
    }
    
    private static func removeDirectoryAtPath(path: NSURL) -> Bool {
        do {
            try NSFileManager.defaultManager().removeItemAtURL(path)
        }
        catch let error {
            print("Cichlid: Failed to remove directory: \(path) -> \(error)")
        }
        return !NSFileManager.defaultManager().fileExistsAtPath(path.absoluteString)
    }
    
}