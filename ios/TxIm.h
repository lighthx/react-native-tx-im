#import <React/RCTBridgeModule.h>
#import <ImSDK/ImSDK.h>
#import <React/RCTEventEmitter.h>

@interface TxIm : RCTEventEmitter <RCTBridgeModule,V2TIMSDKListener,V2TIMSimpleMsgListener,V2TIMConversationListener,V2TIMGroupListener>  //protocol
@property(copy,readwrite) RCTPromiseResolveBlock loginResolve;
@property(copy,readwrite) RCTPromiseRejectBlock loginReject;
@end
