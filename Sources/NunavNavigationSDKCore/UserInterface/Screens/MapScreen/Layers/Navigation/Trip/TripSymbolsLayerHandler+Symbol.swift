import UIKit

extension TripSymbolsLayerHandler {
    struct Symbol {
        let icon: UIImage
        let darkIcon: UIImage
        let imageName: String
    }
}

extension TripSymbolsLayerHandler.Symbol: CaseIterable {
    static var allCases: [TripSymbolsLayerHandler.Symbol] {
        [.checkpoint, .destination, .parkingArea, .origin]
    }
}

extension TripSymbolsLayerHandler.Symbol {
    static let checkpoint = TripSymbolsLayerHandler.Symbol(
        icon: UIImage.Map.checkPointTripSymbol,
        darkIcon: UIImage.Map.checkPointTripSymbolDark,
        imageName: "checkpoint"
    )

    static let destination = TripSymbolsLayerHandler.Symbol(
        icon: UIImage.Map.destinationTripSymbol,
        darkIcon: UIImage.Map.destinationTripSymbolDark,
        imageName: "destination"
    )

    static let parkingArea = TripSymbolsLayerHandler.Symbol(
        icon: UIImage.Map.parkingPin,
        darkIcon: UIImage.Map.parkingPinDark,
        imageName: "parkingArea"
    )

    static let origin = TripSymbolsLayerHandler.Symbol(
        icon: UIImage.Map.originTripSymbol,
        darkIcon: UIImage.Map.originTripSymbolDark,
        imageName: "origin"
    )
}
