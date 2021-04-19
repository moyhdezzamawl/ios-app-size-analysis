import Foundation

guard let sizeAnalysis = try? SizeAnalysis() else {
    print("somethig went wrong")
    exit(EXIT_FAILURE)
}
print(sizeAnalysis.prettyPrinted())
