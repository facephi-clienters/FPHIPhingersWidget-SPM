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
        .package(url: "https://github.com/facephi-clienters/SDK-FPHIDesignSystemResources-SPM.git", .upToNextMinor(from: "2.7.5")),
        .package(url: "https://github.com/facephi-clienters/FPHILicenseManager-SPM.git", .upToNextMajor(from: "0.5.6")),
        .package(url: "https://github.com/facephi-clienters/FPHILicenseActivator-SPM.git", exact: "1.0.1")
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
            url: "https://facephicorp.jfrog.io/artifactory/spm-dev-fphi/WIDGET/FPHIPhingersWidget/1.4.9/FPHIPhingersWidget.zip",
            checksum: "2fbb5f73d81f7f7a3b3564daddc6ad1646eaf9e4823a85d044e654c84d2bb83d"
        ),
        .binaryTarget(
            name: "T5AirSnapFramework",
            url: "https://facephicorp.jfrog.io/artifactory/spm-dev-fphi/WIDGET/T5AirSnapFramework/1.4.9/T5AirSnapFramework.zip",
            checksum: "264d735f2944deedaf9b128b4b05e7158f35f3ae9f58f301c87eafa2b1bafe02"
        ),
        .binaryTarget(
            name: "ncnn",
            url: "https://facephicorp.jfrog.io/artifactory/spm-dev-fphi/WIDGET/ncnn/1.4.9/ncnn.zip",
            checksum: "efac6e26ed7e4f59bda75ad4694a6525d5b5f44a1276961d1eb6cc1f274f2584"
        ),
        .binaryTarget(
            name: "OpenSSL",
            url: "https://facephicorp.jfrog.io/artifactory/spm-dev-fphi/WIDGET/OpenSSL/1.4.9/OpenSSL.zip",
            checksum: "3273eb5be1ba657d2e6f732f52b204bf0c42c70e6068f85c599841fbfc918adb"
        ),
        .binaryTarget(
            name: "opencv2",
            url: "https://facephicorp.jfrog.io/artifactory/spm-dev-fphi/WIDGET/opencv2/1.4.9/opencv2.zip",
            checksum: "97f12f95c886f72b6ec48ba35671dcc90594bca0a4f08d5495b0296c494bab71"
        ),
    ]
)
