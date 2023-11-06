# NunavSDK

![Requires iOS 15.0](https://img.shields.io/badge/iOS-15.0-1575F9?style=flat&logo=apple&label=iOS&link=https%3A%2F%2Fwww.apple.com%2Fde%2Fios)
![Requires Xcode 15](https://img.shields.io/badge/xcode-15-1575F9?style=flat&logo=xcode&label=Xcode&link=https%3A%2F%2Fapps.apple.com%2Fde%2Fapp%2Fxcode%2Fid497799835)
[![Requires Swift 5.9](https://img.shields.io/badge/Swift-5.9-FA7343.svg?style=flat&logo=Swift)](https://swift.org/)
[![SPM compatible](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-FA7343.svg?style=flat&logo=Swift)](https://swift.org/package-manager/)

> **Note**  
> This repository only exists for the purpose of distribution of NunavSDK for iOS on the Swift Package Manager. It contains the code for the NUNAV SDK powering the navigation in third party apps.
> Please contact Grapmasters GmbH directly if you have any issues.

---

## Getting Started

NunavSDK for iOS is distributed using the [Swift Package Manager](https://www.swift.org/package-manager/). To add it to your project, follow the steps below.

### Package.swift

1. Add the following to your dependencies.

```
dependencies: [
    .package(url: "https://github.com/graphmasters/nunav-sdk-ios-distribution", from: "<VERSION>")
]
```

2. Add the dependency to your target.

```
.target(
    name: "Mytarget",
    dependencies: [
        .product(name: "NunavSDK", package: "nunav-sdk-ios-distribution")
    ]
)
```

### Xcode

1. To add a package dependency to your Xcode project, select File > Swift Packages > Add Package Dependency and enter its repository URL. You can also navigate to your target’s General pane, and in the “Frameworks, Libraries, and Embedded Content” section, click the + button, select Add Other, and choose Add Package Dependency.

2. Either add NunavSDK GitHub distribution URL `https://github.com/graphmasters/nunav-sdk-ios-distribution` or search for `nunav-sdk-ios-distribution` package.

3. Choose "Next". Xcode should clone the distribution repository and download the binaries.
