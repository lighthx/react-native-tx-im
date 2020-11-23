#import "TxIm.h"


@implementation TxIm

RCT_EXPORT_MODULE()

// Example method
// See // https://facebook.github.io/react-native/docs/native-modules-ios

RCT_REMAP_METHOD(init,init_sdkAppId:(nonnull NSNumber*)sdkAppId
                 withResolver:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock)reject)
{

V2TIMSDKConfig *config = [[V2TIMSDKConfig alloc] init];

config.logLevel = V2TIM_LOG_INFO;
    int sdkId =[sdkAppId intValue];
    BOOL result=[[V2TIMManager sharedInstance] initSDK:sdkId config:config listener:self];
    if(result){
        resolve(@"success");
    }else{
        reject(@"failed",@"failed",nil);
    }
}

RCT_REMAP_METHOD(
                  login,
                  login_userSig:(nonnull NSString *)userSig
                  login_userId:(nonnull NSString *)userId
                  login_nickName:(nonnull NSString *)nickName
                  login_avatar:(nonnull NSString *)avatar
                  withResolver1:(RCTPromiseResolveBlock)resolve
                  withRejecter1:(RCTPromiseRejectBlock)reject)
                  {
                      [[V2TIMManager sharedInstance] login:userId userSig:userSig succ:^{
                          V2TIMUserFullInfo *info = [V2TIMUserFullInfo alloc];
                          info.faceURL=avatar;
                          info.nickName=nickName;
                          [[V2TIMManager sharedInstance] setSelfInfo:info succ:^{
                              [[V2TIMManager sharedInstance] addSimpleMsgListener:self];
                                                        resolve(@"success");
                                                    } fail:^(int code, NSString *desc) {
                                                        reject([NSString stringWithFormat:@"%d",code],desc,nil);
                                                    }];

                      } fail:^(int code, NSString *desc) {
                          reject([NSString stringWithFormat:@"%d",code],desc,nil);
                      }];

}

RCT_REMAP_METHOD(joinGroup,
                 joinGroup_groupId:(nonnull NSString *)groupId
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
                 sendTextMessage_message:(nonnull NSString *)message
                 sendTextMessage_userId:(nonnull NSString *)userId
                 withResolver3:(RCTPromiseResolveBlock)resolve
                 withRejecter3:(RCTPromiseRejectBlock)reject
                 ){

    [[V2TIMManager sharedInstance] sendC2CTextMessage:message to:userId succ:^{
        resolve(@"success");
    } fail:^(int code, NSString *desc) {
        reject([NSString stringWithFormat:@"%d",code],desc,nil);
    }];
}

RCT_REMAP_METHOD(sendGroupTextMessage,
                 sendTextMessage_message1:(nonnull NSString *)message
                 sendTextMessage_groupId:(nonnull NSString *)groupId
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
                 sendCustomMessage_type:(nonnull NSString *)type
                 sendCustomMessage_message:(nonnull NSString *)message
                 sendCustomMessage_userId:(nonnull NSString *)userId
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
                 sendCustomMessage_type1:(nonnull NSString *)type
                 sendCustomMessage_message1:(nonnull NSString *)message
                 sendCustomMessage_groupId:(nonnull NSString *)groupId
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

RCT_REMAP_METHOD(getGroupMembers,
                 getGroupMembers_groupId:(nonnull NSString *)groupId
                 withResolver7:(RCTPromiseResolveBlock)resolve
                 withRejecter7:(RCTPromiseRejectBlock)reject
                 ){
    [[V2TIMManager sharedInstance] getGroupMemberList:groupId filter:V2TIM_GROUP_MEMBER_FILTER_ALL nextSeq:0 succ:^(uint64_t nextSeq, NSArray<V2TIMGroupMemberFullInfo *> *memberList) {
        NSMutableArray *result = [NSMutableArray array];
        for(int i=0;i<memberList.count;i++){
            NSDictionary* map=@{
                @"nickName":memberList[i].nickName,
                @"avatar":memberList[i].faceURL,
                @"userId":memberList[i].userID,
            };
            [result addObject:map];
        }
        resolve(result);
    } fail:^(int code, NSString *desc) {
        reject([NSString stringWithFormat:@"%d",code],desc,nil);
    }];
}

RCT_REMAP_METHOD(quit,
                 quitGroupId:(NSString *)groupId
                 withResolver8:(RCTPromiseResolveBlock)resolve
                 withRejecter8:(RCTPromiseRejectBlock)reject){
    [[V2TIMManager sharedInstance] quitGroup:groupId succ:nil fail:nil];
    [[V2TIMManager sharedInstance] removeSimpleMsgListener:self];
    [[V2TIMManager sharedInstance] logout:^{
        resolve(@"success");
    } fail:^(int code, NSString *desc) {
        reject([NSString stringWithFormat:@"%d",code],desc,nil);
    }];
}



-(void)onRecvC2CTextMessage:(NSString *)msgID sender:(V2TIMUserInfo *)info text:(NSString *)text{
    NSDictionary* data=@{
        @"type":@"text",
        @"avatar":info.faceURL,
        @"nickName":info.nickName,
        @"userId":info.userID,
        @"content":text,
    };
    [self sendEventWithName:@"txim" body:data];

}


-(void)onRecvC2CCustomMessage:(NSString *)msgID sender:(V2TIMUserInfo *)info customData:(NSData *)data{
    NSDictionary* data1=@{
        @"type":@"custom",
        @"avatar":info.faceURL,
        @"nickName":info.nickName,
        @"userId":info.userID,
        @"content":[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding],
    };
    [self sendEventWithName:@"txim" body:data1];
}

-(void)onRecvGroupTextMessage:(NSString *)msgID groupID:(NSString *)groupID sender:(V2TIMGroupMemberInfo *)info text:(NSString *)text{
    NSDictionary* data=@{
        @"type":@"text",
        @"avatar":info.faceURL,
        @"nickName":info.nickName,
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
        @"nickName":info.nickName,
        @"userId":info.userID,
        @"groupId":groupID,
        @"content":[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding],
    };
    [self sendEventWithName:@"txim" body:data1];
}

-(NSArray<NSString*>*)supportedEvents{
    return @[@"txim"];
}


@end
