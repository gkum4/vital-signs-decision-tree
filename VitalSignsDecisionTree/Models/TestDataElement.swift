//
//  TestDataElement.swift
//  ID3VitalSigns
//
//  Created by Gustavo Kumasawa on 24/08/24.
//

import Foundation

struct TestDataElement {
    let id: Int
    let pressureQuality: Double
    let pulse: Double
    let breathing: Double
    
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
