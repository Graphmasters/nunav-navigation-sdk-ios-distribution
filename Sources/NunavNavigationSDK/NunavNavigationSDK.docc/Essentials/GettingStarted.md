# Getting Started

@Metadata {
    @CallToAction(
        purpose: link, 
        url: "https://nunav.net/lp/sdk",
        label: "Request API Key"
    )
    
    @PageImage(
        purpose: card, 
        source: "slothy-card"
   )
}

Get a full overview of the NUNAV Navigation SDK for iOS and guide your users to their destinations.

To start navigations using the SDK you need an API key for accessing the NUNAV Technology provided by Graphmasters GmbH. For trial use this is free of charge. Further you have to add the SDK as a dependency to your project.

## 1. Request an API Key

To request an API key, visit the [official product page](https://nunav.net/lp/sdk/) of the NUNAV Navigation SDK.

## 2. Add the Dependency

The NUNAV Navigation SDK for iOS is distributed using the Swift Package Manager. To add it to your project,
follow the steps below.

### 2.1 Add the following one to your dependencies.

```
dependencies: [
    .package(url: "https://github.com/graphmasters/nunav-navigation-sdk-ios-distribution", from: "<VERSION>")
]
```

### 2.2 Add the dependency to your target.

```
.target(
    name: "MyTarget",
    dependencies: [
        .product(name: "NunavNavigationSDK", package: "nunav-navigation-sdk-ios-distribution")
    ]
)
```

## 3. Configure the NUNAV Navigation SDK

Configure the SDK with your API key. This is required for all further SDK interactions. Otherwise your app will finish with a fatal error.

```
NunavNavigationSDK.configure(apiKey: "<API_KEY>")
```

Optionally you can configure the NUNAV Navigation SDK with a custom service URL. This is only needed if you are using a custom NUNAV routing. To learn more about custom NUNAV routing please contact Graphmasters.

```
NunavNavigationSDK.configure(apiKey: "<API_KEY>", serviceURL: "<SERVICE_URL>")
```

## 4. Add Location Permission

Add `NSLocationWhenInUseUsageDescription` key to `Info.plist` and provide a proper usage description. For more information refer to [Apple Developer Documenation](https://developer.apple.com/documentation/bundleresources/information_property_list/nslocationwheninuseusagedescription/).

## 5. Add Background Modes

Add background modes ([`UIBackgroundModes`](https://developer.apple.com/documentation/bundleresources/information_property_list/uibackgroundmodes/)) to `info.plist` for enabling the navigation to run while your app is in background.

```
<array>
    <string>audio</string>
    <string>fetch</string>
    <string>location</string>
</array>
```

## 6. Open the Navigation UI

@TabNavigator {
    @Tab("UIKit") {
        @Row {
            @Column {
                ### Instantiate a UIKit ViewController
                
                To open the NUNAV Navigation UI, instantiate a ViewController using NunavNavigationUI with your custom DestinationConfiguration and RoutingConfiguration. Learn more about configuring your navigation session in the [Configuration Guide](<doc:ConfigurationGuide>).
                
                The simplest way to open the Navigation UI is to just hand the destination coordinate:
                
                ```
                let navigationViewController = NunavNavigationUI.makeNavigationViewController(
                    destinationConfiguration: DestinationConfiguration(
                        coordinate: CLLocationCoordinate2D(latitude: 53.551086, longitude: 9.993682)
                    ),
                )
                
                self.present(navigationViewController)
                ```
            }
        }
    }
    @Tab("SwiftUI") {
        @Row {
            @Column {
                ### Instantiate a SwiftUI View
                
                To open the NUNAV Navigation UI, instantiate a View using NunavNavigationUI with your custom DestinationConfiguration and RoutingConfiguration. Learn more about configuring your navigation session in the [Configuration Guide](<doc:ConfigurationGuide>).
                
                The simplest way to open the Navigation UI is to just hand the destination coordinate:
                
                ```
                var body: some View {
                    NavigationLink {
                        NunavNavigationUI.makeNavigationView(
                            destinationConfiguration: DestinationConfiguration(
                                coordinate: CLLocationCoordinate2D(latitude: 53.551086, longitude: 9.993682)
                            ),
                        )
                    } label: {
                        Label("Start Navigation", systemImage: "location.fill")
                    }
                }
                ```
            }
        }
    }
}
