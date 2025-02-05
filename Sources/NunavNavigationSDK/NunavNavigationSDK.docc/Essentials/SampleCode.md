# NUNAV: Integrating the Navigation SDK into an App

@Metadata {
    @CallToAction(
        url: "https://github.com/Graphmasters/nunav-navigation-sdk-example/tree/main/iOS",
        label: "GitHub"
    )
    
    @PageKind(sampleCode)
    @PageColor(blue)
    @PageImage(
        purpose: card, 
        source: "slothy-card"
    )
    
    Check out the example code to see how the simple integration works for your app.
}

## Overview

This sample creates an app where you can choose between different destinations. For all destinations a navigation is opened using the NUNAV Navigation SDK

@Video(poster: "slothy-hero-poster", source: "slothy-hero")

@Row {
    @Column(size: 2) {
        First, you customize your navigation by picking a destination. Optionally you can
        change the ``TransportMode`` for the navigation. It defaults to ``TransportMode/car``. The other attributes of ``RoutingConfiguration`` further customize the navigation.
    }
    
    @Column {
        ![A screenshot of the power picker user interface with four powers displayed – ice, fire, wind, and lightning](slothy-powerPicker)
    }
}



@Row {
    @Column {
        ![A screenshot of the sloth status user interface that indicates the the amount of sleep, fun, and exercise a given sloth is in need of.](slothy-status)
    }
    
    @Column(size: 2) {
        Once you have started the navigation to your destination, the app will show you a full
        navigation experience. This includes a map with the route, information about the next maneuver
        and information for your remaining route like the remaining time and distance.
    }
}

### Localization

The NUNAV Navigation SDK is currently localized in English and German. It automatically takes the device's current locale into account. If you need any more languages please [contact us](https://nunav.net/lp/sdk).

@TabNavigator {
    @Tab("English") {
        ![Two screenshots showing the Slothy app rendering with English language content. The first screenshot shows a sloth map and the second screenshot shows a sloth power picker.](slothy-localization_eng)
    }
    
    @Tab("German") {
        ![Two screenshots showing the Slothy app rendering with Chinese language content. The first screenshot shows a sloth map and the second screenshot shows a sloth power picker.](slothy-localization_zh)
    }
}
