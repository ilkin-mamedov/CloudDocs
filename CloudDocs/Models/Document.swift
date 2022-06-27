import Foundation
import UIKit

struct Document {
    let id: String
    let type: DocumentType
    let title: String
    
    public static func typeToString(type: DocumentType) -> String {
        switch type {
        case .nationalPassport:
            return "National Passport"
        case .internationalPassport:
            return "International Passport"
        case .birthCertificate:
            return "Birth Certificate"
        case .foreignDocument:
            return "Foreign Document"
        case .snils:
            return "SNILS"
        case .inn:
            return "INN"
        case .oms:
            return "OMS"
        case .driversLicense:
            return "Drivers License"
        case .vehicleRegID:
            return "Vehicle Reg ID"
        case .vehiclePassport:
            return "Vehicle Passport"
        case .osago:
            return "OSAGO"
        case .casco:
            return "CASCO"
        case .militaryID:
            return "Military ID"
        case .vzrInsurance:
            return "VZR Insurance"
        }
    }
    
    public static func stringToType(string: String) -> DocumentType {
        switch string {
        case "National Passport":
            return .nationalPassport
        case "International Passport":
            return .internationalPassport
        case "Birth Certificate":
            return .birthCertificate
        case "Foreign Document":
            return .foreignDocument
        case "SNILS":
            return .snils
        case "INN":
            return .inn
        case "OMS":
            return .oms
        case "Drivers License":
            return .driversLicense
        case "Vehicle Reg ID":
            return .vehicleRegID
        case "Vehicle Passport":
            return .vehiclePassport
        case "OSAGO":
            return .osago
        case "CASCO":
            return .casco
        case "Military ID":
            return .militaryID
        case "VZR Insurance":
            return .vzrInsurance
        default:
            return .nationalPassport
        }
    }
}
