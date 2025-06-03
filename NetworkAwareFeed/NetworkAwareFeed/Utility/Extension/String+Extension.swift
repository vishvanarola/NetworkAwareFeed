//
//  String+Extension.swift
//  NetworkAwareFeed
//
//  Created by apple on 03/06/25.
//

import Foundation

extension String {
    /// Converts an ISO8601 date string to a relative time description like "2 years ago".
    func relativeTimeFromNow() -> String {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        guard let date = isoFormatter.date(from: self) else {
            print("❌ Could not parse ISO date from string: \(self)")
            return "Invalid date"
        }
        
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full // Try .short or .abbreviated if needed

        let relativeString = formatter.localizedString(for: date, relativeTo: Date())
        return relativeString
    }
}
