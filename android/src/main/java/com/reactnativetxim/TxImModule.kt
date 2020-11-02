package com.reactnativetxim

import androidx.annotation.Nullable
import com.facebook.react.bridge.*
import com.facebook.react.modules.core.DeviceEventManagerModule.RCTDeviceEventEmitter
import com.tencent.imsdk.v2.*


class TxImModule(reactContext: ReactApplicationContext) : ReactContextBaseJavaModule(reactContext) {
  private val eventName = "txim"
  private val listener:WrapListener= WrapListener(this)
  public fun sendEvent(
    @Nullable params: WritableMap) {
    reactApplicationContext
      .getJSModule(RCTDeviceEventEmitter::class.java)
      .emit(eventName, params)
  }


  override fun getName(): String {
    return "TxIm"
  }

  @ReactMethod
  fun joinGroup(groupId:String,promise: Promise){
    V2TIMManager.getInstance().joinGroup(groupId, "", object : V2TIMCallback {
      override fun onSuccess() {

        promise.resolve("success")
      }

      override fun onError(p0: Int, p1: String?) {
        promise.reject(p0.toString(), p1)
      }

    })
  }
  @ReactMethod
  fun getGroupMembers(groupId: String,promise: Promise){
    V2TIMManager.getGroupManager().getGroupMemberList(
      groupId,
      V2TIMGroupMemberFullInfo.V2TIM_GROUP_MEMBER_FILTER_ALL,
      0,
      object :V2TIMValueCallback<V2TIMGroupMemberInfoResult>{
        @Suppress("UNREACHABLE_CODE")
        override fun onSuccess(p0: V2TIMGroupMemberInfoResult?) {
          TODO("not implemented") //To change body of created functions use File | Settings | File Templates.
          val result=Arguments.createArray();

            p0?.memberInfoList?.forEach{
              val map=Arguments.createMap();
              map.putString("nickName",it.nickName)
              map.putString("userId",it.userID)
              map.putString("avatar",it.faceUrl)
              result.pushMap(map)
            }


          promise.resolve(result)
        }

        override fun onError(code: Int, message: String?) {
          promise.reject(code.toString(), message)
        }
      }
    )
  }

  @ReactMethod
  fun login(userSig: String,userId:String,nickName:String,avatar: String,promise: Promise){
    V2TIMManager.getInstance().login(userId, userSig, object : V2TIMCallback {
      override fun onError(code: Int, message: String?) {
        promise.reject(code.toString(), message)
      }

      override fun onSuccess() {
        val info = V2TIMUserFullInfo()
        info.setNickname(nickName)
        info.faceUrl = avatar
        V2TIMManager.getInstance().setSelfInfo(info, object : V2TIMCallback {
          override fun onSuccess() {
            V2TIMManager.getInstance().addSimpleMsgListener(listener)
            promise.resolve("success")

          }

          override fun onError(code: Int, message: String?) {
            promise.reject(code.toString(), message)
          }

        })

      }
    })
  }


  @ReactMethod
  fun init(sdkAppID: Int, promise: Promise) {
    val config = V2TIMSDKConfig()

    config.setLogLevel(V2TIMSDKConfig.V2TIM_LOG_INFO)
    val result= V2TIMManager.getInstance().initSDK(reactApplicationContext, sdkAppID, config, null)
    if(result){
      promise.resolve("success")
    }else{
      promise.reject("failed","failed")
    }
  }

  @ReactMethod
  fun sendTextMessage(message: String,userId: String, promise: Promise) {
    V2TIMManager.getInstance().sendC2CTextMessage(message,userId,object :V2TIMValueCallback<V2TIMMessage> {
      override fun onSuccess(p0: V2TIMMessage?) {
        promise.resolve("success")
      }

      override fun onError(p0: Int, p1: String?) {
        promise.reject(p0.toString(), p1)
      }
    })
  }

  @ReactMethod
  fun sendGroupTextMessage(message: String,groupId: String, promise: Promise) {
    V2TIMManager.getInstance().sendGroupTextMessage(message,groupId,0,object :V2TIMValueCallback<V2TIMMessage>{
      override fun onSuccess(p0: V2TIMMessage?) {
        promise.resolve("success")
      }

      override fun onError(p0: Int, p1: String?) {
        promise.reject(p0.toString(), p1)
      }
    })
  }

  @ReactMethod
  fun sendCustomMessage(type: String,message:String,userId:String, promise: Promise) {
    val json = String.format("{\"type\":%s,\"message\":%s}", type, message)
    val data = json.toByteArray()
    V2TIMManager.getInstance().sendC2CCustomMessage(data,userId,object :V2TIMValueCallback<V2TIMMessage>{
      override fun onSuccess(p0: V2TIMMessage?) {
        promise.resolve("success")
      }

      override fun onError(p0: Int, p1: String?) {
        promise.reject(p0.toString(), p1)
      }
    })
  }

  @ReactMethod
  fun sendGroupCustomMessage(type: String,message:String,groupId: String, promise: Promise) {
    val json = String.format("{\"type\":%s,\"message\":%s}", type, message)
    val data = json.toByteArray()
    V2TIMManager.getInstance().sendGroupCustomMessage(data,groupId,1,object:V2TIMValueCallback<V2TIMMessage>{
      override fun onSuccess(p0: V2TIMMessage?) {
        promise.resolve("success")
      }

      override fun onError(p0: Int, p1: String?) {
        promise.reject(p0.toString(), p1)
      }
    })
  }

  @ReactMethod
  fun quit(promise: Promise){
    V2TIMManager.getInstance().removeSimpleMsgListener(listener);
    V2TIMManager.getInstance().logout(object :V2TIMCallback{
      override fun onSuccess() {
        promise.resolve("success")
      }

      override fun onError(p0: Int, p1: String?) {
        promise.reject(p0.toString(), p1)
      }
    })

  }

}

public class WrapListener( mo : TxImModule): V2TIMSimpleMsgListener() {
  val txim:TxImModule=mo;
  override fun onRecvC2CTextMessage(msgID: String?, sender: V2TIMUserInfo?, text: String?) {
    if(text!=null){
      val map = Arguments.createMap()
      map.putString("type", "text")
      map.putString("avatar", sender?.faceUrl)
      map.putString("nickName", sender?.nickName)
      map.putString("userId", sender?.userID)
      map.putString("content", text)
      txim.sendEvent(map)
    }

  }

  @ExperimentalStdlibApi
  override fun onRecvC2CCustomMessage(msgID: String?, sender: V2TIMUserInfo?, customData: ByteArray?) {
    if(customData!=null){
      val json= customData.decodeToString();
      val map = Arguments.createMap()
      map.putString("type", "custom")
      map.putString("avatar", sender?.faceUrl)
      map.putString("nickName", sender?.nickName)
      map.putString("userId", sender?.userID)
      map.putString("content", json)
      txim.sendEvent(map)
    }

  }

  override fun onRecvGroupTextMessage(msgID: String?, groupID: String?, sender: V2TIMGroupMemberInfo?, text: String?) {
    if(text!=null){
      val map = Arguments.createMap()
      map.putString("type", "text")
      map.putString("groupId",groupID)
      map.putString("avatar", sender?.faceUrl)
      map.putString("nickName", sender?.nickName)
      map.putString("userId", sender?.userID)
      map.putString("content", text)
      txim.sendEvent(map)
    }

  }

  @ExperimentalStdlibApi
  override fun onRecvGroupCustomMessage(msgID: String?, groupID: String?, sender: V2TIMGroupMemberInfo?, customData: ByteArray?) {
    if(customData!=null){
      val json= customData.decodeToString();
      val map = Arguments.createMap()
      map.putString("type", "custom")
      map.putString("avatar", sender?.faceUrl)
      map.putString("groupId",groupID)
      map.putString("nickName", sender?.nickName)
      map.putString("userId", sender?.userID)
      map.putString("content", json)
      txim.sendEvent(map)
    }
  }
}
