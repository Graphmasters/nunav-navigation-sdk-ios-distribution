import Foundation
import GMMapUtility
import Mapbox
import NunavSDKMultiplatform
import UIKit

final class TripMapLayer: DefaultIconLayer {
    init(identifier: String, source: MGLSource, mapTheme: MapTheme) {
        super.init(identifier: identifier, source: source, minimumZoomLevel: .zero)

        iconAllowsOverlap = NSExpression(forConstantValue: true)
        textAllowsOverlap = NSExpression(forConstantValue: true)

        let lightColor = UIColor.white
        let darkColor = UIColor(red: 21.0 / 256.0, green: 36.0 / 256.0, blue: 48.0 / 256.0, alpha: 0.8)

        textColor = NSExpression(forConstantValue: mapTheme == .light ? darkColor : lightColor)
        textHaloWidth = NSExpression(forConstantValue: 1.2)
        textHaloColor = NSExpression(forConstantValue: mapTheme == .light ? lightColor : darkColor)
        textFontSize = NSExpression(
            forMGLInterpolating: .zoomLevelVariable,
            curveType: .linear,
            parameters: nil,
            stops: NSExpression(forConstantValue: [
                1: 1.2,
                4: 6,
                16: 14
            ])
        )
        textAnchor = NSExpression(forConstantValue: MGLTextAnchor.top.rawValue)
        textPadding = NSExpression(forConstantValue: 10)
    }
}
