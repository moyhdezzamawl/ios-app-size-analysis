//
//  FileData.swift
//  
//
//  Created by Moises Hernandez on 18/04/21.
//

import Foundation

struct FileData: Codable {
    
    var length: Int
    var method: String
    var size: Int
    var name: String
    var category: FileCategory
    
    internal init(length: Int?, method: String, size: Int?, name: String) {
        self.length = length ?? 0
        self.method = method
        self.size = size ?? 0
        self.name = name
        self.category = FileCategory.category(for: name)
    }
    
    static func factory(with str: String) -> FileData? {
        let data = str
            .trimmingCharacters(in: .whitespaces)
            .components(separatedBy: " ")
            .filter({ !$0.isEmpty })
        
        guard data.count == 8 else { return nil }
        
        let fileData = FileData(length: Int(data[0]),
                                method: data[1],
                                size: Int(data[2]),
                                name: data[7])
        
        guard fileData.method == "Defl:N" else { return nil }
        
        return fileData
    }
}


