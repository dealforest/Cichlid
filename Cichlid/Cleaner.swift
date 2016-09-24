//
//  Cleaner.swift
//  Cichlid
//
//  Created by Toshihiro Morimoto on 2/29/16.
//  Copyright © 2016 Toshihiro Morimoto. All rights reserved.
//

import Foundation

struct Cleaner {
    
    static func clearDerivedDataForProject(_ projectName: String) -> Bool {
        let prefix = prefixForDerivedDataRule(projectName)
        let paths = derivedDataPaths(prefix)
        return removeDirectoriesAtPaths(paths)
    }
    
    static func clearAllDerivedData() -> Bool {
        let paths = derivedDataPaths()
        return removeDirectoriesAtPaths(paths)
    }
    
    static func derivedDataPath(_ projectName: String) -> URL? {
        let prefix = prefixForDerivedDataRule(projectName)
        let paths = derivedDataPaths(prefix)
        return paths.first
    }
    
}

extension Cleaner {
    
    fileprivate static func derivedDataPaths(_ prefix: String? = nil) -> [URL] {
        var paths = [URL]()
        if let derivedDataPath = XcodeHelpers.derivedDataPath() {
            do {
                let directories = try FileManager.default.contentsOfDirectory(atPath: derivedDataPath)
                directories.forEach { directory in
                    let path = URL(fileURLWithPath: derivedDataPath).appendingPathComponent(directory)
                    if let prefix = prefix , directory.hasPrefix(prefix) {
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
    
    fileprivate static func removeDirectoriesAtPaths(_ paths: [URL]) -> Bool {
        return paths.reduce(true) { $0 && removeDirectoryAtPath($1) }
    }
    
    fileprivate static func removeDirectoryAtPath(_ path: URL) -> Bool {
        let fileManager = FileManager.default
        do {
            try fileManager.removeItem(at: path)
            
            // retry once
            if fileManager.fileExists(atPath: path.absoluteString) {
                try fileManager.removeItem(at: path)
            }
        }
        catch let error {
            print("Cichlid: Failed to remove directory: \(path) -> \(error)")
        }
        return !FileManager.default.fileExists(atPath: path.absoluteString)
    }
    
    fileprivate static func prefixForDerivedDataRule(_ projectName: String) -> String {
        let name = projectName.replacingOccurrences(of: " ", with: "_")
        return "\(name)-"
    }
    
}
