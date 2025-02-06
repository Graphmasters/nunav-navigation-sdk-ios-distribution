# Configuration Guide

@Metadata {
    @PageKind(article)
    @CallToAction(
        purpose: link, 
        url: "https://nunav.net/lp/sdk",
        label: "Contact Us"
    )
    @PageImage(
        purpose: card, 
        source: "nunav-navigation-sdk-configuration-card"
    )
}

Get an overview the custom configuration options for the NUNAV Navigation SDK.

The NUNAV Navigation SDK gives you different options to configure the navigation for your app's users. This ranges from
the transport mode to custom routing options. This guide will give you an overview of the different configuration options.

If you need any custom configuration options like special routing strategies please [contact us](https://nunav.net/lp/sdk).

@Row {
    @Column(size: 2) {
        ## Configure the Destination

        This ``DestinationConfiguration`` is used to set the destination for the navigation. The SDK will calculate the route and start the navigation. Additionally you can set a ``DestinationConfiguration/label`` for the user to identify the destination correctly. See ``DestinationConfiguration`` for more information.

        ## Configure the Routing

        The SDK allows you to configure custom routing for the navigation. You can set the ``TransportMode``, additional options like ``RoutingConfiguration/avoidTollRoads``. See ``RoutingConfiguration`` and ``TransportMode`` for more information.
        
        ## Code Examples
        
        ```
        let destination = DestinationConfiguration(
            id: "f8d9e6b8-6c3e-4b1b-8c0c-5b3d9b2b3f8b",
            coordinate: CLLocationCoordinate2D(latitude: 52.520008, longitude: 13.404954),
            label: "Brandenburg Gate"
        )
        ```
        
        ```
        let routing = RoutingConfiguration(
            transportMode: .car,
            avoidTollRoads: false
        )
        ```
    }
    
    @Column {
        ![A screenshot of the NUNAV Navigation SDK example app showing the different configuration options](screen-nunav-navigation-sdk-navigation-example-portrait-light)
    }
}


