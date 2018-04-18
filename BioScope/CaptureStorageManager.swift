//
//  CaptureStorageManager.swift
//  BioScope
//
//  Created by Timothy DenOuden on 6/20/17.
//  Copyright © 2017 Timothy DenOuden. All rights reserved.
//
//  This class's purpose is to handle all interactions with the system's files

import Foundation

class CaptureStorageManager {
    
    static let DB_PATH = documentsDirectoryURL().absoluteString + "/db.sqlite3"
    static let CAPTURES_TABLE_NAME = "captures"
    static let LABELS_TABLE_NAME = "labels"
    static var captures = [Capture]()
    
    public static func save(capture: Capture) {
        captures.append(capture)
    }
    
    public static func removeCapture(capture: Capture) {
        captures = captures.filter() { $0 !== capture }
    }
    
    public static func getAllCaptures() -> [Capture] {
        return captures
    }
    
    public static func save(label: Label) {
        
    }
    
    public static func removeAllFilesInDocumentsDirectory() -> Bool {
        return false
    }
    
    public static func test() {
        
    }
    
    //experiments, caputures, labels, location
    public static func firstRunSetup() {
        let capture = PhotoCapture(title: "Blue Cells", zoom: 1, image: #imageLiteral(resourceName: "blueCells"))
        capture.tags.append("nucleus")
        capture.tags.append("cell wall")
        capture.tags.append("Allium cepa")
        captures.append(capture)
        
        let pink = PhotoCapture(title: "Pink Cells", zoom: 1, image: #imageLiteral(resourceName: "pinkCells"))
        pink.tags.append("nucleus")
        captures.append(pink)
        
        let leg = PhotoCapture(title: "Insect Leg", zoom: 1, image: #imageLiteral(resourceName: "leg"))
        leg.tags.append("insect")
        captures.append(leg)
        
        let purple = PhotoCapture(title: "Cross Section", zoom: 1, image: #imageLiteral(resourceName: "purpleCells"))
        purple.tags.append("cells")
        purple.tags.append("purple")
        captures.append(purple)
    }
    
    private static func documentsDirectoryURL() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    private static func photosDirectoryURL() -> URL {
        return documentsDirectoryURL().appendingPathComponent("photos", isDirectory: true)
    }
    
    private static func contentsOfDirectoryAtURL(url: URL) -> [URL] {
        guard let urls = try? FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: [], options: .skipsHiddenFiles) else {return []}
        return urls
    }
}
