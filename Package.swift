// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FPHIPhingersWidget-SPM",
    defaultLocalization: "es",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "FPHIPhingersWidget",
            targets: ["FPHIPhingersWidget-SPM"]
        ),
        .library(
            name: "FPHIPhingersWidgetResources",
            targets: ["FPHIPhingersWidgetResources-SPM"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/facephi-clienters/SDK-FPHIDesignSystemResources-SPM.git", exact: "2.7.7"),
        .package(url: "https://github.com/facephi-clienters/FPHILicenseManager-SPM.git", .upToNextMajor(from: "0.5.6")),
        .package(url: "https://github.com/facephi-clienters/FPHILicenseActivator-SPM.git", exact: "1.0.2"),
        .package(url: "https://github.com/krzyzanowskim/OpenSSL.git", exact: "1.1.2301"),
        .package(url: "https://github.com/facephi-clienters/OpenCV-SPM.git", exact: "4.6.0"),
    ],
    targets: [
        .target(
            name: "FPHIPhingersWidget-SPM",
            dependencies: [
                "fphiphingers",
                .product(name: "FPHIDesignSystemResources",
                         package: "SDK-FPHIDesignSystemResources-SPM"),
                "FPHILicenseManager-SPM",
                .product(name: "FPHILicenseActivator-SPM", package: "FPHILicenseActivator-SPM"),
                "FPHIPhingersWidgetResources-SPM",
                "ncnn",
                .product(name: "OpenSSL", package: "OpenSSL"),
                .product(name: "OpenCV-SPM", package: "OpenCV-SPM"),
                "T5AirSnapBridge",
            ]
        ),
        .target(
            name: "FPHIPhingersWidgetResources-SPM",
            resources: [
                .copy("compose/cocoapods/compose-resources"),
                .copy("cocoapods/resources/com.facephi.tf.models"),
            ]
        ),
        .target(
            name: "T5AirSnapBridge",
            dependencies: ["T5AirSnapFramework"]
        ),
        .binaryTarget(
            name: "fphiphingers",
            url: "https://facephicorp.jfrog.io/artifactory/spm-pro-fphi/WIDGET/FPHIPhingersWidget/1.4.12/FPHIPhingersWidget.zip",
            checksum: "015f3828bc93f6ce321be89d937d9680880a7e330ff6ba9b247725b7c7f351ca"
        ),
        .binaryTarget(
            name: "T5AirSnapFramework",
            url: "https://facephicorp.jfrog.io/artifactory/spm-pro-fphi/WIDGET/T5AirSnapFramework/1.4.12/T5AirSnapFramework.zip",
            checksum: "8b3a7382336ee53515122729220ee4e3f9f10661a1587a34ff17684cbbb0dca9"
        ),
        .binaryTarget(
            name: "ncnn",
            url: "https://facephicorp.jfrog.io/artifactory/spm-pro-fphi/WIDGET/FPHIPhingersTFFrameworks/ncnn/7.1.0/ncnn.zip",
            checksum: "65614c21cdc015954045e593bfcd4e5919175c7b1a4e981ed7a93e32cf43e513"
        ),
    ]
)
