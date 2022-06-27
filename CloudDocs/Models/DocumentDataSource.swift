import Foundation

class DocumentDataSource {
    
    var type: DocumentType?
    
    var fields: [DocumentField] {
        switch type {
        case .nationalPassport:
            return [
                DocumentField(title: "Passport series and number", subtitle: ""),
                DocumentField(title: "Full name", subtitle: ""),
                DocumentField(title: "Full name (in Latin letters)", subtitle: ""),
                DocumentField(title: "Date of birth", subtitle: ""),
                DocumentField(title: "Gender", subtitle: ""),
                DocumentField(title: "Subdivision code", subtitle: ""),
                DocumentField(title: "Issued by", subtitle: ""),
                DocumentField(title: "Date of issue", subtitle: ""),
                DocumentField(title: "Registered address", subtitle: ""),
                DocumentField(title: "Registered by", subtitle: ""),
                DocumentField(title: "Registration date", subtitle: ""),
            ]
        case .internationalPassport:
            return [
                DocumentField(title: "Passport number", subtitle: ""),
                DocumentField(title: "Full name", subtitle: ""),
                DocumentField(title: "Surname name (in Latin letters)", subtitle: ""),
                DocumentField(title: "Date of birth", subtitle: ""),
                DocumentField(title: "Place of birth", subtitle: ""),
                DocumentField(title: "Gender", subtitle: ""),
                DocumentField(title: "Issued by", subtitle: ""),
                DocumentField(title: "Date of issue", subtitle: ""),
                DocumentField(title: "Expiration date", subtitle: ""),
            ]
        case .birthCertificate:
            return [
                DocumentField(title: "Series and number", subtitle: ""),
                DocumentField(title: "Full name", subtitle: ""),
                DocumentField(title: "Surname name (in Latin letters)", subtitle: ""),
                DocumentField(title: "Date of birth", subtitle: ""),
                DocumentField(title: "Place of birth", subtitle: ""),
                DocumentField(title: "Place of registration", subtitle: ""),
            ]
        case .foreignDocument:
            return [
                DocumentField(title: "Series and number", subtitle: ""),
                DocumentField(title: "Full name", subtitle: ""),
                DocumentField(title: "Surname name (in Latin letters)", subtitle: ""),
                DocumentField(title: "Date of birth", subtitle: ""),
                DocumentField(title: "Gender", subtitle: ""),
                DocumentField(title: "Citizenship", subtitle: ""),
                DocumentField(title: "Issued by", subtitle: ""),
                DocumentField(title: "Date of issue", subtitle: ""),
            ]
        case .snils:
            return [
                DocumentField(title: "Number", subtitle: ""),
                DocumentField(title: "Full name", subtitle: ""),
                DocumentField(title: "Date of birth", subtitle: ""),
                DocumentField(title: "Place of birth", subtitle: ""),
                DocumentField(title: "Registration date", subtitle: ""),
            ]
        case .inn:
            return [
                DocumentField(title: "TIN", subtitle: ""),
                DocumentField(title: "Series and number", subtitle: ""),
                DocumentField(title: "Full name", subtitle: ""),
                DocumentField(title: "Date of birth", subtitle: ""),
                DocumentField(title: "Issuing authority", subtitle: ""),
                DocumentField(title: "Date of issue", subtitle: ""),
            ]
        case .oms:
            return [
                DocumentField(title: "Document number", subtitle: ""),
                DocumentField(title: "Series/number of form", subtitle: ""),
                DocumentField(title: "Surname, name and patronymic", subtitle: ""),
                DocumentField(title: "Date of birth", subtitle: ""),
                DocumentField(title: "Validity period", subtitle: ""),
            ]
        case .driversLicense:
            return [
                DocumentField(title: "Full name", subtitle: ""),
                DocumentField(title: "Surname name (in Latin letters)", subtitle: ""),
                DocumentField(title: "Date of birth", subtitle: ""),
                DocumentField(title: "Place of birth", subtitle: ""),
                DocumentField(title: "Place of birth (in Latin letters)", subtitle: ""),
                DocumentField(title: "Series and number", subtitle: ""),
                DocumentField(title: "Issued by", subtitle: ""),
                DocumentField(title: "Issued by (in Latin letters)", subtitle: ""),
                DocumentField(title: "Date of issue", subtitle: ""),
                DocumentField(title: "Valid until", subtitle: ""),
                DocumentField(title: "Place of residence", subtitle: ""),
                DocumentField(title: "Special marks", subtitle: ""),
            ]
        case .vehicleRegID:
            return [
                DocumentField(title: "Certificate series/number", subtitle: ""),
                DocumentField(title: "Register sign (license plate)", subtitle: ""),
                DocumentField(title: "Identification number (VIN)", subtitle: ""),
                DocumentField(title: "Make, model", subtitle: ""),
                DocumentField(title: "Vehicle category", subtitle: ""),
                DocumentField(title: "Year of vehicle release", subtitle: ""),
                DocumentField(title: "Chassis number", subtitle: ""),
                DocumentField(title: "Body number", subtitle: ""),
                DocumentField(title: "Color", subtitle: ""),
                DocumentField(title: "Engine power", subtitle: ""),
                DocumentField(title: "Engine displacement", subtitle: ""),
                DocumentField(title: "Series and number of PTS", subtitle: ""),
                DocumentField(title: "Permissible maximum weight", subtitle: ""),
                DocumentField(title: "Weight without load", subtitle: ""),
                DocumentField(title: "Name", subtitle: ""),
                DocumentField(title: "Spetial marks", subtitle: ""),
            ]
        case .vehiclePassport:
            return [
                DocumentField(title: "Series and number of PTS", subtitle: ""),
                DocumentField(title: "Document type", subtitle: ""),
                DocumentField(title: "Identification number (VIN)", subtitle: ""),
                DocumentField(title: "Make, model", subtitle: ""),
                DocumentField(title: "Vehicle type", subtitle: ""),
                DocumentField(title: "Vehicle category", subtitle: ""),
                DocumentField(title: "Body number (cab, trailer)", subtitle: ""),
            ]
        case .osago:
            return [
                DocumentField(title: "Series and policy number", subtitle: ""),
                DocumentField(title: "Valid from", subtitle: ""),
                DocumentField(title: "Valid until", subtitle: ""),
                DocumentField(title: "Date of issue", subtitle: ""),
                DocumentField(title: "Insurance company name", subtitle: ""),
                DocumentField(title: "Insurance company address", subtitle: ""),
                DocumentField(title: "Phone number", subtitle: ""),
                DocumentField(title: "Make, model", subtitle: ""),
                DocumentField(title: "VIN number", subtitle: ""),
                DocumentField(title: "Register sign (license plate)", subtitle: ""),
                DocumentField(title: "Insurance premium", subtitle: ""),
            ]
        case .casco:
            return [
                DocumentField(title: "Series and policy number", subtitle: ""),
                DocumentField(title: "Valid from", subtitle: ""),
                DocumentField(title: "Valid until", subtitle: ""),
                DocumentField(title: "Date of issue", subtitle: ""),
                DocumentField(title: "Insurance company name", subtitle: ""),
                DocumentField(title: "Insurance company address", subtitle: ""),
                DocumentField(title: "Phone number", subtitle: ""),
                DocumentField(title: "Make, model", subtitle: ""),
                DocumentField(title: "VIN number", subtitle: ""),
                DocumentField(title: "Register sign (license plate)", subtitle: ""),
                DocumentField(title: "Insurance premium", subtitle: ""),
            ]
        case .militaryID:
            return [
                DocumentField(title: "Series and number", subtitle: ""),
                DocumentField(title: "Full name", subtitle: ""),
                DocumentField(title: "Date of issue", subtitle: ""),
                DocumentField(title: "Commissariat", subtitle: ""),
            ]
        case .vzrInsurance:
            return [
                DocumentField(title: "Policy number", subtitle: ""),
                DocumentField(title: "Valid from", subtitle: ""),
                DocumentField(title: "Valid until", subtitle: ""),
                DocumentField(title: "Insurance company name", subtitle: ""),
                DocumentField(title: "Full name", subtitle: ""),
                DocumentField(title: "Policy cost", subtitle: ""),
            ]
        default:
            return [
                DocumentField(title: "", subtitle: "")
            ]
        }
    }
}
