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
        .package(url: "https://github.com/facephi-clienters/SDK-FPHIDesignSystemResources-SPM.git", exact: "2.8.0"),
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
            url: "https://facephicorp.jfrog.io/artifactory/spm-pro-fphi/WIDGET/FPHIPhingersWidget/1.5.0/FPHIPhingersWidget.zip",
            checksum: "5dcdcc2fc5a873463768398dbe968f5eb035980d5a69a4d2e6c4ed2300b52b11"
        ),
        .binaryTarget(
            name: "T5AirSnapFramework",
            url: "https://facephicorp.jfrog.io/artifactory/spm-pro-fphi/WIDGET/T5AirSnapFramework/1.5.0/T5AirSnapFramework.zip",
            checksum: "e30bb7b18db4b6821d4941bbc973db8a2a4efab02528cd6f030bc00b02a98418"
        ),
        .binaryTarget(
            name: "ncnn",
            url: "https://facephicorp.jfrog.io/artifactory/spm-pro-fphi/WIDGET/FPHIPhingersTFFrameworks/ncnn/7.1.0/ncnn.zip",
            checksum: "65614c21cdc015954045e593bfcd4e5919175c7b1a4e981ed7a93e32cf43e513"
        ),
    ]
)
