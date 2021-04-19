//
//  SizeAnalysis.swift
//  
//
//  Created by Moises Hernandez on 18/04/21.
//

import Foundation

class SizeAnalysis {
    
    var sizeAnalysisData: SizeAnalysisData?
    
    init() throws {
        self.sizeAnalysisData = try self.readSizeAlaysisData()
    }
    
    func readSizeAlaysisData() throws -> SizeAnalysisData {
        let environment: [String: String] = ProcessInfo.processInfo.environment
        guard let ipaPath = environment["IPA_PATH"] else {
            print("Please provide the export and ipa path")
            exit(EXIT_FAILURE)
        }
        let zipPath = "ExampleApp.zip"
        let sizeAnalysisDataPath = "size-analysis-data.txt"
        
        shell("cp \(ipaPath) \(zipPath)")
        shell("unzip -v \(zipPath) > \(sizeAnalysisDataPath)")
        shell("rm \(zipPath)")
        
        let data = try String(contentsOfFile: sizeAnalysisDataPath, encoding: .utf8)
        let sizeAlaysisData = data.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: .newlines)
        let filesData = sizeAlaysisData.compactMap(FileData.factory)
        var report = SizeAnalysisData.factory(with: sizeAlaysisData.last ?? "") ?? SizeAnalysisData()
        report.filesData = filesData
        
        shell("rm \(sizeAnalysisDataPath)")
        
        return report
    }
    
    @discardableResult
    func shell(_ command: String) -> String {
        let task = Process()
        let pipe = Pipe()
        
        task.standardOutput = pipe
        task.standardError = pipe
        task.arguments = ["-c", command]
        task.launchPath = "/bin/zsh"
        task.launch()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)!
        
        return output
    }
    
    func prettyPrinted() -> String {
        guard let data = self.sizeAnalysisData else {
            return "The analysis has not be done yet"
        }
        var analysis = ""
        analysis += "Size: \(data.sizeInMB.rounded(toPlaces: 2)) MB\n"
        analysis += "Lenght: \(data.lengthInMB.rounded(toPlaces: 2)) MB\n"
        analysis += "File count: \(data.fileCount)\n"
        analysis += "Dependencies size: \(data.dependenceisSizeInMB.rounded(toPlaces: 2)) MB\n"
        let categorySizes = data.fileCategorySizes ?? [:]
        for category in categorySizes.keys {
            let categorySize = categorySizes[category] ?? 0
            let sizeInMb = Double(categorySize) / 1_000_000
            analysis += "\(category.rawValue) size: \(sizeInMb.rounded(toPlaces: 2)) MB, \(Int(sizeInMb * 100 / data.sizeInMB))% of total app size\n"
        }
        return analysis
    }
    
}

extension String {

    var fileName: String {
        URL(fileURLWithPath: self).deletingPathExtension().lastPathComponent
    }

    var fileExtension: String {
        URL(fileURLWithPath: self).pathExtension
    }
}

extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}


