#import "PushPlugin.h"
#if __has_include(<unifonic_sdk_flutter_ios/unifonic_sdk_flutter_ios-Swift.h>)
#import <unifonic_sdk_flutter_ios/unifonic_sdk_flutter_ios-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "unifonic_sdk_flutter_ios-Swift.h"
#endif

@implementation PushPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftPushPlugin registerWithRegistrar:registrar];
}
@end
