import Foundation
import T5AirSnapFramework

private let defaultPositionCodeRawValue: UInt32 = 0
private let maxAnalyzeLogs = 10
private let analyzeLogEvery = 30

private let unknownPositionCode = NIST_POS_CODE(rawValue: defaultPositionCodeRawValue)

private func makePositionCode(_ value: Int32) -> NIST_POS_CODE {
    let raw = UInt32(bitPattern: value)
    return NIST_POS_CODE(rawValue: raw)
}

private func bridgeLog(_ message: String) {
    NSLog("[T5AirSnapBridge] %@", message)
}

@objcMembers
public final class T5BridgeRectCoordinate: NSObject {
    public let x: Int32
    public let y: Int32

    public init(x: Int32, y: Int32) {
        self.x = x
        self.y = y
        super.init()
    }
}

@objcMembers
public final class T5BridgeRectSeed: NSObject {
    public let positionCodeValue: Int32
    public let coordinates: [T5BridgeRectCoordinate]

    public init(positionCodeValue: Int32, coordinates: [T5BridgeRectCoordinate] = []) {
        self.positionCodeValue = positionCodeValue
        self.coordinates = coordinates
        super.init()
    }

    internal func apply(to rect: SgmRectImage) {
        rect.pos = makePositionCode(positionCodeValue)
        rect.coords = normalizeCoordinates(coordinates)
    }
}

@objcMembers
public final class T5BridgeRectSnapshot: NSObject {
    public let positionCodeValue: Int32
    public let width: Int32
    public let height: Int32
    public let focused: Bool
    public let coordinates: [T5BridgeRectCoordinate]

    internal init(rect: SgmRectImage) {
        self.positionCodeValue = Int32(bitPattern: rect.pos.rawValue)
        self.width = Int32(rect.width)
        self.height = Int32(rect.height)
        self.focused = rect.focused
        self.coordinates = rect.coords.map { pair in
            let x = pair.first ?? 0
            let y = pair.count > 1 ? pair[1] : 0
            return T5BridgeRectCoordinate(x: x, y: y)
        }
        super.init()
    }

    @objc(isFocused)
    public func isFocused() -> Bool {
        focused
    }

    public func toSeed() -> T5BridgeRectSeed {
        T5BridgeRectSeed(positionCodeValue: positionCodeValue, coordinates: coordinates)
    }
}

@objcMembers
public final class T5BridgeAnalysisResult: NSObject {
    public let statusRawValue: Int32
    public let statusDescription: String
    public let rectCount: Int32
    public let rects: [T5BridgeRectSnapshot]

    internal init(status: Int, rects: [T5BridgeRectSnapshot], rectCount: Int32) {
        self.statusRawValue = Int32(status)
        self.statusDescription = String(status)
        self.rectCount = rectCount
        self.rects = rects
        super.init()
    }
}

@objcMembers
public final class T5BridgeSegmentedRect: NSObject {
    public let positionCodeValue: Int32
    public let width: Int32
    public let height: Int32
    public let focused: Bool
    public let coordinates: [T5BridgeRectCoordinate]
    public let livenessScore: Float
    public let rawImage: Data?
    public let compressedImage: Data?

    internal init(rect: SgmRectImage, livenessScore: Float) {
        self.positionCodeValue = Int32(bitPattern: rect.pos.rawValue)
        self.width = Int32(rect.width)
        self.height = Int32(rect.height)
        self.focused = rect.focused
        self.coordinates = rect.coords.map { pair in
            let x = pair.first ?? 0
            let y = pair.count > 1 ? pair[1] : 0
            return T5BridgeRectCoordinate(x: x, y: y)
        }
        self.livenessScore = livenessScore
        self.rawImage = T5BridgeSegmentedRect.copyData(from: rect.image, count: Int(rect.width * rect.height))
        self.compressedImage = T5BridgeSegmentedRect.copyData(
            from: rect.compressedImage,
            count: Int(rect.compressedImageSize)
        )
        super.init()
    }

    @objc(isFocused)
    public func isFocused() -> Bool {
        focused
    }

    private static func copyData(from pointer: UnsafeMutablePointer<UInt8>?, count: Int) -> Data? {
        guard let pointer, count > 0 else { return nil }
        return Data(bytes: pointer, count: count)
    }
}

@objcMembers
public final class T5BridgeSegmentationResult: NSObject {
    public let statusCode: Int32
    public let rectCount: Int32
    public let rects: [T5BridgeSegmentedRect]

    internal init(statusCode: Int32, rects: [T5BridgeSegmentedRect], rectCount: Int32) {
        self.statusCode = statusCode
        self.rects = rects
        self.rectCount = rectCount
        super.init()
    }
}

@objcMembers
public final class T5BridgeInitResult: NSObject {
    public let statusCode: Int32
    public let message: String

    public init(statusCode: Int32, message: String) {
        self.statusCode = statusCode
        self.message = message
        super.init()
    }
}

@objcMembers
public final class T5BridgeSdk: NSObject {
    public static func initSdk(sdk: T5AirSnap, license: String) -> T5BridgeInitResult {
        let work: () -> T5BridgeInitResult = {
            var ret: Int32 = 0
            bridgeLog("initSdk start licenseLength=\(license.count) main=\(Thread.isMainThread)")
            let message = license.utf8CString.withUnsafeBufferPointer { buffer -> String in
                guard let base = buffer.baseAddress else { return "" }
                let bytes = UnsafeRawPointer(base).assumingMemoryBound(to: UInt8.self)
                return sdk.initSDK(license: bytes, ret: &ret)
            }
            bridgeLog("initSdk end ret=\(ret) msgLength=\(message.count)")
            return T5BridgeInitResult(statusCode: ret, message: message)
        }

        if Thread.isMainThread {
            return work()
        }
        return DispatchQueue.main.sync {
            work()
        }
    }
}

@objcMembers
public final class T5BridgeAnalyzer: NSObject {
    private var rectPool: [SgmRectImage] = []
    private let defaultCapacity: Int
    private var analyzeCallCount: Int = 0

    public init(defaultCapacity: Int = 4) {
        self.defaultCapacity = max(1, defaultCapacity)
        super.init()
        bridgeLog("T5BridgeAnalyzer init defaultCapacity=\(self.defaultCapacity)")
    }

    /// Ejecuta `T5AirSnap.analyzeImage` usando `SgmRectImage` sin exponerlos al módulo KMP.
    /// - Parameters:
    ///   - sdk: Instancia de `T5AirSnap` ya configurada por Kotlin/Native.
    ///   - yBuffer/vuBuffer: Punteros al frame en formato NV12.
    ///   - rotationDegrees: Rotación aplicada al frame.
    ///   - width/height: Dimensiones del frame.
    ///   - currDistance: Mantiene compatibilidad con la firma actual (el SDK Swift no lo usa todavía).
    ///   - seeds: Semillas (posición y coordenadas) provenientes del cuadro anterior.
    /// - Returns: `T5BridgeAnalysisResult` con los rectángulos ya listos para Kotlin.
    public func analyze(
        sdk: T5AirSnap,
        yBuffer: UnsafeMutablePointer<UInt8>,
        vuBuffer: UnsafeMutablePointer<UInt8>,
        rotationDegrees: Int32,
        width: Int32,
        height: Int32,
        currDistance: Float,
        seeds: [T5BridgeRectSeed]
    ) -> T5BridgeAnalysisResult {
        let callIndex = analyzeCallCount
        analyzeCallCount += 1

        let shouldLog = callIndex < maxAnalyzeLogs || (callIndex % analyzeLogEvery == 0)
        if shouldLog {
            bridgeLog(
                "analyze #\(callIndex) w=\(width)x\(height) rot=\(rotationDegrees) " +
                "currDistance=\(currDistance) seeds=\(seeds.count)"
            )
        }
        _ = currDistance // El framework Swift aún no expone esta configuración.

        let activeCount = computeActiveCount(seedCount: seeds.count)
        ensureRectPoolSize(activeCount)

        let activeRects = prepareRects(targetCount: activeCount, seeds: seeds)
        var rectCount = Int32(activeRects.count)
        let status = sdk.analyzeImage(
            yBuffer: yBuffer,
            vuBuffer: vuBuffer,
            rotationDegrees: rotationDegrees,
            width: width,
            height: height,
            rects: activeRects,
            rectsCount: &rectCount
        )
        if shouldLog {
            bridgeLog("analyze #\(callIndex) status=\(status) rectCount=\(rectCount)")
        }
        let snapshots = (0..<Int(rectCount)).map { index in
            T5BridgeRectSnapshot(rect: activeRects[index])
        }
        return T5BridgeAnalysisResult(status: status, rects: snapshots, rectCount: rectCount)
    }

    private func computeActiveCount(seedCount: Int) -> Int {
        if seedCount <= 0 {
            return defaultCapacity
        }
        return min(defaultCapacity, seedCount)
    }

    private func ensureRectPoolSize(_ count: Int) {
        guard count > rectPool.count else { return }
        let missing = count - rectPool.count
        bridgeLog("ensureRectPoolSize expanding by \(missing) (newCount=\(count))")
        for _ in 0..<missing {
            rectPool.append(SgmRectImage())
        }
    }

    private func prepareRects(targetCount: Int, seeds: [T5BridgeRectSeed]) -> [SgmRectImage] {
        guard !rectPool.isEmpty else { return [] }
        for index in 0..<targetCount {
            let rect = rectPool[index]
            if index < seeds.count {
                seeds[index].apply(to: rect)
            } else {
                reset(rect: rect)
            }
        }
        return Array(rectPool.prefix(targetCount))
    }

    private func reset(rect: SgmRectImage) {
        rect.pos = unknownPositionCode
        rect.coords = normalizeCoordinates()
        rect.focused = false
        rect.width = 0
        rect.height = 0
        rect.image = nil
        rect.compressedImage = nil
        rect.compressedImageSize = 0
    }
}

@objcMembers
public final class T5BridgeSegmenter: NSObject {
    private var rectPool: [SgmRectImage] = []
    private let defaultCapacity: Int

    public init(defaultCapacity: Int = 4) {
        self.defaultCapacity = max(1, defaultCapacity)
        super.init()
        bridgeLog("T5BridgeSegmenter init defaultCapacity=\(self.defaultCapacity)")
    }

    public func getSegmentedFingers(
        sdk: T5AirSnap,
        yBuffer: UnsafeMutablePointer<UInt8>,
        gender: UInt8,
        age: UInt8,
        clean: Bool,
        seeds: [T5BridgeRectSeed]
    ) -> T5BridgeSegmentationResult {
        let activeCount = computeActiveCount(seedCount: seeds.count)
        ensureRectPoolSize(activeCount)
        let activeRects = prepareRects(targetCount: activeCount, seeds: seeds)
        var rectCount = Int32(activeRects.count)
        var livenessScores = Array(repeating: Float(-1), count: max(activeRects.count, 4))

        let status = livenessScores.withUnsafeMutableBufferPointer { buffer -> Int32 in
            guard let baseAddress = buffer.baseAddress else { return -1 }
            return sdk.getSegmentedFingers(
                grayBuffer: yBuffer,
                gender: gender,
                age: age,
                clean: clean,
                rects: activeRects,
                rectsCount: &rectCount,
                livenessScore: baseAddress
            )
        }

        let boundedCount = max(0, min(Int(rectCount), activeRects.count))
        let snapshots = (0..<boundedCount).map { index in
            T5BridgeSegmentedRect(rect: activeRects[index], livenessScore: livenessScores[index])
        }
        bridgeLog("getSegmentedFingers status=\(status) rectCount=\(rectCount) mapped=\(snapshots.count)")
        return T5BridgeSegmentationResult(statusCode: status, rects: snapshots, rectCount: rectCount)
    }

    private func computeActiveCount(seedCount: Int) -> Int {
        if seedCount <= 0 {
            return defaultCapacity
        }
        return min(defaultCapacity, seedCount)
    }

    private func ensureRectPoolSize(_ count: Int) {
        guard count > rectPool.count else { return }
        let missing = count - rectPool.count
        bridgeLog("segmenter ensureRectPoolSize expanding by \(missing) (newCount=\(count))")
        for _ in 0..<missing {
            rectPool.append(SgmRectImage())
        }
    }

    private func prepareRects(targetCount: Int, seeds: [T5BridgeRectSeed]) -> [SgmRectImage] {
        guard !rectPool.isEmpty else { return [] }
        for index in 0..<targetCount {
            let rect = rectPool[index]
            if index < seeds.count {
                seeds[index].apply(to: rect)
            } else {
                reset(rect: rect)
            }
        }
        return Array(rectPool.prefix(targetCount))
    }

    private func reset(rect: SgmRectImage) {
        rect.pos = unknownPositionCode
        rect.coords = normalizeCoordinates()
        rect.focused = false
        rect.width = 0
        rect.height = 0
        rect.image = nil
        rect.compressedImage = nil
        rect.compressedImageSize = 0
    }
}

private func normalizeCoordinates(_ coords: [T5BridgeRectCoordinate] = []) -> [[Int32]] {
    var result = coords.map { [$0.x, $0.y] }
    if result.count < 4 {
        result.append(contentsOf: Array(repeating: [0, 0], count: 4 - result.count))
    } else if result.count > 4 {
        result = Array(result.prefix(4))
    }
    return result
}
