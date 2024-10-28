import GMMapUtility
import Mapbox
import NunavSDKMultiplatform

open class TripSymbolsLayerHandler: MGLStyleLayersHandler {
    // MARK: Nested Types

    private enum Constants {
        static let layerIdentifier: String = "TRIP_SYMBOLS_LAYER_IDENTIFIER"
        static let sourceIdentifier: String = "TRIP_SYMBOLS_SOURCE_IDENTIFIER"
    }

    // MARK: Properties

    private let identifierPrefix: String
    private let showDestinationMetaData: Bool

    private let measurementSystemProvider: MeasurementSystemProvider = LocaleMeasurementSystemProvider(
        locale: .autoupdatingCurrent)
    private let distanceConverter: DistanceConverter = RoundedDistanceConverter()
    private let durationConverter: DurationConverter = CompactDurationConverter()

    private lazy var source = MGLShapeSource(
        identifier: identifierPrefix + Constants.sourceIdentifier,
        shapes: [],
        options: nil
    )

    private lazy var layer: MGLStyleLayer = TripMapLayer(
        identifier: identifierPrefix + Constants.layerIdentifier,
        source: source,
        mapTheme: mapTheme
    )

    // MARK: Lifecycle

    public init(
        identifierPrefix: String,
        mapLayerManager: MapboxMapLayerManager?,
        mapTheme: MapTheme,
        showDestinationMetaData: Bool = false
    ) {
        self.identifierPrefix = identifierPrefix
        self.showDestinationMetaData = showDestinationMetaData

        super.init(mapLayerManager: mapLayerManager, mapTheme: mapTheme)
    }

    override public func setup() {
        super.setup()
        mapLayerManager?.add(shapeSource: source, useFeatureCache: true)

        try? mapLayerManager?.addRouteSymbolLayer(layer: layer)

        for item in Symbol.allCases {
            mapLayerManager?.add(
                image: mapTheme == .light ? item.icon : item.darkIcon,
                for: item.imageName
            )
        }
    }

    // MARK: Overridden Functions

    override public func updateVisibility(_ visible: Bool) {
        if visible {
            mapLayerManager?.showLayer(with: layer.identifier)
        } else {
            mapLayerManager?.hideLayer(with: layer.identifier)
        }
    }

    // MARK: Functions

    public func refresh(origin _: LatLng? = nil, destinations: [LatLng]?, route: Route? = nil) {
        guard let firstStop = firstStop(route: route, destinations: destinations) else {
            try? mapLayerManager?.clear(source: source)
            return
        }

        let remainingStops = remainingStops(
            firstStop: firstStop,
            destinations: destinations
        )

        let features: [MGLPointFeature] = [
            firstStopPin(latLng: firstStop, destinations: remainingStops),
            parkingPin(route: route),
            firstStopDuration(route: route)
        ].compactMap { $0 } + remainingStopPins(destinations: remainingStops)

        try? mapLayerManager?.set(
            shape: MGLShapeCollectionFeature(shapes: features),
            on: source
        )
    }

    private func firstStopDuration(route: Route?) -> MGLPointFeature? {
        guard showDestinationMetaData, let route = route else {
            return nil
        }

        let feature = MGLPointFeature()
        feature.coordinate = route.destinationInformation.latLng.clLocationCoordinate2D
        feature.attributes[DefaultIconLayer.textKey] = [
            LabelParser.shared.parseTitle(label: route.destination.label.split(separator: "\n").joined(separator: ", ")),
            durationConverter.convert(duration: route.totalTravelTime).formattedString()
        ].joined(separator: "\n")
        return feature
    }

    private func firstStop(route: Route?, destinations _: [LatLng]?) -> LatLng? {
        return route?.destinationInformation.latLng
    }

    private func remainingStops(firstStop: LatLng, destinations: [LatLng]?) -> [LatLng] {
        return destinations?.filter {
            $0 != firstStop
        } ?? []
    }

    private func firstStopPin(latLng: LatLng, destinations: [LatLng]) -> MGLPointFeature {
        guard !destinations.isEmpty else {
            return destinationPin(latLng: latLng)
        }
        return checkpointPin(latLng: latLng)
    }

    private func parkingPin(route: Route?) -> MGLPointFeature? {
        guard let parkingStop = route?.destinationInformation.parkingInformation?.latLng else {
            return nil
        }
        return featurePin(
            latLng: parkingStop,
            imageName: Symbol.parkingArea.imageName
        )
    }

    private func remainingStopPins(destinations: [LatLng]) -> [MGLPointFeature] {
        guard !destinations.isEmpty else {
            return []
        }
        var features = destinations.prefix(destinations.count - 1).map { self.checkpointPin(latLng: $0) }
        if let lastCheckPoint = destinations.last {
            features.append(destinationPin(latLng: lastCheckPoint))
        }
        return features
    }

    private func destinationPin(latLng: LatLng) -> MGLPointFeature {
        return featurePin(latLng: latLng, imageName: Symbol.destination.imageName)
    }

    private func checkpointPin(latLng: LatLng) -> MGLPointFeature {
        return featurePin(latLng: latLng, imageName: Symbol.checkpoint.imageName)
    }

    private func featurePin(latLng: LatLng, imageName: String) -> MGLPointFeature {
        let feature = MGLPointFeature()
        feature.coordinate = CLLocationCoordinate2D(
            latitude: latLng.latitude,
            longitude: latLng.longitude
        )
        feature.attributes[DefaultIconLayer.iconNameKey] = imageName
        return feature
    }
}
