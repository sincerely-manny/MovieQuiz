import Foundation

extension Date {
    var dateTimeString: String {
        DateFormatter.defaultDateTime.string(from: self)
    }
}

extension DateFormatter {
    fileprivate static let defaultDateTime: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.YY hh:mm"
        return dateFormatter
    }()
}
