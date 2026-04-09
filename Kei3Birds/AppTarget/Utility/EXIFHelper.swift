import UIKit
import ImageIO
import CoreLocation

struct ImageMetadata {
    var latitude: Double?
    var longitude: Double?
    var takenAt: String?
    var locationName: String?
}

enum EXIFHelper {
    static func extractMetadata(from image: UIImage) async -> ImageMetadata {
        var metadata = ImageMetadata()

        guard let data = image.jpegData(compressionQuality: 1.0),
              let source = CGImageSourceCreateWithData(data as CFData, nil),
              let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any] else {
            return metadata
        }

        if let gps = properties[kCGImagePropertyGPSDictionary] as? [CFString: Any] {
            if let lat = gps[kCGImagePropertyGPSLatitude] as? Double,
               let latRef = gps[kCGImagePropertyGPSLatitudeRef] as? String {
                metadata.latitude = latRef == "S" ? -lat : lat
            }
            if let lng = gps[kCGImagePropertyGPSLongitude] as? Double,
               let lngRef = gps[kCGImagePropertyGPSLongitudeRef] as? String {
                metadata.longitude = lngRef == "W" ? -lng : lng
            }
        }

        if let exif = properties[kCGImagePropertyExifDictionary] as? [CFString: Any],
           let dateStr = exif[kCGImagePropertyExifDateTimeOriginal] as? String {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy:MM:dd HH:mm:ss"
            if let date = formatter.date(from: dateStr) {
                metadata.takenAt = ISO8601DateFormatter().string(from: date)
            }
        }

        // GPS座標から地名を逆ジオコーディング
        if let lat = metadata.latitude, let lng = metadata.longitude {
            let location = CLLocation(latitude: lat, longitude: lng)
            let geocoder = CLGeocoder()
            if let placemarks = try? await geocoder.reverseGeocodeLocation(location),
               let placemark = placemarks.first {
                let components = [placemark.administrativeArea, placemark.locality, placemark.subLocality]
                let name = components.compactMap { $0 }.joined()
                if !name.isEmpty {
                    metadata.locationName = name
                }
            }
        }

        return metadata
    }
}
