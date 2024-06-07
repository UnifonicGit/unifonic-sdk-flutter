import Foundation

extension UNIRemoteMessage {
    static func from(userInfo: [AnyHashable: Any]) -> UNIRemoteMessage {
        let message = UNIRemoteMessage()
        message.data = userInfo as? [String: Any]
        message.notification = UNINotification.from(userInfo: userInfo)
        return message
    }

    static func fromNotificationContent(content: UNNotificationContent) -> UNIRemoteMessage {
        let message = UNIRemoteMessage()
        message.data = content.userInfo as? [String: Any]
        
        let notification = UNINotification()
        notification.title = content.title
        notification.body = content.body
        message.notification = notification
        
        return message
    }
}

extension UNINotification {
    static func from(userInfo: [AnyHashable: Any]) -> UNINotification? {
        guard let aps = userInfo["aps"] as? [AnyHashable: Any] else {
            return nil
        }
        
        let notification = UNINotification()
        if let alert = aps["alert"] as? [AnyHashable: Any] {
            notification.title = alert["title"] as? String
            notification.body = alert["body"] as? String
        } else if let title = aps["alert"] as? String {
            notification.title = title
        } else {
            return nil
        }
        return notification
    }
}

extension UNIUNNotificationSettings {
    static func from(unSettings: UNNotificationSettings) -> UNIUNNotificationSettings {
        let settings = UNIUNNotificationSettings()
        settings.soundSetting = UNIUNNotificationSettingBox(value: unSettings.soundSetting.toSerializable())
        settings.badgeSetting = UNIUNNotificationSettingBox(value: unSettings.badgeSetting.toSerializable())
        settings.alertSetting = UNIUNNotificationSettingBox(value: unSettings.alertSetting.toSerializable())
        settings.notificationCenterSetting = UNIUNNotificationSettingBox(value: unSettings.notificationCenterSetting.toSerializable())
        settings.lockScreenSetting = UNIUNNotificationSettingBox(value: unSettings.lockScreenSetting.toSerializable())
        settings.carPlaySetting = UNIUNNotificationSettingBox(value: unSettings.carPlaySetting.toSerializable())
        settings.authorizationStatus = UNIUNAuthorizationStatusBox(value: unSettings.authorizationStatus.toSerializable())
        settings.alertStyle = UNIUNAlertStyleBox(value: unSettings.alertStyle.toSerializable())

        if #available(iOS 11.0, *) {
            settings.showPreviewsSetting = UNIUNShowPreviewsSettingBox(value: unSettings.showPreviewsSetting.toSerializable())
        } else {
            settings.showPreviewsSetting = UNIUNShowPreviewsSettingBox(value: .always)
        }

        if #available(iOS 12.0, *) {
            settings.providesAppNotificationSettings = NSNumber(booleanLiteral: unSettings.providesAppNotificationSettings)
            settings.criticalAlertSetting = UNIUNNotificationSettingBox(value: unSettings.criticalAlertSetting.toSerializable())
        } else {
            settings.providesAppNotificationSettings = false
            settings.criticalAlertSetting = UNIUNNotificationSettingBox(value: .notSupported)
        }

        if #available(iOS 13.0, *) {
            settings.announcementSetting = UNIUNNotificationSettingBox(value: unSettings.announcementSetting.toSerializable())
        } else {
            settings.announcementSetting = UNIUNNotificationSettingBox(value: .notSupported)
        }

        return settings
    }
}

extension UNNotificationSetting {
    func toSerializable() -> UNIUNNotificationSetting {
        switch self {
        case .notSupported:
            return .notSupported
        case .disabled:
            return .disabled
        case .enabled:
            return .enabled
        @unknown default:
            print("Received unknown notificationSetting: \(self), defaulting to .notSupported")
            return .notSupported
        }
    }
}

extension UNAuthorizationStatus {
    func toSerializable() -> UNIUNAuthorizationStatus {
        switch self {
        case .notDetermined:
            return .notDetermined
        case .denied:
            return .denied
        case .authorized:
            return .authorized
        case .provisional:
            return .provisional
        case .ephemeral:
            return .ephemeral
        @unknown default:
            print("Received unknown UNAuthorizationStatus: \(self), defaulting to .notDetermined")
            return .notDetermined
        }
    }
}

extension UNAlertStyle {
    func toSerializable() -> UNIUNAlertStyle {
        switch self {
        case .none:
            return .none
        case .banner:
            return .banner
        case .alert:
            return .alert
        @unknown default:
            print("Received unknown UNAlertStyle: \(self), defaulting to .alert")
            return .alert
        }
    }
}

@available(iOS 11.0, *)
extension UNShowPreviewsSetting {
    func toSerializable() -> UNIUNShowPreviewsSetting {
        switch self {
        case .always:
            return .always
        case .whenAuthenticated:
            return .whenAuthenticated
        case .never:
            return .never
        @unknown default:
            print("Received unknown UNShowPreviewsSetting: \(self), defaulting to .whenAuthenticated")
            return .whenAuthenticated
        }
    }
}
