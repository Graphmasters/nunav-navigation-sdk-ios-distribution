import Foundation
import GMMapUtility
import Mapbox

public final class NunavStyleLocalizer {
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

    public init() {}
}

extension NunavStyleLocalizer: MGLMapStyleLocalizer {
    public func localize(_ style: MGLStyle, locale: Locale) {
        supportedLayers(in: style).forEach {
            $0.text = NSExpression(forKeyPath: keyPath(for: locale))
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
