import Foundation
import GMCoreUtility
import GMMapUtility
import Mapbox
import MultiplatformNavigation
import SwiftUI
import UIKit

struct MapView: UIViewControllerRepresentable {
    let onUserInteracted: (NavigationScreen.Interactions) -> Void
    let mapLocationProvider: LocationProvider
    let navigationSdk: NavigationSdk

    @Binding var navigationState: NavigationScreen.UIState

    func makeUIViewController(context _: Context) -> NavigationMapViewController {
        return NavigationMapViewController(
            navigationUIState: navigationState,
            mapLocationProvider: mapLocationProvider,
            navigationSdk: navigationSdk,
            onUserInteracted: onUserInteracted
        )
    }

    func updateUIViewController(_ uiViewController: NavigationMapViewController, context _: Context) {
        uiViewController.navigationUIState = navigationState
    }
}
