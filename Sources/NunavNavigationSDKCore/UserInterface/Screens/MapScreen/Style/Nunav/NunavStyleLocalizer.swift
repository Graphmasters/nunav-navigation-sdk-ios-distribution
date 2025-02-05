import Foundation
import GMMapUtility
import Mapbox

final class NunavStyleLocalizer {
    // MARK: Nested Types

    private enum Constants {
        static let supportedLayerIds: [String] = [
            "place_neighbourhood",
            "place_city",
            "place_town",
            "place_state",
            "place_village",
            "country_1",
            "country_2",
            "country_3",
            "country_label",
            "place_label_city",
            "state"
        ]
    }

    // MARK: Lifecycle

    init() {}
}

extension NunavStyleLocalizer: MGLMapStyleLocalizer {
    func localize(_ style: MGLStyle, locale: Locale) {
        for supportedLayer in supportedLayers(in: style) {
            supportedLayer.text = NSExpression(forKeyPath: keyPath(for: locale))
        }
    }
}

extension NunavStyleLocalizer {
    private func supportedLayers(in style: MGLStyle) -> [MGLSymbolStyleLayer] {
        Constants.supportedLayerIds
            .compactMap { style.layer(withIdentifier: $0) }
            .compactMap { $0 as? MGLSymbolStyleLayer }
    }

    private func keyPath(for locale: Locale) -> String {
        return (locale.languageCode).map { "name:\($0)" } ?? "name"
    }
}
