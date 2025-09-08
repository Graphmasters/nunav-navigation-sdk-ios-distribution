import Foundation
import GMMapUtility
import Mapbox
import MultiplatformNavigation

// swiftlint:disable:next type_body_length
class RouteTurnCommandArrowsLayerHandler: MGLStyleLayersHandler {
    // MARK: Nested Types

    private enum Constants {
        static let arrowShaftPartOneLayerIdentifier: String = "turncommand-arrows-layer-shaft-one-identifier"
        static let arrowShaftPartTwoLayerIdentifier: String = "turncommand-arrows-layer-shaft-two-identifier"
        static let arrowShaftSourcePartOneIdentifier: String = "turncommand-arrows-source-shaft-one-identifier"
        static let arrowShaftSourcePartTwoIdentifier: String = "turncommand-arrows-source-shaft-two-identifier"
        static let arrowShaftOutlineLayerPartOneIdentifier: String =
            "turncommand-arrows-outline-layer-shaft-one-identifier"
        static let arrowShaftOutlineLayerPartTwoIdentifier: String =
            "turncommand-arrows-outline-layer-shaft-two-identifier"
        static let arrowHeadLayerIdentifier: String = "turncommand-arrows-head-layer-identifier"
        static let arrowHeadSourceIdentifier: String = "turncommand-arrows-head-source-identifier"
        static let arrowHeadIconIdentifier: String = "arrowHead"
        static let defaultHalfArrowLength: Length = Length.companion.fromMeters(
            meters: 40.0
        )
        static let arrowHeadRotationKey: String = "arrowhead-rotation-key"
        static let arrowHeadSizeReductionFactor: Double = 1.5
    }

    // MARK: Properties

    private(set) lazy var turnCommandArrowShaftPartOneLayer: MGLLineStyleLayer = RouteTurnCommandArrowLayer(
        identifier: Constants.arrowShaftPartOneLayerIdentifier, source: turnCommandArrowShaftPartOneSource
    )

    private(set) lazy var turnCommandArrowShaftPartTwoLayer: MGLLineStyleLayer = RouteTurnCommandArrowLayer(
        identifier: Constants.arrowShaftPartTwoLayerIdentifier, source: turnCommandArrowShaftPartTwoSource
    )

    private(set) lazy var turnCommandArrowShaftPartOneOutlineLayer: MGLLineStyleLayer =
        RouteTurnCommandArrowOutlineLayer(
            identifier: Constants.arrowShaftOutlineLayerPartOneIdentifier, source: turnCommandArrowShaftPartOneSource
        )

    private(set) lazy var turnCommandArrowShaftPartTwoOutlineLayer: MGLLineStyleLayer =
        RouteTurnCommandArrowOutlineLayer(
            identifier: Constants.arrowShaftOutlineLayerPartTwoIdentifier, source: turnCommandArrowShaftPartTwoSource
        )

    private(set) lazy var turnCommandArrowHeadLayer: MGLSymbolStyleLayer = {
        let layer = self.createArrowHeadLayer(
            layerId: Constants.arrowHeadLayerIdentifier,
            source: self.turnCommandArrowHeadSource
        )
        return layer
    }()

    private let navigationSdk: NavigationSdk

    private lazy var turnCommandArrowShaftPartOneSource = MGLShapeSource(
        identifier: Constants.arrowShaftSourcePartOneIdentifier,
        shapes: []
    )

    private lazy var turnCommandArrowShaftPartTwoSource = MGLShapeSource(
        identifier: Constants.arrowShaftSourcePartTwoIdentifier,
        shapes: []
    )

    private lazy var turnCommandArrowHeadSource = MGLShapeSource(
        identifier: Constants.arrowHeadSourceIdentifier,
        shapes: []
    )

    private var coordinates: [LatLng] {
        didSet {
            guard oldValue != coordinates else {
                return
            }
            updateArrowShaft(with: coordinates)
            updateArrowHead(with: coordinates)
        }
    }

    // MARK: Lifecycle

    override func setup() {
        super.setup()

        mapLayerManager?.add(shapeSource: turnCommandArrowShaftPartOneSource)
        mapLayerManager?.add(shapeSource: turnCommandArrowShaftPartTwoSource)
        mapLayerManager?.add(shapeSource: turnCommandArrowHeadSource)

        mapLayerManager?.add(
            image: .Map.maneuverArrowHead,
            for: Constants.arrowHeadIconIdentifier
        )

        try? mapLayerManager?.addRouteLineLayer(
            layer: turnCommandArrowShaftPartOneLayer
        )
        try? mapLayerManager?.add(
            layer: turnCommandArrowShaftPartTwoLayer,
            aboveLayerWith: turnCommandArrowShaftPartOneLayer.identifier
        )
        try? mapLayerManager?.add(
            layer: turnCommandArrowShaftPartOneOutlineLayer,
            belowLayerWith: turnCommandArrowShaftPartOneLayer.identifier
        )
        try? mapLayerManager?.add(
            layer: turnCommandArrowShaftPartTwoOutlineLayer,
            belowLayerWith: turnCommandArrowShaftPartOneLayer.identifier
        )
        try? mapLayerManager?.add(
            layer: turnCommandArrowHeadLayer,
            belowLayerWith: turnCommandArrowShaftPartTwoLayer.identifier
        )
    }

    override func startLayerUpdates() {
        super.startLayerUpdates()
        navigationSdk.addOnNavigationStateUpdatedListener(onNavigationStateUpdatedListener: self)
    }

    override func stopLayerUpdates() {
        super.stopLayerUpdates()
        navigationSdk.removeOnNavigationStateUpdatedListener(onNavigationStateUpdatedListener: self)
    }

    init(
        mapTheme: MapTheme,
        mapLayerManager: MapboxMapLayerManager?,
        navigationSdk: NavigationSdk
    ) {
        self.navigationSdk = navigationSdk
        self.coordinates = []
        super.init(mapLayerManager: mapLayerManager, mapTheme: mapTheme)
    }

    // MARK: Overridden Functions

    override func refreshLayerVisibility(isVisible: Bool) {
        if isVisible {
            mapLayerManager?.showLayer(with: turnCommandArrowShaftPartOneLayer.identifier)
            mapLayerManager?.showLayer(with: turnCommandArrowShaftPartTwoLayer.identifier)
            mapLayerManager?.showLayer(with: turnCommandArrowShaftPartOneOutlineLayer.identifier)
            mapLayerManager?.showLayer(with: turnCommandArrowShaftPartTwoOutlineLayer.identifier)
            mapLayerManager?.showLayer(with: turnCommandArrowHeadLayer.identifier)
        } else {
            mapLayerManager?.hideLayer(with: turnCommandArrowShaftPartOneLayer.identifier)
            mapLayerManager?.hideLayer(with: turnCommandArrowShaftPartTwoLayer.identifier)
            mapLayerManager?.hideLayer(with: turnCommandArrowShaftPartOneOutlineLayer.identifier)
            mapLayerManager?.hideLayer(with: turnCommandArrowShaftPartTwoOutlineLayer.identifier)
            mapLayerManager?.hideLayer(with: turnCommandArrowHeadLayer.identifier)
        }
    }

    // MARK: Functions

    private func clearSources() {
        try? mapLayerManager?.clear(source: turnCommandArrowShaftPartOneSource)
        try? mapLayerManager?.clear(source: turnCommandArrowShaftPartTwoSource)
        try? mapLayerManager?.clear(source: turnCommandArrowHeadSource)
    }

    private func onNavigationStateUpdate() {
        guard navigationSdk.navigationActive,
              let routeProgress = navigationSdk.navigationState?.routeProgress,
              routeProgress.nextManeuver.turnInfo.turnCommand != .destination,
              navigationSdk.navigationState?.displayInformation.shouldShowUserOffRoute != true
        else {
            clearSources()
            return
        }
        updateLayerCoordinates(from: routeProgress)
    }

    private func updateArrowShaft(with coordinates: [LatLng]) {
        guard coordinates.count > 1 else {
            clearSources()
            return
        }

        let midIndex = (coordinates.count - 1) / 2
        let firstHalf = Array(coordinates[...midIndex])
        let secondHalf = Array(coordinates[midIndex...])

        guard let firstHalfFeature = createArrowShaftFeature(from: firstHalf),
              let secondHalfFeature = createArrowShaftFeature(from: secondHalf) else {
            return
        }

        updateArrowShaftPartOneSource(with: firstHalfFeature)
        updateArrowShaftPartTwoSource(with: secondHalfFeature)
    }

    private func getRotation(from coordinates: [LatLng]) -> Double {
        let tempCoordinates = coordinates
        guard !tempCoordinates.isEmpty, let last = tempCoordinates.last,
              let secondToLast = tempCoordinates.dropLast().last
        else {
            return 0.0
        }
        return Geodesy.shared.getHeading(
            start: secondToLast,
            end: last
        )
    }

    private func updateArrowHead(with coordinates: [LatLng]) {
        guard let arrowHeadFeature = createArrowHeadFeature(from: coordinates) else {
            return
        }
        updateArrowHeadSource(with: arrowHeadFeature)
    }

    private func createArrowShaftFeature(from coordinates: [LatLng]) -> MGLPolylineFeature? {
        return MGLPolylineFeature(
            coordinates: coordinates.map {
                CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude)
            },
            count: UInt(coordinates.count)
        )
    }

    private func createArrowHeadFeature(from coordinates: [LatLng]) -> MGLPointFeature? {
        guard let lastArrowShaftCoordinate = coordinates.last else {
            return nil
        }
        let feature = MGLPointFeature()
        feature.coordinate = CLLocationCoordinate2D(
            latitude: lastArrowShaftCoordinate.latitude,
            longitude: lastArrowShaftCoordinate.longitude
        )
        feature.attributes = [
            Constants.arrowHeadRotationKey: getRotation(from: coordinates)
        ]
        return feature
    }

    private func updateLayerCoordinates(
        from routeProgress: RouteProgressTrackerRouteProgress
    ) {
        coordinates = getArrowCoordinates(from: routeProgress)
    }

    private func getArrowCoordinates(
        from routeProgress: RouteProgressTrackerRouteProgress
    ) -> [LatLng] {
        var coordinates = [LatLng]()
        let waypointsBeforeManeuver =
            routeProgress.route.waypoints[0 ... Int(routeProgress.nextManeuver.startIndex)]
        let waypointsAfterManeuver =
            routeProgress.route.waypoints[
                Int(routeProgress.nextManeuver.startIndex) ... (routeProgress.route.waypoints.count - 1)
            ]
        let trimmedWaypointsBeforeManeuver = trim(
            waypoints: waypointsBeforeManeuver.map { $0.latLng }.reversed(),
            distance: Constants.defaultHalfArrowLength
        )
        coordinates.append(contentsOf: trimmedWaypointsBeforeManeuver.reversed())
        let trimmedWaypointsAfterManeuver = trim(
            waypoints: waypointsAfterManeuver.map { $0.latLng },
            distance: arrowLengthAfterManeuver(for: routeProgress)
        )
        coordinates.append(contentsOf: trimmedWaypointsAfterManeuver)
        return coordinates
    }

    private func arrowLengthAfterManeuver(for routeProgress: RouteProgressTrackerRouteProgress) -> Length {
        return .companion.fromMeters(
            meters: getManeuverArrowLength(for: routeProgress.nextManeuver)
                .inMeters() + Constants.defaultHalfArrowLength.inMeters()
        )
    }

    private func getManeuverArrowLength(
        for maneuver: Maneuver
    ) -> Length {
        return navigationSdk.routeProgressTracker.getDistanceFromWaypointToWaypoint(
            startIndex: maneuver.startIndex,
            endIndex: maneuver.endIndex
        ) ?? Length.companion.ZERO
    }

    private func trim(waypoints: [LatLng], distance: Length) -> [LatLng] {
        guard let firstWaypoint = waypoints.first else {
            return []
        }
        var result = [firstWaypoint]
        var traveledDistance = Length.companion.ZERO
        for index in 1 ..< waypoints.count {
            let nextWaypoint = waypoints[index]
            guard let lastAddedWaypoint = result.last else {
                return []
            }
            let segmentLength = Geodesy.shared.pointToPointDistance(start: lastAddedWaypoint, end: nextWaypoint)
            if traveledDistance.inMeters() + segmentLength.inMeters() > distance.inMeters() {
                let shiftedLatLng = Geodesy.shared.shiftByPolarInDegrees(
                    position: lastAddedWaypoint,
                    meters: Length.companion.fromMeters(meters: abs(traveledDistance.minus(other: distance).inMeters())),
                    heading: Geodesy.shared.getHeading(start: lastAddedWaypoint, end: nextWaypoint)
                )
                result.append(shiftedLatLng)
                return result
            } else if traveledDistance.inMeters() + segmentLength.inMeters() == distance.inMeters() {
                result.append(nextWaypoint)
                return result
            } else {
                result.append(nextWaypoint)
            }

            traveledDistance = traveledDistance.plus(other: segmentLength)
        }
        return result
    }

    // MARK: Layer and Sources

    private func createArrowHeadLayer(layerId: String, source: MGLSource) -> MGLSymbolStyleLayer {
        let layer = MGLSymbolStyleLayer(identifier: layerId, source: source)
        layer.iconRotationAlignment = NSExpression(forConstantValue: "map")
        layer.iconRotation = NSExpression(forKeyPath: Constants.arrowHeadRotationKey)
        layer.iconAllowsOverlap = NSExpression(forConstantValue: true)
        layer.iconAnchor = NSExpression(forConstantValue: "bottom")
        layer.iconImageName = NSExpression(forConstantValue: Constants.arrowHeadIconIdentifier)
        layer.iconScale = NSExpression(
            forMGLInterpolating: .zoomLevelVariable,
            curveType: .linear,
            parameters: nil,
            stops: NSExpression(
                forConstantValue: [
                    1: 0.1 * Constants.arrowHeadSizeReductionFactor,
                    16: 0.5 * Constants.arrowHeadSizeReductionFactor,
                    20: 1 * Constants.arrowHeadSizeReductionFactor
                ]
            )
        )
        layer.iconIgnoresPlacement = NSExpression(forConstantValue: true)
        return layer
    }

    private func updateArrowShaftPartOneSource(with feature: MGLPolylineFeature) {
        DispatchQueue.main.async {
            try? self.mapLayerManager?.set(shape: feature, on: self.turnCommandArrowShaftPartOneSource)
        }
    }

    private func updateArrowShaftPartTwoSource(with feature: MGLPolylineFeature) {
        DispatchQueue.main.async {
            try? self.mapLayerManager?.set(shape: feature, on: self.turnCommandArrowShaftPartTwoSource)
        }
    }

    private func updateArrowHeadSource(with feature: MGLPointFeature) {
        DispatchQueue.main.async {
            try? self.mapLayerManager?.set(shape: feature, on: self.turnCommandArrowHeadSource)
        }
    }
}

extension RouteTurnCommandArrowsLayerHandler: OnNavigationStateUpdatedListener {
    func onNavigationStateUpdated(navigationState _: NavigationState?) {
        DispatchQueue.main.async { self.onNavigationStateUpdate() }
    }
}
