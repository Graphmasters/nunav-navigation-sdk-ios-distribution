import GMCoreUtility
import GMMapUtility
import Mapbox
import NunavSDKMultiplatform

open class RouteLineLayerHandler: MGLStyleLayersHandler {
    // MARK: Nested Types

    private enum Constants {
        static let firstPartRouteLayerIdentifier = "FIRST_PART_ROUTE_LAYER_IDENTIFIER"
        static let firstPartRouteOutlineLayerIdentifier = "FIRST_PART_ROUTE_OUTLINE_LAYER_IDENTIFIER"
        static let firstPartRouteSourceIdentifier = "FIRST_PART_ROUTE_SOURCE_IDENTIFIER"

        static let secondPartRouteLayerIdentifier = "SECOND_PART_ROUTE_LAYER_IDENTIFIER"
        static let secondPartRouteOutlineLayerIdentifier = "SECOND_PART_ROUTE_OUTLINE_LAYER_IDENTIFIER"
        static let secondPartRouteSourceIdentifier = "SECOND_PART_ROUTE_SOURCE_IDENTIFIER"
    }

    // MARK: Properties

    public private(set) lazy var firstPartRouteLayer: MGLLineStyleLayer = RouteLineLayer(
        identifier: identifierPrefix + Constants.firstPartRouteLayerIdentifier, source: firstPartRouteSource
    )

    public private(set) lazy var firstPartRouteOutlineLayer: MGLLineStyleLayer = RouteOutlineLayer(
        identifier: identifierPrefix + Constants.firstPartRouteOutlineLayerIdentifier, source: firstPartRouteSource
    )

    public private(set) lazy var secondPartRouteLayer: MGLLineStyleLayer = RouteLineLayer(
        identifier: identifierPrefix + Constants.secondPartRouteLayerIdentifier,
        source: secondPartRouteSource
    )

    public private(set) lazy var secondPartRouteOutlineLayer: MGLLineStyleLayer = RouteOutlineLayer(
        identifier: identifierPrefix + Constants.secondPartRouteOutlineLayerIdentifier,
        source: secondPartRouteSource
    )

    private let identifierPrefix: String

    private let featureCreator: RouteFeatureCreator

    private var featureCreationQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.qualityOfService = .utility
        queue.maxConcurrentOperationCount = 1
        queue.name = "Route feature creation"
        return queue
    }()

    private var drawQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.qualityOfService = .userInitiated
        queue.underlyingQueue = .main
        queue.maxConcurrentOperationCount = 2
        queue.name = "Route drawing"
        return queue
    }()

    private lazy var firstPartRouteSource: MGLShapeSource = .init(
        identifier: identifierPrefix + Constants.firstPartRouteSourceIdentifier,
        shapes: [],
        options: [
            MGLShapeSourceOption.simplificationTolerance: MGLShapeSourceOption.routeSimplificationToleranceValue
        ]
    )

    private lazy var secondPartRouteSource = MGLShapeSource(
        identifier: identifierPrefix + Constants.secondPartRouteSourceIdentifier,
        shapes: [],
        options: [
            MGLShapeSourceOption.simplificationTolerance: MGLShapeSourceOption.routeSimplificationToleranceValue
        ]
    )

    // MARK: Computed Properties

    public var waypoints: [Route.Waypoint] = [] {
        didSet {
            guard waypoints.count > 1 else {
                return clearLayer()
            }
            refreshLayer(with: waypoints)
        }
    }

    // MARK: Lifecycle

    public init(
        mapLayerManager: MapboxMapLayerManager?,
        mapTheme: MapTheme,
        featureCreator: RouteFeatureCreator,
        identifierPrefix: String
    ) {
        self.featureCreator = featureCreator
        self.identifierPrefix = identifierPrefix

        super.init(mapLayerManager: mapLayerManager, mapTheme: mapTheme)
    }

    override public func setup() {
        mapLayerManager?.add(shapeSource: firstPartRouteSource, useFeatureCache: true)
        mapLayerManager?.add(shapeSource: secondPartRouteSource, useFeatureCache: true)

        try? mapLayerManager?.addRouteLineLayer(layer: secondPartRouteOutlineLayer)
        try? mapLayerManager?.addRouteLineLayer(layer: firstPartRouteOutlineLayer)
        try? mapLayerManager?.addRouteLineLayer(layer: secondPartRouteLayer)
        try? mapLayerManager?.addRouteLineLayer(layer: firstPartRouteLayer)
    }

    // MARK: Overridden Functions

    override public func updateVisibility(_ visible: Bool) {
        if visible {
            mapLayerManager?.showLayer(with: firstPartRouteLayer.identifier)
            mapLayerManager?.showLayer(with: firstPartRouteOutlineLayer.identifier)
            mapLayerManager?.showLayer(with: secondPartRouteLayer.identifier)
            mapLayerManager?.showLayer(with: secondPartRouteOutlineLayer.identifier)
        } else {
            mapLayerManager?.hideLayer(with: firstPartRouteLayer.identifier)
            mapLayerManager?.hideLayer(with: firstPartRouteOutlineLayer.identifier)
            mapLayerManager?.hideLayer(with: secondPartRouteLayer.identifier)
            mapLayerManager?.hideLayer(with: secondPartRouteOutlineLayer.identifier)
        }
    }

    // MARK: Functions

    public func refreshLayer(with fullRoute: [Route.Waypoint], forced: Bool = false) {
        if forced {
            cancelRemainingWork()
        }

        let operation = BlockOperation(block: { [weak self] in
            guard let self = self else {
                return
            }
            let firstTurnCommandIndex = fullRoute.firstIndex(where: { $0.isTurnCommand() }) ?? fullRoute.endIndex
            let position = fullRoute.distance(from: fullRoute.startIndex, to: firstTurnCommandIndex)
            let parts = RouteUtils().splitAtIndex(waypoints: fullRoute, indexInclusive: Int32(position))
                .filter { $0.count > 1 }

            guard let firstPart = parts.first, let secondPart = parts.last else {
                return
            }

            self.set(waypoints: firstPart, source: self.firstPartRouteSource, forced: forced)

            self.set(waypoints: secondPart, source: self.secondPartRouteSource, forced: forced)
        })
        featureCreationQueue.addOperation(operation)
    }

    private func clearLayer() {
        cancelRemainingWork()
        clearSources()
    }

    private func cancelRemainingWork() {
        featureCreationQueue.cancelAllOperations()
        drawQueue.cancelAllOperations()
    }

    private func clearSources() {
        drawQueue.addOperation {
            try? self.mapLayerManager?.clear(source: self.firstPartRouteSource)
            try? self.mapLayerManager?.clear(source: self.secondPartRouteSource)
        }
    }

    private func set(waypoints: [Route.Waypoint], source: MGLShapeSource, forced: Bool) {
        let shapes: MGLShapeCollectionFeature = shape(from: waypoints)

        guard forced || shapeChanged(newShapes: shapes, currentShapes: source.shape as? MGLShapeCollectionFeature) else {
            return
        }

        drawQueue.addOperation { [weak self] in
            guard let self = self else {
                return
            }
            try? self.mapLayerManager?.set(shape: shapes, on: source)
        }
    }

    private func shapeChanged(newShapes: MGLShapeCollectionFeature, currentShapes: MGLShapeCollectionFeature?) -> Bool {
        guard let currentShapes = currentShapes else {
            return true
        }
        guard newShapes.attributes["HASH"] as? String == currentShapes.attributes["HASH"] as? String else {
            return true
        }
        return newShapes.shapes.first?.attributes.compactMap { $0.value as? String }
            != currentShapes.shapes.first?.attributes.compactMap { $0.value as? String }
    }

    private func shape(from waypoints: [Route.Waypoint]) -> MGLShapeCollectionFeature {
        let feature = Array(getFeatures(from: waypoints.reversed())).mglFeature
        feature.attributes["HASH"] = "\(waypoints.hashValue)"
        return feature
    }

    private func getFeatures(from waypoints: [Route.Waypoint]) -> [RouteFeatureCreatorRouteFeature] {
        do {
            return try featureCreator.createFeatures(waypoints: waypoints)
        } catch {
            GMAnalytics().postEvent(
                tag: "[Error] RouteLayerHandler",
                message: "Can not create features",
                properties: [
                    "Underlying error": String(describing: error)
                ]
            )
            return []
        }
    }
}
