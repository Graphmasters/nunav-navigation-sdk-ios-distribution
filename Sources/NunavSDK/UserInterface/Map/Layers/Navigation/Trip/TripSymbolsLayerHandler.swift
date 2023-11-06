import GMMapUtility
import Mapbox
import NunavSDKMultiplatform

open class TripSymbolsLayerHandler: MGLStyleLayersHandler {
    private enum Constants {
        static let layerIdentifier: String = "TRIP_SYMBOLS_LAYER_IDENTIFIER"
        static let sourceIdentifier: String = "TRIP_SYMBOLS_SOURCE_IDENTIFIER"
    }

    private let identifierPrefix: String
    private let mapTheme: MapTheme
    private let showDestinationMetaData: Bool

    private let measurementSystemProvider: MeasurementSystemProvider = LocaleMeasurementSystemProvider(
        locale: .autoupdatingCurrent)
    private let distanceConverter: DistanceConverter = RoundedDistanceConverter()
    private let durationConverter: DurationConverter = CompactDurationConverter()

    public init(
        identifierPrefix: String,
        mapLayerManager: MapboxMapLayerManager?,
        mapTheme: MapTheme,
        showDestinationMetaData: Bool = false
    ) {
        self.identifierPrefix = identifierPrefix
        self.mapTheme = mapTheme
        self.showDestinationMetaData = showDestinationMetaData

        super.init(mapLayerManager: mapLayerManager)
    }

    override public func setup() {
        super.setup()
        mapLayerManager?.add(shapeSource: source, useFeatureCache: true)

        try? mapLayerManager?.addRouteSymbolLayer(layer: layer)

        Symbol.allCases.forEach {
            mapLayerManager?.add(
                image: mapTheme == .light ? $0.icon : $0.darkIcon,
                for: $0.imageName
            )
        }
    }

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

    override public func updateVisibility(_ visible: Bool) {
        if visible {
            mapLayerManager?.showLayer(with: layer.identifier)
        } else {
            mapLayerManager?.hideLayer(with: layer.identifier)
        }
    }

    // MARK: - Refresh Source

    private func firstStopDuration(route: Route?) -> MGLPointFeature? {
        guard showDestinationMetaData, let route = route else {
            return nil
        }

        let latLng = route.destinationInfo.destination?.location
            ?? route.destinationInfo.parking?.location
            ?? route.destination.latLng

        let feature = MGLPointFeature()
        feature.coordinate = latLng.clLocationCoordinate2D
        feature.attributes[DefaultIconLayer.textKey] = [
            LabelParser.shared.parseTitle(label: route.destination.label.split(separator: "\n").joined(separator: ", ")),
            durationConverter.convert(duration: route.remainingTravelTime).formattedString()
        ].joined(separator: "\n")
        return feature
    }

    private func getDestinationMetaData(route: Route) -> String {
        [
            durationConverter.convert(
                duration: route.remainingTravelTime
            ).formattedString(),
            distanceConverter.convert(
                length: route.distance,
                measurementSystem: measurementSystemProvider.getMeasurementSystem()
            ).formattedString()
        ].joined(separator: " • ")
    }

    private func firstStop(route: Route?, destinations: [LatLng]?) -> LatLng? {
        return route?.destinationInfo.destination?.location
            ?? route?.destination.latLng
            ?? destinations?.first
    }

    private func remainingStops(firstStop: LatLng, destinations: [LatLng]?) -> [LatLng] {
        return destinations?.filter {
            $0 != firstStop
        } ?? []
    }

    private func firstStopPin(latLng: LatLng, destinations: [LatLng]) -> MGLPointFeature {
        guard destinations.count > 0 else {
            return destinationPin(latLng: latLng)
        }
        return checkpointPin(latLng: latLng)
    }

    private func parkingPin(route: Route?) -> MGLPointFeature? {
        guard let parkingStop = route?.destinationInfo.parking?.location else {
            return nil
        }
        return featurePin(
            latLng: parkingStop,
            imageName: Symbol.parkingArea.imageName
        )
    }

    private func remainingStopPins(destinations: [LatLng]) -> [MGLPointFeature] {
        guard destinations.count > 0 else {
            return []
        }
        var features = destinations.prefix(destinations.count - 1).map { checkpointPin(latLng: $0) }
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

    // MARK: - Source and Layer

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
}

extension Array where Element == Route.DestinationInfo {
    var destination: Route.DestinationInfo? {
        return first(where: { $0.type.lowercased() == "destination" })
    }

    var parking: Route.DestinationInfo? {
        return first(where: { $0.type.lowercased() == "parking" })
    }
}
