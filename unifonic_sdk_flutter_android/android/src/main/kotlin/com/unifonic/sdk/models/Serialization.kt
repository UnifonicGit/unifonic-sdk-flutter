package com.unifonic.sdk.models

import com.google.firebase.messaging.RemoteMessage as FcmRemoteMessage

fun FcmRemoteMessage.toMap(): Map<String, Any?> {
    return mapOf<String, Any?>(
        "data" to data,
        "notification" to notification?.toMap()
    )
}

fun FcmRemoteMessage.Notification.toMap(): Map<String, Any?> {
    return mapOf(
        "title" to this.title,
        "body" to this.body
    )
}

fun FcmRemoteMessage.Notification.toPushNotification(): Notification {
    return Notification(this.title, this.body)
}

fun FcmRemoteMessage.toPushRemoteMessage(): RemoteMessage {
    return RemoteMessage(this.notification?.toPushNotification(), this.data.toMap())
}
