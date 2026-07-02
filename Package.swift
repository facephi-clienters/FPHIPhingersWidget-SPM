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
        .package(url: "https://github.com/facephi-clienters/SDK-FPHIDesignSystemResources-SPM.git", exact: "2.7.5"),
        .package(url: "https://github.com/facephi-clienters/FPHILicenseManager-SPM.git", .upToNextMajor(from: "0.5.6")),
        .package(url: "https://github.com/facephi-clienters/FPHILicenseActivator-SPM.git", exact: "1.0.2")
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
                "OpenSSL",
                "opencv2",
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
            url: "https://facephicorp.jfrog.io/artifactory/spm-pro-fphi/WIDGET/FPHIPhingersWidget/1.4.11/FPHIPhingersWidget.zip",
            checksum: "e91c2255e648abfa0464a5eb379a23d4b28389f7e3ca423a2234b8c970c753e6"
        ),
        .binaryTarget(
            name: "T5AirSnapFramework",
            url: "https://facephicorp.jfrog.io/artifactory/spm-pro-fphi/WIDGET/T5AirSnapFramework/1.4.11/T5AirSnapFramework.zip",
            checksum: "e5a6470c3b200205bddfad6df8fa83a91de87eb1f9a5322e641af2d1553f4fa5"
        ),
        .binaryTarget(
            name: "ncnn",
            url: "https://facephicorp.jfrog.io/artifactory/spm-pro-fphi/WIDGET/ncnn/1.4.11/ncnn.zip",
            checksum: "30d4d6e3aedd86a53be2d41eaac39e5bd9372a11adb548df8b7420d7e7d870eb"
        ),
        .binaryTarget(
            name: "OpenSSL",
            url: "https://facephicorp.jfrog.io/artifactory/spm-pro-fphi/WIDGET/OpenSSL/1.4.11/OpenSSL.zip",
            checksum: "b9d13d8fd0dddbc5cc21b865e1299e9dac0dbc91826e35e059f544b8648a045b"
        ),
        .binaryTarget(
            name: "opencv2",
            url: "https://facephicorp.jfrog.io/artifactory/spm-pro-fphi/WIDGET/opencv2/1.4.11/opencv2.zip",
            checksum: "05ad8a32a3a93e112b64b8100b3e134f9f52519a3ae94df1a4d1f404e1772672"
        ),
    ]
)
