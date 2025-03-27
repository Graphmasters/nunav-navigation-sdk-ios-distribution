import Foundation
import GMCoreUtility
import GMMapUtility
import Mapbox
import MultiplatformNavigation
import NunavDesignSystem
import UIKit

class NavigationMapViewController: UIViewController {
    // MARK: Properties

    lazy var mapView: MGLMapView = {
        let view = MGLMapView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let onUserInteracted: (NavigationScreen.Interactions) -> Void

    private let mapLocationProvider: LocationProvider

    private let navigationSdk: NavigationSdk

    private var isFirstCameraUpdate: Bool = true

    private lazy var mapLayersLifecycleHandler = MGLMapViewLifeCycleHandler(
        mapThemeRepository: mapThemeRepository,
        mapStyleUrlProvider: mapStyleUrlProvider,
        mapStyleLocalizer: mapStyleLocalizer,
        mapLayerHandlerBuilder: mapLayersControllerBuilder
    )

    private lazy var mapThemeRepository = SimpleMapThemeRepository()

    private lazy var mapStyleUrlProvider: MGLMapStyleUrlProvider = NunavMGLMapStyleUrlProvider()

    private lazy var cameraConfigurationProvider = StaticCameraConfigurationProvider()

    private lazy var cameraController = MGLMapViewCameraController(mapView: mapView)

    private lazy var mapStyleLocalizer = NunavStyleLocalizer()

    private lazy var mapLayersControllerBuilder = NunavSDKMapLayersControllerBuilder(
        mapLocationProvider: mapLocationProvider,
        navigationSdk: navigationSdk
    )

    private lazy var cameraComponent = CameraComponent(
        navigationSdk: navigationSdk,
        mapView: mapView,
        updateRate: BaseCameraComponent.companion.DEFAULT_UPDATE_RATE,
        zoomSteps: GenericNavigationZoomProvider.companion.ZOOM_STEPS
    )

    // MARK: Computed Properties

    public var navigationUIState: NavigationScreen.UIState {
        didSet {
            if oldValue.interactionMode != navigationUIState.interactionMode {
                onInteractionModeChanged()
            }
        }
    }

    // MARK: Lifecycle

    init(
        navigationUIState: NavigationScreen.UIState,
        mapLocationProvider: LocationProvider,
        navigationSdk: NavigationSdk,
        onUserInteracted: @escaping (NavigationScreen.Interactions) -> Void
    ) {
        self.navigationUIState = navigationUIState
        self.mapLocationProvider = mapLocationProvider
        self.navigationSdk = navigationSdk
        self.onUserInteracted = onUserInteracted
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Overridden Functions

    override func viewDidLoad() {
        super.viewDidLoad()

        configure(mapView)
        mapLayersLifecycleHandler.setup(mapView: mapView, delegate: self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isFirstCameraUpdate = true
        add(mapView)
        updateInsets()
        mapLocationProvider.startLocationUpdates()
        cameraComponent.navigationCameraHandler.startCameraTracking()

        mapLayersLifecycleHandler.resumeLayerUpdates()
        cameraComponent.addCameraUpdateListener(cameraUpdateListener: self)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        mapLocationProvider.stopLocationUpdates()
        cameraComponent.navigationCameraHandler.stopCameraTracking()

        mapLayersLifecycleHandler.pauseLayerUpdates()

        cameraComponent.removeCameraUpdateListener(cameraUpdateListener: self)

        mapView.removeFromSuperview()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        mapThemeRepository.mapTheme = traitCollection.userInterfaceStyle == .dark ? .dark : .light
        // updateInsets()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: nil) { _ in
            self.updateInsets()
        }
    }

    // MARK: Functions

    func onInteractionModeChanged() {
        switch navigationUIState.interactionMode {
        case .overview:
            guard let waypoints = navigationUIState.navigationState?.routeProgress?.remainingWaypoints else {
                return
            }
            cameraController.show(
                locations: waypoints.map {
                    CLLocationCoordinate2D(latitude: $0.latLng.latitude, longitude: $0.latLng.longitude)
                },
                animated: true
            )
        case .following:
            guard let cameraUpdate = cameraComponent.cameraUpdate else {
                return
            }
            updateCamera(cameraUpdate: cameraUpdate)
        case .interacting, .loading:
            break
        }
    }

    func add(_ mapView: MGLMapView) {
        view.insertSubview(mapView, at: 0)
        NSLayoutConstraint.activate(
            mapView.constraintsForAnchoringTo(boundsOf: view)
        )
    }

    func configure(_ mapView: MGLMapView) {
        mapView.isUserInteractionEnabled = true
        mapView.allowsScrolling = true
        mapView.allowsZooming = true
        mapView.allowsTilting = true
        mapView.showsUserLocation = false
        mapView.attributionButton.isUserInteractionEnabled = false
        mapView.logoView.isHidden = true
        mapView.attributionButton.isHidden = true
        mapView.compassView.isHidden = true
        mapView.styleURL = mapStyleUrlProvider.mapStyle(forMapTheme: mapThemeRepository.mapTheme)
    }

    func forceNextCameraUpdateInstant() {
        guard let cameraUpdate = cameraComponent.cameraUpdate else {
            return
        }
        let newUpdate = CameraUpdate(
            latLng: cameraUpdate.latLng,
            zoom: cameraUpdate.zoom,
            tilt: cameraUpdate.tilt,
            bearing: cameraUpdate.bearing,
            dismissible: cameraUpdate.dismissible,
            duration: .companion.ZERO,
            padding: cameraUpdate.padding
        )
        updateCamera(cameraUpdate: newUpdate)
    }

    func updateCamera(cameraUpdate: CameraUpdate) {
        guard navigationUIState.interactionMode == .following else {
            return
        }
        cameraController.move(cameraUpdate: cameraUpdate, cameraConfiguration: cameraConfigurationProvider.cameraConfiguration)
    }

    private func updateInsets() {
        MainThread.shared.execute {
            UIView.animate(withDuration: 0.3) {
                self.additionalSafeAreaInsets = UIEdgeInsets(
                    top: Spacing.default.rawValue,
                    left: self.traitCollection.isLandscapeLayout ?
                        (
                            self.view.bounds.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right
                        ) / 2 : Spacing.default.rawValue,
                    bottom: .zero,
                    right: Spacing.default.rawValue
                )
            }
        }
    }
}

extension NavigationMapViewController: NavigationCameraHandlerCameraUpdateListener {
    func onCameraUpdateReady(cameraUpdate: CameraUpdate) {
        if isFirstCameraUpdate {
            let newUpdate = CameraUpdate(
                latLng: cameraUpdate.latLng,
                zoom: cameraUpdate.zoom,
                tilt: cameraUpdate.tilt,
                bearing: cameraUpdate.bearing,
                dismissible: cameraUpdate.dismissible,
                duration: .companion.ZERO,
                padding: cameraUpdate.padding
            )
            updateCamera(cameraUpdate: newUpdate)
            isFirstCameraUpdate = false
        } else {
            updateCamera(cameraUpdate: cameraUpdate)
        }
    }
}

extension NavigationMapViewController: MGLMapViewLifeCycleHandlerDelegate {
    func mapView(
        _: MGLMapView,
        regionIsChangingWith reason: MGLCameraChangeReason,
        handledBy _: MGLMapViewLifeCycleHandler
    ) {
        guard !(
            reason.contains(.programmatic) || reason.contains(.transitionCancelled) || reason.isEmpty
        ) else {
            return
        }
        onUserInteracted(.mapDidMoved)
    }
}

final class SimpleMapThemeRepository: MapThemeRepository {
    // MARK: Properties

    var delegate: MapThemeRepositoryDelegate?

    // MARK: Computed Properties

    var mapTheme: MapTheme = .light {
        didSet {
            guard oldValue != mapTheme else {
                return
            }
            delegate?.mapThemeRepository(self, didChangeMapTheme: mapTheme)
        }
    }
}
