import Foundation

class DecisionTreeCreator {
    private let dataElements: [DataElement]
    
    init(dataElements: [DataElement]) {
        self.dataElements = dataElements
    }
    
    func execute() -> Node {
        return getDecisionTree(examples: dataElements)
    }
}

extension DecisionTreeCreator {
    private func getDecisionTree(
        nodeValue: NodeValue? = nil,
        examples: [DataElement],
        attributes: [Attribute] = Attribute.allCases.filter({ $0 != .severityClass }),
        parentExamples: [DataElement] = []
    ) -> Node {
        guard !examples.isEmpty else {
            return createAnswerNode(
                value: nodeValue,
                answer: getMajoritySeverityClass(for: parentExamples)
            )
        }
        
        let (isAllSameClass, isAllSameClassSeverityClass) = isAllSameClass(examples)
        
        if isAllSameClass, let value = isAllSameClassSeverityClass {
            return createAnswerNode(value: nodeValue, answer: value)
        }
        
        guard !attributes.isEmpty else {
            return createAnswerNode(
                value: nodeValue,
                answer: getMajoritySeverityClass(for: examples)
            )
        }
        
        var newAttributes = attributes
            .map({ (attribute: $0, entropyValues: getEntropy(examples, for: $0)) })
            .sorted(by: { $0.entropyValues.entropy < $1.entropyValues.entropy })
        let (attribute, (attributeValue, _)) = newAttributes.removeFirst()
        
        var childNodes: [Node] = []
        
        let lessThanOrEqualPartitionDataElements = examples.filter {
            return $0.getContinuousValue(for: attribute) <= attributeValue
        }
        childNodes.append(getDecisionTree(
            nodeValue: .lessThanOrEqual(value: attributeValue),
            examples: lessThanOrEqualPartitionDataElements,
            attributes: newAttributes.map({ $0.attribute }),
            parentExamples: examples
        ))
        let moreThanPartitionDataElements = examples.filter {
            return $0.getContinuousValue(for: attribute) > attributeValue
        }
        childNodes.append(getDecisionTree(
            nodeValue: .moreThan(value: attributeValue),
            examples: moreThanPartitionDataElements,
            attributes: newAttributes.map({ $0.attribute }),
            parentExamples: examples
        ))
        
        return Node(value: nodeValue, childrenAttribute: attribute, children: childNodes)
    }
    
    private func getSeverityClassEntropy(for dataElements: [DataElement]) -> Double {
        let totalCount = dataElements.count
        
        var countDict: [SeverityClass: Int] = [:]
        dataElements.forEach { dataElement in
            guard let count = countDict[dataElement.severityClass] else {
                countDict[dataElement.severityClass] = 1
                return
            }
            countDict[dataElement.severityClass] = count + 1
        }
        
        var entropy: Double = 0
        countDict.keys.forEach { key in
            var classCount = 0
            if let count = countDict[key] {
                classCount = count
            }
            
            let percentage = Double(classCount) / Double(totalCount)
            
            entropy += -percentage * log2(percentage)
        }
        
        return entropy
    }
    
    private func createAnswerNode(value: NodeValue?, answer: SeverityClass) -> Node {
        return Node(
            value: value,
            childrenAttribute: .severityClass,
            children: [Node(value: .severityClass(answer))]
        )
    }
    
    private func getMajoritySeverityClass(for dataElements: [DataElement]) -> SeverityClass {
        var severityClassCountDict: [SeverityClass: Int] = [:]
        dataElements.forEach { dataElement in
            guard let count = severityClassCountDict[dataElement.severityClass] else {
                severityClassCountDict[dataElement.severityClass] = 1
                return
            }
            severityClassCountDict[dataElement.severityClass] = count + 1
        }
        
        var maxCount: Int = 0
        var result = SeverityClass.one
        for severityClass in SeverityClass.allCases {
            guard 
                let count = severityClassCountDict[severityClass],
                count > maxCount
            else {
                continue
            }
            
            maxCount = count
            result = severityClass
        }
        
        return result
    }
    
    private func isAllSameClass(
        _ dataElements: [DataElement]
    ) -> (result: Bool, severityClass: SeverityClass?) {
        var severityClassCountDict: [SeverityClass: Int] = [:]
        dataElements.forEach { dataElement in
            guard let count = severityClassCountDict[dataElement.severityClass] else {
                severityClassCountDict[dataElement.severityClass] = 1
                return
            }
            severityClassCountDict[dataElement.severityClass] = count + 1
        }
        
        let totalCount = dataElements.count
        
        for severityClass in SeverityClass.allCases {
            guard severityClassCountDict[severityClass] == totalCount else {
                continue
            }
            
            return (result: true, severityClass: severityClass)
        }
        
        return (result: false, severityClass: nil)
    }
    
    private func getEntropy(
        _ dataElements: [DataElement],
        for attribute: Attribute
    ) -> (value: Double, entropy: Double) {
        let sortedDataElements = dataElements.sorted {
            return $0.getContinuousValue(for: attribute) < $1.getContinuousValue(for: attribute)
        }
        
        let totalCount = sortedDataElements.count
        let severityClassEntropy = getSeverityClassEntropy(for: dataElements)
        
        var gainEntropies: [Double: Double] = [:]
        sortedDataElements.dropLast().enumerated().forEach { index, dataElement in
            let lessThanOrEqualEntropy = getSeverityClassEntropy(
                for: Array(sortedDataElements[0...index])
            )
            let moreThanEntropy = getSeverityClassEntropy(
                for: Array(sortedDataElements[(index + 1)...(totalCount - 1)])
            )
            let gainEntropy = severityClassEntropy -
                (Double(index + 1) / Double(totalCount)) * lessThanOrEqualEntropy -
                (Double(totalCount - index + 1) / Double(totalCount)) * moreThanEntropy
            
            gainEntropies[dataElement.getContinuousValue(for: attribute)] = gainEntropy
        }
        
        if let lastDataElement = sortedDataElements.last {
            let lessThanOrEqualEntropy = getSeverityClassEntropy(
                for: Array(sortedDataElements[0..<totalCount])
            )
            let gainEntropy = severityClassEntropy - lessThanOrEqualEntropy
            
            gainEntropies[lastDataElement.getContinuousValue(for: attribute)] = gainEntropy
        }
        
        var maxGainEntropy: (value: Double, entropy: Double) = (0, 0)
        gainEntropies.keys.forEach { key in
            guard let entropy = gainEntropies[key] else { return }
            
            if maxGainEntropy.entropy < entropy {
                maxGainEntropy = (value: key, entropy: entropy)
            }
        }
        
        return maxGainEntropy
    }
}
