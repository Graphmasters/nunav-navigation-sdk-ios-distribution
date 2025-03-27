import Combine
import Foundation
import MultiplatformNavigation
import Network
import SwiftUI

extension NavigationScreen {
    class ViewModel: ObservableObject {
        // MARK: Properties

        public var toggleVoiceInstructionComponent: (() -> Void)?

        public var dismissNavigation: (() -> Void)?

        @Published var state: NavigationScreen.UIState

        private let navigationSdk: NavigationSdk
        private let locationProvider: LocationProvider

        // MARK: Computed Properties

        var dialogStateContributionBinding: Binding<Bool> {
            Binding(
                get: {
                    self.state.dialogState == .contribution
                },
                set: { _ in self.dismissDialogs() }
            )
        }

        var dialogStateEndNavigationBinding: Binding<Bool> {
            Binding(
                get: {
                    self.state.dialogState == .endNavigation
                },
                set: { _ in self.dismissDialogs() }
            )
        }

        var dialogStateDestinationReachedBinding: Binding<Bool> {
            Binding(
                get: {
                    guard case .destinationReached = self.state.dialogState else {
                        return false
                    }
                    return true
                },
                set: { _ in self.dismissDialogs() }
            )
        }

        var dialogStateErrorBinding: Binding<Bool> {
            Binding(
                get: {
                    guard case .error = self.state.dialogState else {
                        return false
                    }
                    return true
                },
                set: { _ in self.dismissDialogs() }
            )
        }

        // MARK: Lifecycle

        init(
            navigationSdk: NavigationSdk,
            locationProvider: LocationProvider
        ) {
            self.navigationSdk = navigationSdk
            self.locationProvider = locationProvider
            self.state = NavigationScreen.UIState(
                navigationState: navigationSdk.navigationState,
                interactionMode: .following,
                dialogState: .none,
                voiceInstructionsEnabled: true
            )
        }

        // MARK: Functions

        func onAppear() {
            navigationSdk.addOnDestinationReachedListener(onDestinationReachedListener: self)
            navigationSdk.addOnNavigationStoppedListener(onNavigationStoppedListener: self)
            navigationSdk.addOnRouteRequestFailedListener(onRouteRequestFailedListener: self)
            navigationSdk.addOnNavigationStateUpdatedListener(onNavigationStateUpdatedListener: self)
        }

        func onDisappear() {
            navigationSdk.removeOnDestinationReachedListener(onDestinationReachedListener: self)
            navigationSdk.removeOnNavigationStoppedListener(onNavigationStoppedListener: self)
            navigationSdk.removeOnRouteRequestFailedListener(onRouteRequestFailedListener: self)
            navigationSdk.removeOnNavigationStateUpdatedListener(onNavigationStateUpdatedListener: self)
        }

        func onUserInteracted(interaction: NavigationScreen.Interactions) {
            switch interaction {
            case .mapDidMoved:
                state = state.doCopy(interactionMode: .interacting)
            case .onVoiceInstructionButtonTapped:
                onVoiceInstructionButtonClicked()
            case .onRouteOverviewButtonTapped:
                onRouteOverviewButtonClicked()
            case .onBackToRouteButtonTapped:
                onBackToRouteButtonClicked()
            case .onEndNavigationDialogCloseTapped:
                onEndNavigationDialogCloseTapped()
            case .mapTilerContributionSelected:
                mapTilerMapContributionDidPress()
            case .openStreetMapContributionSelected:
                openStreetMapContributionDidPress()
            case .nunavMapContributionSelected:
                nunavMapContributionDidPress()
            case .onContributionButtonTapped:
                onContributionButtonTapped()
            case .dismissDialogButtonTapped:
                dismissDialogs()
            case .onEndNavigationButtonTapped:
                onEndNavigationButtonTapped()
            }
        }

        func onVoiceInstructionButtonClicked() {
            state = state.doCopy(
                voiceInstructionsEnabled: state.voiceInstructionsEnabled ? false : true
            )
            toggleVoiceInstructionComponent?()
        }

        func onRouteOverviewButtonClicked() {
            state = state.doCopy(interactionMode: .overview)
        }

        func onBackToRouteButtonClicked() {
            state = state.doCopy(interactionMode: .following)
        }

        private func onEndNavigationDialogCloseTapped() {
            navigationSdk.stopNavigation()
        }

        private func dismissDialogs() {
            state = state.doCopy(dialogState: .none)
        }

        private func onContributionButtonTapped() {
            state = state.doCopy(dialogState: .contribution)
        }

        private func nunavMapContributionDidPress() {
            UIApplication.shared.open(
                URL(string: "https://github.com/Graphmasters/nunav-sdk-example")!, options: [:], completionHandler: nil
            )
        }

        private func openStreetMapContributionDidPress() {
            UIApplication.shared.open(
                URL(string: "https://www.openstreetmap.org/copyright")!, options: [:], completionHandler: nil
            )
        }

        private func mapTilerMapContributionDidPress() {
            UIApplication.shared.open(
                URL(string: "https://www.maptiler.com/copyright/")!, options: [:], completionHandler: nil
            )
        }

        private func onEndNavigationButtonTapped() {
            state = state.doCopy(dialogState: .endNavigation)
        }

        private func getNavigationError(_ error: KotlinException) -> NavigationScreen.ErrorType {
            switch error {
            case is UnauthorizedException:
                return .unauthorized
            case is RouteProviderRouteNotFoundException:
                return .routeNotFound
            case is TooManyRequestsException:
                return .tooManyRequests
            case is NoLocationAvailableException:
                return .noLocationAvailable
            // This has to be added in the SDK and on the BFF.
            // case is ServiceTemporarilyUnavailableException:
            //     return .serviceTemporarilyUnavailable
            default:
                return .unknown
            }
        }

        func persistentErrorDialogCloseButtonTapped() {
            navigationSdk.stopNavigation()
        }

        func onStartNavigationFailed(with error: Error) {
            state = state.doCopy(
                dialogState: NavigationScreen.DialogState.error(
                    type: .unknown
                )
            )
        }
    }
}

extension NavigationScreen.ViewModel: NavigationEventHandlerOnNavigationStoppedListener {
    func onNavigationStopped() {
        dismissNavigation?()
    }
}

extension NavigationScreen.ViewModel: NavigationEventHandlerOnDestinationReachedListener {
    func onDestinationReached(navigationResult: NavigationResult) {
        state = state.doCopy(
            dialogState: .destinationReached(label: navigationResult.destination.label)
        )
    }
}

extension NavigationScreen.ViewModel: NavigationEventHandlerOnRouteRequestFailedListener {
    func onRouteRequestFailed(e: KotlinException) {
        guard navigationSdk.navigationState?.route == nil else {
            return
        }
        state = state.doCopy(
            dialogState: NavigationScreen.DialogState.error(
                type: getNavigationError(e)
            )
        )
    }
}

extension NavigationScreen.ViewModel: OnNavigationStateUpdatedListener {
    func onNavigationStateUpdated(navigationState: NavigationState?) {
        state = state.doCopy(navigationState: navigationState)
    }
}
