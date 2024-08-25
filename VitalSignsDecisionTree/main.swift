import Foundation

let trainFilePath = "/Users/gustavokumasawa/Documents/UTFPR/2024.1/Sistemas Inteligentes/Trabalho 2/treino_sinais_vitais_com_label.txt"
let testFilePath = "/Users/gustavokumasawa/Documents/UTFPR/2024.1/Sistemas Inteligentes/Trabalho 2/treino_sinais_vitais_sem_label.txt"

func getParsedDataElements(from filePath: String) throws -> [DataElement] {
    let fileURL = URL(fileURLWithPath: filePath)
    
    let content = try String(contentsOf: fileURL, encoding: .utf8)
    
    let splittedContent = content.split(separator: "\n")
    
    let dataElements: [DataElement] = try splittedContent.map { contentLine in
        let params = contentLine.split(separator: ",")
        
        guard
            let id = Int(params[0]),
            let pressureQuality = Double(params[3]),
            let pulse = Double(params[4]),
            let breathing = Double(params[5]),
            let severityClassInt = Int(params[7]),
            let severityClass = SeverityClass(rawValue: severityClassInt)
        else {
            throw NSError(domain: "Mapping DataElement", code: 0)
        }
        
        return DataElement(
            id: id,
            pressureQuality: pressureQuality,
            pulse: pulse,
            breathing: breathing,
            severityClass: severityClass
        )
    }
    
    return dataElements
}

func getParsedTestDataElements(from filePath: String) throws -> [TestDataElement] {
    let fileURL = URL(fileURLWithPath: filePath)
    
    let content = try String(contentsOf: fileURL, encoding: .utf8)
    
    let splittedContent = content.split(separator: "\n")
    
    let dataElements: [TestDataElement] = try splittedContent.map { contentLine in
        let params = contentLine.split(separator: ", ")
        
        guard
            let id = Int(params[0]),
            let pressureQuality = Double(params[3]),
            let pulse = Double(params[4]),
            let breathing = Double(params[5])
        else {
            throw NSError(domain: "Mapping DataElement", code: 0)
        }
        
        return TestDataElement(
            id: id,
            pressureQuality: pressureQuality,
            pulse: pulse,
            breathing: breathing
        )
    }
    
    return dataElements
}

func getSeverityClass(for dataElement: TestDataElement, using tree: Node) -> (id: Int, severityClass: SeverityClass)? {
    var node = tree
    
    while true {
        if node.childrenAttribute == nil {
            guard case .severityClass(let severityClass) = node.value else {
                debugPrint("Leaf does not contain answer")
                return nil
            }
            
            return (id: dataElement.id, severityClass: severityClass)
        }
        
        guard
            let childrenAttribute = node.childrenAttribute,
            let childNode = node.children?.first(where: {
                if case .severityClass = $0.value {
                    return true
                }
                
                return $0.value?.passCondition(
                    dataElement.getContinuousValue(for: childrenAttribute)
                ) == true
            })
        else {
            fatalError("Not found")
        }
        
        node = childNode
    }
}

func printTree(_ tree: Node) {
    print(tree.childrenAttribute?.rawValue ?? "")
    
    var rowNodes = tree.children ?? []
    
    while !rowNodes.isEmpty {
        print(rowNodes.map({ "\($0.value?.toString() ?? "") \($0.childrenAttribute?.rawValue ?? "")" }).joined(separator: " | "))
        
        rowNodes = rowNodes.flatMap({ $0.children ?? [] })
    }
}

func run() {
    guard 
        let trainDataElements = try? getParsedDataElements(from: trainFilePath),
        let testDataElements = try? getParsedTestDataElements(from: testFilePath)
    else {
        debugPrint("Failed to parse data")
        return
    }
    
    let tree = DecisionTreeCreator(dataElements: trainDataElements).execute()
    printTree(tree)
    print("\n")
    
    var answers: [(id: Int, severityClass: SeverityClass)] = []
    
    for testDataElement in testDataElements {
        if let result = getSeverityClass(for: testDataElement, using: tree) {
            answers.append(result)
        }
    }
    
    var correctCount = 0
    
    for answer in answers {
        guard
            let correspondingAnswerElement = trainDataElements.first(where: { $0.id == answer.id }),
            correspondingAnswerElement.severityClass == answer.severityClass
        else {
            continue
        }
        
        correctCount += 1
    }
    
    let correctPercentage = Double(correctCount) / Double(testDataElements.count)
    
    print("Correct percentage: \(correctPercentage)")
}

run()

