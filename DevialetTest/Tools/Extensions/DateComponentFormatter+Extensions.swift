//
//  DateComponentFormatter+Extensions.swift
//  DevialetTest
//
//  Created by Faustin on 15/09/2023.
//

import Foundation

extension DateComponentsFormatter {
    /*
     return duration in milliseconds between two Date()
     I will use it to check if some method have not too long execution duration
     */
    func difference(from fromDate: Date, to toDate: Date) -> String? {
        self.allowedUnits = [NSCalendar.Unit.second]
        self.maximumUnitCount = 8
        self.unitsStyle = .full
        
        allowsFractionalUnits = true
        
        guard let firstPart = self.string(from: fromDate, to: toDate) else { return nil }
        
        let milliseconds = abs(toDate.timeIntervalSince(fromDate)).remainder(dividingBy: 1) * 1000
        let numberFormatter = NumberFormatter()
        numberFormatter.maximumFractionDigits = 0
        
        guard let secondPart = numberFormatter.string(from: milliseconds as NSNumber) else { return nil }
        
        return "\(firstPart) \(secondPart) milliseconds"
    }
}
