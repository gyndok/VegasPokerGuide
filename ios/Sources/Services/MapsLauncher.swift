import Foundation
import UIKit

enum MapsLauncher {
    @MainActor
    static func openDirections(to venue: Venue) {
        guard let url = URL(string: venue.mapsURL) else { return }
        UIApplication.shared.open(url)
    }
}
