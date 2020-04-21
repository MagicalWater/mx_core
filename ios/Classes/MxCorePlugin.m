#import "MxCorePlugin.h"
#import <mx_core/mx_core-Swift.h>

@implementation MxCorePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftMxCorePlugin registerWithRegistrar:registrar];
}
@end
