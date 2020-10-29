#import <React/RCTBridgeModule.h>
#import <ImSDK.h>

@interface TxIm : NSObject <RCTBridgeModule,V2TIMSDKListener,V2TIMAdvancedMsgListener,V2TIMConversationListener,V2TIMGroupListener,V2TIMFriendshipListener>

@end
