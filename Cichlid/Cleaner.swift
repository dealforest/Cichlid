//
//  Cleaner.swift
//  Cichlid
//
//  Created by Toshihiro Morimoto on 2/29/16.
//  Copyright © 2016 Toshihiro Morimoto. All rights reserved.
//

import Foundation

struct Cleaner {
    
    static func clearDerivedDataForProject(projectName: String) -> Bool {
        let prefix = prefixForDerivedDataRule(projectName)
        let paths = derivedDataPaths(prefix)
        return removeDirectoriesAtPaths(paths)
    }
    
    static func clearAllDerivedData() -> Bool {
        let paths = derivedDataPaths()
        return removeDirectoriesAtPaths(paths)
    }
    
    static func derivedDataPath(projectName: String) -> NSURL? {
        let prefix = prefixForDerivedDataRule(projectName)
        let paths = derivedDataPaths(prefix)
        return paths.first
    }
    
}

extension Cleaner {
    
    private static func derivedDataPaths(prefix: String? = nil) -> [NSURL] {
        var paths = [NSURL]()
        if let derivedDataPath = XcodeHelpers.derivedDataPath() {
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
    
    private static func removeDirectoriesAtPaths(paths: [NSURL]) -> Bool {
        return paths.reduce(true) { $0 && removeDirectoryAtPath($1) }
    }
    
    private static func removeDirectoryAtPath(path: NSURL) -> Bool {
        let fileManager = NSFileManager.defaultManager()
        do {
            try fileManager.removeItemAtURL(path)
            
            // retry once
            if fileManager.fileExistsAtPath(path.absoluteString) {
                try fileManager.removeItemAtURL(path)
            }
        }
        catch let error {
            print("Cichlid: Failed to remove directory: \(path) -> \(error)")
        }
        return !NSFileManager.defaultManager().fileExistsAtPath(path.absoluteString)
    }
    
    private static func prefixForDerivedDataRule(projectName: String) -> String {
        let name = projectName.stringByReplacingOccurrencesOfString(" ", withString: "_")
        return "\(name)-"
    }
    
}
