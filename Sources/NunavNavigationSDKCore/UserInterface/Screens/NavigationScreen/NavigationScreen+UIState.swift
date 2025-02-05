import MultiplatformNavigation

extension NavigationScreen {
    struct UIState {
        let navigationState: NavigationState?
        let interactionMode: InteractionMode
        let dialogState: DialogState?
        let voiceInstructionsEnabled: Bool
    }

    enum InteractionMode {
        case following
        case interacting
        case overview
        case loading
    }

    enum DialogState: Equatable {
        case contribution
        case endNavigation
        case destinationReached(label: String)
        case error(type: ErrorType)

        // MARK: Computed Properties

        var errorType: ErrorType? {
            guard case let .error(type) = self else {
                return nil
            }
            return type
        }

        var destinationLabel: String? {
            guard case let .destinationReached(label) = self else {
                return nil
            }
            return label
        }
    }

    enum ErrorType {
        case unauthorized
        case routeNotFound
        case unknown
    }
}

extension NavigationScreen.UIState {
    func doCopy(
        interactionMode: NavigationScreen.InteractionMode? = nil,
        voiceInstructionsEnabled: Bool? = nil
    ) -> NavigationScreen.UIState {
        return NavigationScreen.UIState(
            navigationState: navigationState,
            interactionMode: interactionMode ?? self.interactionMode,
            dialogState: dialogState,
            voiceInstructionsEnabled: voiceInstructionsEnabled ?? self.voiceInstructionsEnabled
        )
    }

    func doCopy(
        dialogState: NavigationScreen.DialogState?
    ) -> NavigationScreen.UIState {
        return NavigationScreen.UIState(
            navigationState: navigationState,
            interactionMode: interactionMode,
            dialogState: dialogState,
            voiceInstructionsEnabled: voiceInstructionsEnabled
        )
    }

    func doCopy(
        navigationState: NavigationState? = nil
    ) -> NavigationScreen.UIState {
        return NavigationScreen.UIState(
            navigationState: navigationState,
            interactionMode: interactionMode,
            dialogState: dialogState,
            voiceInstructionsEnabled: voiceInstructionsEnabled
        )
    }
}
