import GMCoreUtility
import GMMapUtility
import Mapbox
import NunavSDKMultiplatform

public final class ManeuverLayerHandler: MGLStyleLayersHandler {
    // MARK: Nested Types

    private enum Constants {
        static let layerIdentifier: String = "MANEUVER_LAYER_IDENTIFIER"
        static let sourceIdentifier: String = "MANEUVER_SOURCE_IDENTIFIER"
        static let labelPostFix: String = "_LABELED"

        static let anchorKey = "ICON_ANCHOR"
        static let imageKeyLabeled = "IMAGE_KEY_LABELED"
    }

    private struct Turn {
        let latLng: LatLng
        let turnInfo: TurnInfo
        let icon: ManeuverMapIconCreator.ManeuverMapIcon
        let iconLabeled: ManeuverMapIconCreator.ManeuverMapIcon
    }

    // MARK: Properties

    private let maneuverMapIconCreator: ManeuverMapIconCreator

    private lazy var source: MGLShapeSource = .init(identifier: Constants.sourceIdentifier, shapes: [], options: nil)

    private lazy var layer: MGLStyleLayer = {
        let labeledLayer = MGLSymbolStyleLayer(identifier: Constants.layerIdentifier, source: self.source)
        labeledLayer.minimumZoomLevel = 5
        labeledLayer.iconImageName = NSExpression(forKeyPath: Constants.imageKeyLabeled)
        labeledLayer.iconAnchor = NSExpression(forKeyPath: Constants.anchorKey)
        labeledLayer.iconScale = NSExpression(forMGLInterpolating: NSExpression.zoomLevelVariable,
                                              curveType: MGLExpressionInterpolationMode.linear,
                                              parameters: nil,
                                              stops: NSExpression(forConstantValue: [
                                                  5: 0.6,
                                                  16: 1
                                              ]))
        labeledLayer.iconAllowsOverlap = NSExpression(forConstantValue: true)
        labeledLayer.textAllowsOverlap = NSExpression(forConstantValue: true)
        labeledLayer.iconIgnoresPlacement = NSExpression(forConstantValue: true)
        labeledLayer.iconOpacity = NSExpression(
            forMGLInterpolating: NSExpression.zoomLevelVariable,
            curveType: .linear,
            parameters: nil,
            stops: NSExpression(forConstantValue: [
                labeledLayer.minimumZoomLevel: 0.0,
                labeledLayer.minimumZoomLevel + 0.25: 1.0
            ])
        )
        return labeledLayer
    }()

    // MARK: Computed Properties

    public var maneuvers: [Maneuver] = [] {
        didSet {
            guard oldValue != maneuvers else {
                return
            }
            turns = maneuvers.compactMap { maneuver in
                guard let maneuverMapIconLabeled = maneuverMapIconCreator.create(
                    turnInfo: maneuver.turnInfo, showDirectionLabel: true
                ),
                    let maneuverMapIcon = maneuverMapIconCreator.create(
                        turnInfo: maneuver.turnInfo, showDirectionLabel: false
                    ) else {
                    return nil
                }
                return Turn(
                    latLng: maneuver.latLng,
                    turnInfo: maneuver.turnInfo,
                    icon: maneuverMapIcon,
                    iconLabeled: maneuverMapIconLabeled
                )
            }
        }
    }

    private var turns: [Turn] = [] {
        didSet {
            removeImages(of: oldValue)
            addImages(for: turns)
            refreshSource(with: turns)
        }
    }

    // MARK: Lifecycle

    public init(
        mapLayerManager: MapboxMapLayerManager?,
        mapTheme: MapTheme,
        maneuverMapIconCreator: ManeuverMapIconCreator
    ) {
        self.maneuverMapIconCreator = maneuverMapIconCreator
        super.init(mapLayerManager: mapLayerManager, mapTheme: mapTheme)
    }

    override public func setup() {
        mapLayerManager?.add(shapeSource: source, useFeatureCache: true)
        try? mapLayerManager?.addRouteSymbolLayer(layer: layer)
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

    private func removeImages(of turns: [Turn]) {
        for turn in turns.map(\.turnInfo) {
            mapLayerManager?.remove(imageWithKey: imageKey(for: turn) + Constants.labelPostFix)
        }
    }

    private func addImages(for turns: [Turn]) {
        for turn in turns {
            mapLayerManager?.add(image: turn.iconLabeled.image, for: imageKey(for: turn.turnInfo) + Constants.labelPostFix)
        }
    }

    private func refreshSource(with turns: [Turn]) {
        try? mapLayerManager?.set(
            shape: MGLShapeCollectionFeature(shapes: turns.map(point)),
            on: source
        )
    }

    private func imageKey(for turnInfo: TurnInfo) -> String {
        turnInfo.turnCommand.name +
            turnInfo.directionNames.joined(separator: "_") +
            turnInfo.directionReferenceNames.joined(separator: "_") +
            (turnInfo.leadsToStreetName ?? "")
    }

    private func point(for turn: Turn) -> MGLPointFeature {
        let point = MGLPointFeature()
        point.identifier = UUID().uuidString
        point.coordinate = turn.latLng.clLocationCoordinate2D
        point.attributes[Constants.anchorKey] = turn.icon.anchor
        point.attributes[Constants.imageKeyLabeled] = imageKey(for: turn.turnInfo) + Constants.labelPostFix
        return point
    }
}
