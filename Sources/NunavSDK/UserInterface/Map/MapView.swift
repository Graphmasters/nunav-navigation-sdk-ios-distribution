import Foundation
import GMCoreUtility
import GMMapUtility
import Mapbox
import NunavSDKMultiplatform
import SwiftUI
import UIKit

struct MapView: UIViewControllerRepresentable {
    func makeUIViewController(context _: Context) -> some UIViewController {
        NavigationMapViewController()
    }

    func updateUIViewController(_: UIViewControllerType, context _: Context) {}
}
