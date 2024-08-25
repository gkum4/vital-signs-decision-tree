import Foundation

enum NodeValue {
    case lessThanOrEqual(value: Double)
    case moreThan(value: Double)
    case severityClass(_ severityClass: SeverityClass)
    
    func passCondition(_ value: Double) -> Bool {
        switch self {
        case .lessThanOrEqual(value: let lessThanOrEqualValue):
            return value <= lessThanOrEqualValue
        case .moreThan(value: let moreThanValue):
            return value > moreThanValue
        case .severityClass(_):
            return false
        }
    }
    
    func toString() -> String {
        switch self {
        case .lessThanOrEqual(let value):
            return "<= \(value)"
        case .moreThan(let value):
            return "> \(value)"
        case .severityClass(let severityClass):
            return "\(severityClass.rawValue)"
        }
    }
}
