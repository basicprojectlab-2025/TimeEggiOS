//
//  Extensions.swift
//  TimeEgg
//
//  Created by donghyeon choi on 9/22/25.
//

import Foundation
import SwiftUI
import UIKit
import CoreLocation

// MARK: - Color Extensions
extension Color {
    static let timeEggPrimary = Color(red: 0.2, green: 0.6, blue: 0.8)
    static let timeEggSecondary = Color(red: 0.9, green: 0.7, blue: 0.3)
    static let timeEggAccent = Color(red: 0.8, green: 0.4, blue: 0.6)
}

// MARK: - Date Extensions
extension Date {
    func timeAgo() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }
    
    func formattedString() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: self)
    }
}

// MARK: - String Extensions
extension String {
    func isValidEmail() -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: self)
    }
    
    func localized() -> String {
        return NSLocalizedString(self, comment: "")
    }
}

// MARK: - UIImage Extensions
extension UIImage {
    func resized(to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    func compressed(quality: CGFloat = 0.8) -> Data? {
        return jpegData(compressionQuality: quality)
    }
    
    func aspectRatio() -> CGFloat {
        return size.width / size.height
    }
}

// MARK: - CLLocation Extensions
extension CLLocation {
    func distanceString(from location: CLLocation) -> String {
        let distance = self.distance(from: location)
        
        if distance < 1000 {
            return "\(Int(distance))m"
        } else {
            let km = distance / 1000
            return String(format: "%.1fkm", km)
        }
    }
}

// MARK: - View Extensions
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
    
    func customShadow(color: Color = .black, radius: CGFloat = 4, x: CGFloat = 0, y: CGFloat = 2) -> some View {
        self.shadow(color: color, radius: radius, x: x, y: y)
    }
}

// MARK: - RoundedCorner Shape
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Array Extensions
extension Array where Element: Hashable {
    mutating func removeDuplicates() {
        self = Array(Set(self))
    }
}

// MARK: - Optional Extensions
extension Optional where Wrapped == String {
    var isEmptyOrNil: Bool {
        return self?.isEmpty ?? true
    }
}

// MARK: - Bundle Extensions
extension Bundle {
    var appVersion: String {
        return infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }
    
    var buildNumber: String {
        return infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
    }
}
