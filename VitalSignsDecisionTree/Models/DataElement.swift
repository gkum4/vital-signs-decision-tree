import Foundation

struct DataElement: Identifiable {
    let id: Int
    let pressureQuality: Double
    let pulse: Double
    let breathing: Double
    let severityClass: SeverityClass
    
    func getContinuousValue(for attribute: Attribute) -> Double {
        switch attribute {
        case .pressureQuality:
            return pressureQuality
        case .pulse:
            return pulse
        case .breathing:
            return breathing
        case .severityClass:
            fatalError("severityClass is not continuous")
        }
    }
}
