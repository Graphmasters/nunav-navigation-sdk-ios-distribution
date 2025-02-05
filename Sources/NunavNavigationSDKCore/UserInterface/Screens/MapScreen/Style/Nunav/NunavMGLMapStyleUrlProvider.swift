import Foundation
import GMMapUtility

final class NunavMGLMapStyleUrlProvider: MGLMapStyleUrlProvider {
    func mapStyle(forMapTheme mapTheme: MapTheme) -> URL {
        switch mapTheme {
        case .light:
            return URL(string: "https://tiles.graphmasters.net/styles/nunav-light-mobile-v1.1/style.json")!
        case .dark:
            return URL(string: "https://tiles.graphmasters.net/styles/nunav-dark-mobile-v1.1/style.json")!
        }
    }
}
