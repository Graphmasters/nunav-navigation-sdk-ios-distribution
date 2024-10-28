import Foundation
import GMCoreUtility
import GMMapUtility
import Mapbox
import NunavSDKMultiplatform
import UIKit

class NavigationMapViewController: UIViewController {
    // MARK: Properties

    public lazy var mapView: MGLMapView = {
        let view = MGLMapView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self.mapLayersLifecycleHandler
        return view
    }()

    private lazy var mapLayersLifecycleHandler = MGLMapViewLifeCycleHandler(
        mapThemeRepository: mapThemeRepository,
        mapStyleUrlProvider: mapStyleUrlProvider,
        mapStyleLocalizer: mapStyleLocalizer,
        mapLayerHandlerBuilder: mapLayersControllerBuilder
    )

    private lazy var mapThemeRepository = SimpleMapThemeRepository()

    private lazy var mapStyleUrlProvider: MGLMapStyleUrlProvider = NunavMGLMapStyleUrlProvider()

    private lazy var mapCameraUpdateHandler: MapCameraUpdateHandler = .init(
        cameraController: cameraController,
        cameraConfigurationProvider: StaticCameraConfigurationProvider()
    )

    private lazy var cameraController = MGLMapViewCameraController(mapView: mapView)

    private lazy var mapStyleLocalizer = NunavStyleLocalizer()

    private lazy var mapLayersControllerBuilder = NunavSDKMapLayersControllerBuilder(
        mapLocationProvider: NavigationUI.mapLocationProvider,
        navigationSdk: NunavSDK.navigationSdk,
        routeDetachStateProvider: NavigationUI.routeDetachStateProvider
    )

    private lazy var cameraComponent = CameraComponent(
        navigationSdk: NunavSDK.navigationSdk,
        mapView: mapView
    )

    // MARK: Lifecycle

    public init() {
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Overridden Functions

    override open func viewDidLoad() {
        super.viewDidLoad()

        configure(mapView)
        mapLayersLifecycleHandler.setup(mapView: mapView)
    }

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        add(mapView)

        NavigationUI.mapLocationProvider.startLocationUpdates()
        cameraComponent.navigationCameraHandler.startCameraTracking()

        mapLayersLifecycleHandler.resumeLayerUpdates()
        cameraComponent.addCameraUpdateListener(cameraUpdateListener: mapCameraUpdateHandler)
    }

    override open func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NavigationUI.mapLocationProvider.stopLocationUpdates()
        cameraComponent.navigationCameraHandler.stopCameraTracking()

        mapLayersLifecycleHandler.pauseLayerUpdates()

        cameraComponent.removeCameraUpdateListener(cameraUpdateListener: mapCameraUpdateHandler)

        mapView.removeFromSuperview()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        mapThemeRepository.mapTheme = traitCollection.userInterfaceStyle == .dark ? .dark : .light
    }

    // MARK: Functions

    open func add(_ mapView: MGLMapView) {
        view.insertSubview(mapView, at: 0)
        NSLayoutConstraint.activate(
            mapView.constraintsForAnchoringTo(boundsOf: view)
        )
    }

    open func configure(_ mapView: MGLMapView) {
        mapView.allowsTilting = true
        mapView.showsUserLocation = false
        mapView.attributionButton.isUserInteractionEnabled = false
        mapView.logoView.isHidden = true
        mapView.attributionButton.isHidden = true
        mapView.compassView.isHidden = true
        mapView.styleURL = mapStyleUrlProvider.mapStyle(forMapTheme: mapThemeRepository.mapTheme)
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
