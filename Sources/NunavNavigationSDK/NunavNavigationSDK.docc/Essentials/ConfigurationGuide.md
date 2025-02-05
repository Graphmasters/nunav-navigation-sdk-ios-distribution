# Configuration Guide

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

Get an overview the custom configuration options for the NUNAV Navigation SDK. The NUNAV Navigation SDK gives you different options to configure the navigation for your app's users.

## Configure the Destination

The easiest way is to use the ``DestinationConfiguration``. This configuration is used to set the destination for the navigation. The SDK will then calculate the route and start the navigation. Additionally you can set a ``DestinationConfiguration/id`` for the server to identify the destination and a ``DestinationConfiguration/label`` for the user to identify the destination correctly. See ``DestinationConfiguration`` for more information.

## Configure the Routing

The SDK allows you to configure custom routing for the navigation. You can set the ``TransportMode``, additional options like ``RoutingConfiguration/avoidTollRoads`` and optionally a ``RoutingConfiguration/contextToken`` for custom routing decided by the server. See ``RoutingConfiguration`` and ``TransportMode`` for more information.
