# Integrate the Navigation SDK into your App

@Metadata {
    @PageKind(sampleCode)
    @CallToAction(
        url: "https://github.com/Graphmasters/nunav-navigation-sdk-example/tree/main/iOS",
        label: "GitHub"
    )
    @PageImage(
        purpose: card, 
        source: "nunav-navigation-sdk-sample-code-card"
    )
}

Check out the example code to see how the simple integration works for your app.

## Overview

This sample creates an app where you can choose between different destinations. For all destinations a navigation is opened using the NUNAV Navigation SDK

@Row {
    @Column(size: 2) {
        First, you customize your navigation by picking a destination. Optionally you can
        change the ``TransportMode`` for the navigation. It defaults to ``TransportMode/car``. The other attributes of ``RoutingConfiguration`` further customize the navigation.
    }
    
    @Column {
        ![A screenshot of the NUNAV Navigation SDK example app showing the different configuration options](screen-nunav-navigation-sdk-navigation-example-config)
    }
}



@Row {
    @Column {
        ![A screenshot of the NUNAV Navigation SDK user experience](screen-nunav-navigation-sdk-navigation-landscape-light-2)
    }
    
    @Column {
        Once you have started the navigation to your destination, the app will show you a full
        navigation experience. This includes a map with the route, information about the next maneuver
        and information for your remaining route like the remaining time and distance.
    }
}

### Adaption

The NUNAV Navigation SDK is currently localized in English and German. It automatically takes the device's current locale into account. If you need any more languages please [contact us](https://nunav.net/lp/sdk).

Further the NUNAV Navigation SDK automatically adapts to the system appearance. If the system appearance is set to dark mode, the SDK will also be displayed in dark mode.

@TabNavigator {
    @Tab("Light") {
        ![Two screenshots showing the NUNAV Navigation sdk rendering with light system appearance.](nunav-navigation-sdk-sample-code-comparison-light)
    }
    
    @Tab("Dark") {
        ![Two screenshots showing the NUNAV Navigation sdk rendering with light system appearance.](nunav-navigation-sdk-sample-code-comparison-dark)
    }
}
