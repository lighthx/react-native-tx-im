package com.reactnativetxim

import androidx.annotation.Nullable
import com.facebook.react.bridge.*
import com.facebook.react.modules.core.DeviceEventManagerModule.RCTDeviceEventEmitter
import com.tencent.imsdk.v2.*


class TxImModule(reactContext: ReactApplicationContext) : ReactContextBaseJavaModule(reactContext) {
  private var _groupId = ""
  private val eventName = "txim"
  private fun sendEvent(
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
        _groupId = groupId
        promise.resolve("success")
      }

      override fun onError(p0: Int, p1: String?) {
        promise.reject(p0.toString(), p1)
      }

    })
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
  fun init(sdkAppID: Int,groupId: String, promise: Promise) {
    val config = V2TIMSDKConfig()

    config.setLogLevel(V2TIMSDKConfig.V2TIM_LOG_INFO)
    V2TIMManager.getInstance().initSDK(reactApplicationContext, sdkAppID, config, object : V2TIMSDKListener() {

      override fun onConnectSuccess() {
        V2TIMManager.getInstance().addSimpleMsgListener(object : V2TIMSimpleMsgListener() {

          override fun onRecvC2CTextMessage(msgID: String?, sender: V2TIMUserInfo?, text: String?) {
            if(text!=null){
              val map = Arguments.createMap()
              map.putString("type", "text")
              map.putString("avatar", sender?.faceUrl)
              map.putString("nickName", sender?.nickName)
              map.putString("userId", sender?.userID)
              map.putString("content", text)
              sendEvent(map)
            }

          }

          override fun onRecvC2CCustomMessage(msgID: String?, sender: V2TIMUserInfo?, customData: ByteArray?) {
              if(customData!=null){
               val json= customData.toString()
                val map = Arguments.createMap()
                map.putString("type", "custom")
                map.putString("avatar", sender?.faceUrl)
                map.putString("nickName", sender?.nickName)
                map.putString("userId", sender?.userID)
                map.putString("content", json)
                sendEvent(map)
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
              sendEvent(map)
            }

          }

          override fun onRecvGroupCustomMessage(msgID: String?, groupID: String?, sender: V2TIMGroupMemberInfo?, customData: ByteArray?) {
            if(customData!=null){
              val json= customData.toString()
              val map = Arguments.createMap()
              map.putString("type", "custom")
              map.putString("avatar", sender?.faceUrl)
              map.putString("groupId",groupId)
              map.putString("nickName", sender?.nickName)
              map.putString("userId", sender?.userID)
              map.putString("content", json)
              sendEvent(map)
            }
          }
        })
        promise.resolve("success")
        // 已经成功连接到腾讯云服务器
      }

      override fun onConnectFailed(code: Int, error: String) {
        promise.reject(code.toString(), error)
        // 连接腾讯云服务器失败
      }
    })
  }

  @ReactMethod
  fun sendTextMessage(message: String,userId: String, promise: Promise) {
    val msg = V2TIMManager.getMessageManager().createTextMessage(message)
    V2TIMManager.getMessageManager().sendMessage(msg, userId, null, 1, true, null, object : V2TIMSendCallback<V2TIMMessage> {
      override fun onSuccess(p0: V2TIMMessage?) {
        promise.resolve("success")
      }

      override fun onError(p0: Int, p1: String?) {
        promise.reject(p0.toString(), p1)
      }

      override fun onProgress(p0: Int) {
        TODO("Not yet implemented")
      }
    });
  }

  @ReactMethod
  fun sendGroupTextMessage(message: String,groupId: String, promise: Promise) {
    val msg = V2TIMManager.getMessageManager().createTextMessage(message)
    V2TIMManager.getMessageManager().sendMessage(msg, null, groupId, 1, true, null, object : V2TIMSendCallback<V2TIMMessage> {
      override fun onSuccess(p0: V2TIMMessage?) {
        promise.resolve("success")
      }

      override fun onError(p0: Int, p1: String?) {
        promise.reject(p0.toString(), p1)
      }

      override fun onProgress(p0: Int) {
        TODO("Not yet implemented")
      }
    });
  }

  @ReactMethod
  fun sendCustomMessage(type: String,message:String,userId:String, promise: Promise) {

    val json = String.format("{\"type\":%s,\"message\":%s}", type, message)
    val data = json.toByteArray()
    val msg = V2TIMManager.getMessageManager().createCustomMessage(data);
    V2TIMManager.getMessageManager().sendMessage(msg, userId, null, 1, true, null, object : V2TIMSendCallback<V2TIMMessage> {
      override fun onSuccess(p0: V2TIMMessage?) {
        promise.resolve("success")
      }

      override fun onError(p0: Int, p1: String?) {
        promise.reject(p0.toString(), p1)
      }

      override fun onProgress(p0: Int) {
        TODO("Not yet implemented")
      }
    });
  }

  @ReactMethod
  fun sendGroupCustomMessage(type: String,message:String,groupId: String, promise: Promise) {

    val json = String.format("{\"type\":%s,\"message\":%s}", type, message)
    val data = json.toByteArray()
    val msg = V2TIMManager.getMessageManager().createCustomMessage(data);
    V2TIMManager.getMessageManager().sendMessage(msg, null, groupId, 1, true, null, object : V2TIMSendCallback<V2TIMMessage> {
      override fun onSuccess(p0: V2TIMMessage?) {
        promise.resolve("success")
      }

      override fun onError(p0: Int, p1: String?) {
        promise.reject(p0.toString(), p1)
      }

      override fun onProgress(p0: Int) {
        TODO("Not yet implemented")
      }
    });
  }

  @ReactMethod
  fun quit(){
    V2TIMManager.getInstance().removeSimpleMsgListener(null)
    V2TIMManager.getInstance().logout(null)

  }

}

