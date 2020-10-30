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
RCT_REMAP_METHOD(init,init_sdkAppId:(NSNumber*)sdkAppId
                 withResolver:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock)reject)
{
    
V2TIMSDKConfig *config = [[V2TIMSDKConfig alloc] init];

config.logLevel = V2TIM_LOG_INFO;

BOOL result=[[V2TIMManager sharedInstance] initSDK:[sdkAppId intValue] config:config listener:self];
    self.loginResolve=resolve;
    self.loginReject=reject;
}

RCT_REMAP_METHOD(
                  login,
                  login_userSig:(NSString *)userSig
                  login_userId:(NSString *)userId
                  login_nickName:(NSString *)nickName
                  login_avatar:(NSString *)avatar
                  withResolver1:(RCTPromiseResolveBlock)resolve
                  withRejecter1:(RCTPromiseRejectBlock)reject)
                  {
                      [[V2TIMManager sharedInstance] login:userId userSig:userSig succ:^{
                          V2TIMUserFullInfo *info = [V2TIMUserFullInfo alloc];
                          info.faceURL=avatar;
                          info.nickName=nickName;
                          [[V2TIMManager sharedInstance] setSelfInfo:info succ:^{
                                                        resolve(@"success");
                                                    } fail:^(int code, NSString *desc) {
                                                        reject([NSString stringWithFormat:@"%d",code],desc,nil);
                                                    }];
                         
                      } fail:^(int code, NSString *desc) {
                          reject([NSString stringWithFormat:@"%d",code],desc,nil);
                      }];
    
}

RCT_REMAP_METHOD(joinGroup,
                 joinGroup_groupId:(NSString *)groupId
                 withResolver2:(RCTPromiseResolveBlock)resolve
                 withRejecter2:(RCTPromiseRejectBlock)reject
                 ){
    [[V2TIMManager sharedInstance] joinGroup:groupId msg:nil succ:^{
            resolve(@"success");
        } fail:^(int code, NSString *desc) {
            reject([NSString stringWithFormat:@"%d",code],desc,nil);
        }];
}

RCT_REMAP_METHOD(sendTextMessage,
                 sendTextMessage_message:(NSString *)message
                 sendTextMessage_userId:(NSString *)userId
                 withResolver3:(RCTPromiseResolveBlock)resolve
                 withRejecter3:(RCTPromiseRejectBlock)reject
                 ){
    [[V2TIMManager sharedInstance] sendC2CTextMessage:message to:userId succ:^{
        resolve(@"success");
    } fail:^(int code, NSString *desc) {
        reject([NSString stringWithFormat:@"%d",code],desc,nil);
    }];
}

RCT_REMAP_METHOD(sendTextGroupMessage,
                 sendTextMessage_message1:(NSString *)message
                 sendTextMessage_userId1:(NSString *)userId
                 sendTextMessage_groupId:(NSString *)groupId
                 withResolver4:(RCTPromiseResolveBlock)resolve
                 withRejecter4:(RCTPromiseRejectBlock)reject
                 ){
    [[V2TIMManager sharedInstance] sendGroupTextMessage:message to:groupId priority:V2TIM_PRIORITY_DEFAULT succ:^{
        resolve(@"success");
    } fail:^(int code, NSString *desc) {
        reject([NSString stringWithFormat:@"%d",code],desc,nil);
    }];
}

RCT_REMAP_METHOD(sendCustomMessage,
                 sendCustomMessage_type:(NSString *)type
                 sendCustomMessage_message:(NSString *)message
                 sendCustomMessage_userId:(NSString *)userId
                 withResolver5:(RCTPromiseResolveBlock)resolve
                 withRejecter5:(RCTPromiseRejectBlock)reject
                 ){
    NSString* msg=[NSString stringWithFormat:@"{\"type\":%@,\"message\":%@}",type,message];
    NSData* data=[msg dataUsingEncoding:NSUTF8StringEncoding];
    [[V2TIMManager sharedInstance] sendGroupCustomMessage:data to:userId priority:V2TIM_PRIORITY_DEFAULT succ:^{
        resolve(@"success");
    } fail:^(int code, NSString *desc) {
        reject([NSString stringWithFormat:@"%d",code],desc,nil);
    }];
}

RCT_REMAP_METHOD(sendGroupCustomMessage,
                 sendCustomMessage_type1:(NSString *)type
                 sendCustomMessage_message1:(NSString *)message
                 sendCustomMessage_groupId:(NSString *)groupId
                 withResolver6:(RCTPromiseResolveBlock)resolve
                 withRejecter6:(RCTPromiseRejectBlock)reject
                 ){
    NSString* msg=[NSString stringWithFormat:@"{\"type\":%@,\"message\":%@}",type,message];
    NSData* data=[msg dataUsingEncoding:NSUTF8StringEncoding];
    [[V2TIMManager sharedInstance] sendGroupCustomMessage:data to:groupId priority:V2TIM_PRIORITY_DEFAULT succ:^{
        resolve(@"success");
    } fail:^(int code, NSString *desc) {
        reject([NSString stringWithFormat:@"%d",code],desc,nil);
    }];
}

-(void)onRecvC2CTextMessage:(NSString *)msgID sender:(V2TIMUserInfo *)info text:(NSString *)text{
    NSDictionary* data=@{
        @"type":@"text",
        @"avatar":info.faceURL,
        @"name":info.nickName,
        @"userId":info.userID,
        @"content":text,
    };
    [self sendEventWithName:@"txim" body:data];
}

-(void)onRecvC2CCustomMessage:(NSString *)msgID sender:(V2TIMUserInfo *)info customData:(NSData *)data{
    NSDictionary* data1=@{
        @"type":@"custom",
        @"avatar":info.faceURL,
        @"name":info.nickName,
        @"userId":info.userID,
        @"content":[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding],
    };
    [self sendEventWithName:@"txim" body:data1];
    
}
-(void)onRecvGroupTextMessage:(NSString *)msgID groupID:(NSString *)groupID sender:(V2TIMGroupMemberInfo *)info text:(NSString *)text{

    NSDictionary* data=@{
        @"type":@"text",
        @"avatar":info.faceURL,
        @"name":info.nickName,
        @"groupId":groupID,
        @"userId":info.userID,
        @"content":text,
    };
    [self sendEventWithName:@"txim" body:data];
}
-(void)onRecvGroupCustomMessage:(NSString *)msgID groupID:(NSString *)groupID sender:(V2TIMGroupMemberInfo *)info customData:(NSData *)data{
    NSDictionary* data1=@{
        @"type":@"custom",
        @"avatar":info.faceURL,
        @"name":info.nickName,
        @"userId":info.userID,
        @"groupId":groupID,
        @"content":[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding],
    };
    [self sendEventWithName:@"txim" body:data1];
}

-(NSArray<NSString*>*)supportedEvents{
    return @[@"txim"];
}

- (void)onConnecting {
    // 正在连接到腾讯云服务器

}
- (void)onConnectSuccess {
    // 已经成功连接到腾讯云服务器
    self.loginResolve(@"success");
}
- (void)onConnectFailed:(int)code err:(NSString*)err {
    // 连接腾讯云服务器失败
    self.loginReject([NSString stringWithFormat:@"%d",code], err, nil);
}

@end
