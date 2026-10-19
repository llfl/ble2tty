import Foundation

public enum BLEInboundChannel: Equatable, Sendable {
    case data
    case configuration
}

public enum BLETransportProfile: Equatable, Sendable {
    case ch9140
    case ffe1

    public var serviceUUID: String {
        switch self {
        case .ch9140: CH9140UUID.service
        case .ffe1: "FFE0"
        }
    }

    public var readCharacteristicUUID: String {
        switch self {
        case .ch9140: CH9140UUID.readCharacteristic
        case .ffe1: "FFE1"
        }
    }

    public var writeCharacteristicUUID: String {
        switch self {
        case .ch9140: CH9140UUID.writeCharacteristic
        case .ffe1: "FFE1"
        }
    }

    public var configurationCharacteristicUUID: String? {
        switch self {
        case .ch9140: CH9140UUID.configCharacteristic
        case .ffe1: nil
        }
    }

    public var notificationCharacteristicUUIDs: [String] {
        switch self {
        case .ch9140: [CH9140UUID.readCharacteristic, CH9140UUID.configCharacteristic]
        case .ffe1: ["FFE1"]
        }
    }

    public var supportsCH9140Configuration: Bool {
        self == .ch9140
    }

    public static func supportsNotifications(notify: Bool, indicate: Bool) -> Bool {
        notify || indicate
    }

    public func isReady(readCharacteristicFound: Bool,
                        writeMode: BLEWriteMode?,
                        configurationCharacteristicFound: Bool,
                        notifiedCharacteristicUUIDs: Set<String>) -> Bool {
        guard readCharacteristicFound,
              writeMode != nil,
              configurationCharacteristicUUID == nil || configurationCharacteristicFound else {
            return false
        }
        return notificationCharacteristicUUIDs.allSatisfy {
            notifiedCharacteristicUUIDs.contains($0)
        }
    }

    public func inboundChannel(for characteristicUUID: String) -> BLEInboundChannel? {
        let uuid = characteristicUUID.uppercased()
        if uuid == readCharacteristicUUID { return .data }
        if uuid == configurationCharacteristicUUID { return .configuration }
        return nil
    }

    public static func select(serviceUUIDs: [String]) -> BLETransportProfile? {
        let services = Set(serviceUUIDs.map { $0.uppercased() })
        if services.contains(BLETransportProfile.ch9140.serviceUUID) { return .ch9140 }
        if services.contains(BLETransportProfile.ffe1.serviceUUID) { return .ffe1 }
        return nil
    }
}

public enum BLEWriteMode: Equatable, Sendable {
    case withoutResponse
    case withResponse

    public static func select(writesWithoutResponse: Bool,
                              writesWithResponse: Bool) -> BLEWriteMode? {
        if writesWithoutResponse { return .withoutResponse }
        if writesWithResponse { return .withResponse }
        return nil
    }
}
