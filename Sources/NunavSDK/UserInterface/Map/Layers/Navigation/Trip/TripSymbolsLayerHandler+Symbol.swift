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
        icon: Asset.Map.checkPointTripSymbol.image,
        darkIcon: Asset.Map.checkPointTripSymbolDark.image,
        imageName: "checkpoint"
    )

    static let destination = TripSymbolsLayerHandler.Symbol(
        icon: Asset.Map.destinationTripSymbol.image,
        darkIcon: Asset.Map.destinationTripSymbolDark.image,
        imageName: "destination"
    )

    static let parkingArea = TripSymbolsLayerHandler.Symbol(
        icon: Asset.Map.parkingPin.image,
        darkIcon: Asset.Map.parkingPinDark.image,
        imageName: "parkingArea"
    )

    static let origin = TripSymbolsLayerHandler.Symbol(
        icon: Asset.Map.originTripSymbol.image,
        darkIcon: Asset.Map.originTripSymbolDark.image,
        imageName: "origin"
    )
}
