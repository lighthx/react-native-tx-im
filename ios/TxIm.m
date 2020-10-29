#import "TxIm.h"


@implementation TxIm

RCT_EXPORT_MODULE()

// Example method
// See // https://facebook.github.io/react-native/docs/native-modules-ios
RCT_REMAP_METHOD(multiply,
                 multiplyWithA:(nonnull NSNumber*)a withB:(nonnull NSNumber*)b
                 withResolver:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock)reject)
{
  NSNumber *result = @([a floatValue] * [b floatValue]);

  resolve(result);
}
RCT_REMAP_METHOD(init,init_sdkAppId:(NSNumber*)sdkAppId)
{
    
V2TIMSDKConfig *config = [[V2TIMSDKConfig alloc] init];
// 3. 指定 log 输出级别，详情请参考 SDKConfig。
config.logLevel = V2TIM_LOG_INFO;
// 4. 初始化 SDK 并设置 V2TIMSDKListener 的监听对象。
// initSDK 后 SDK 会自动连接网络，网络连接状态可以在 V2TIMSDKListener 回调里面监听。
[[V2TIMManager sharedInstance] initSDK:[sdkAppId intValue] config:config listener:self];
}
- (void)onConnecting {
    // 正在连接到腾讯云服务器
}
- (void)onConnectSuccess {
    // 已经成功连接到腾讯云服务器
}
- (void)onConnectFailed:(int)code err:(NSString*)err {
    // 连接腾讯云服务器失败
}

@end
