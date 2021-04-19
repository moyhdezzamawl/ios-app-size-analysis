//
//  SizeAnalysisData.swift
//  
//
//  Created by Moises Hernandez on 18/04/21.
//

import Foundation

struct SizeAnalysisData {
    
    var rowCount: Int = 0
    var length: Int = 0
    var size: Int = 0
    var fileCount: Int = 0
    var fileCategorySizes: [FileCategory: Int]?
    var dependencySizes: [String: Int]?
    
    var filesData: [FileData] = [] {
        didSet {
            self.rowCount = self.filesData.count
            if self.fileCategorySizes == nil ||
                self.dependencySizes == nil {
                self.calculateSizes()
            }
        }
    }
    
    var sizeInMB: Double {
        Double(size) / 1_000_000
    }
    
    var lengthInMB: Double {
        Double(length) / 1_000_000
    }
    
    var fileCountForMetrics: Double {
        Double(fileCount)
    }
    
    var dependenceisSizeInMB: Double {
        let size: Double = self.dependencySizes?.reduce(0, { $0 + Double($1.value) }) ?? 0
        return size / 1_000_000
    }
    
    static func factory(with str: String) -> SizeAnalysisData? {
        let data = str
            .trimmingCharacters(in: .whitespaces)
            .components(separatedBy: " ")
            .filter({ !$0.isEmpty })
        
        guard data.count == 5 else { return nil }
        
        return SizeAnalysisData(length: Int(data[0]) ?? 0,
                                size: Int(data[1]) ?? 0,
                                fileCount: Int(data[3]) ?? 0)
    }
    
    mutating func calculateSizes() {
        var categorySizes = [FileCategory: Int]()
        var dependencySizes = [String: Int]()
        for fileData in filesData {
            categorySizes.sum(fileData.size, forKey: fileData.category)

            if fileData.name.contains(".bundle") {
                addBundleSizeTo(dependencySizes: &dependencySizes,
                                fileData: fileData)
            } else if fileData.name.contains("/Frameworks") {
                addFrameworkSize(to: &dependencySizes, fileData: fileData)
            }
        }
        if fileCategorySizes == nil {
            self.fileCategorySizes = categorySizes
        }
        if self.dependencySizes == nil {
            self.dependencySizes = dependencySizes
        }
    }
    
    func addFrameworkSize(to dependencySizes: inout [String: Int], fileData: FileData) {
        let components = fileData.name.components(separatedBy: "/")
        guard components.count > 4 else { return }
        let frameworkName = components[3]
        dependencySizes.sum(fileData.size, forKey: frameworkName)
    }
    
    func addBundleSizeTo(dependencySizes: inout [String: Int], fileData: FileData) {
        let components = fileData.name.components(separatedBy: "/")
        guard components.count > 3 else { return }
        let bundleName = components[2]
        dependencySizes.sum(fileData.size, forKey: bundleName)
    }
}

extension Dictionary where Key: Hashable, Value == Int {
    
    mutating func sum(_ value: Value, forKey key: Key) {
        let dependencySum = (self[key] ?? 0) + value
        self.updateValue(dependencySum, forKey: key)
    }
}



