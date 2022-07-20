package com.servicexsdkrn

import one.credify.sdk.core.request.GetOfferListParam
import one.credify.sdk.core.callback.OfferListCallback
import one.credify.sdk.core.model.*
import android.util.Log
import com.facebook.react.bridge.*
import com.facebook.react.modules.core.DeviceEventManagerModule
import com.google.gson.Gson
import com.servicexsdkrn.util.Parser
import one.credify.sdk.*
import java.lang.Exception
import kotlin.collections.ArrayList

class ServicexSdkRnModule(reactContext: ReactApplicationContext) :
  ReactContextBaseJavaModule(reactContext) {

  override fun getName(): String {
    return "ServicexSdkRn"
  }

  private var mUserProfile: UserProfile? = null
  private var mOfferList: OfferList? = null
  private var mPushClaimResultCallback: CredifySDK.PushClaimResultCallback? = null
  private var mMarketName: String? = null

  private val mNativeEvent = "nativeEvent"

  enum class EventType(val rawValue: String) {
    COMPLETION("completion"),
    REDEEM_COMPLETED("redeemCompleted"),
    PUSH_CLAIM_TOKEN("pushClaimToken"),
  }

  private fun sendEvent(payload: WritableMap?) {
    this.reactApplicationContext
      .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter::class.java)
      .emit(mNativeEvent, payload)
  }

  private fun createEventPayload(type: String, payload: WritableMap?): WritableMap {
    val newPayload = Arguments.createMap().apply {
      putString("type", type)
      payload?.let {
        putMap("payload", it)
      }
    }
    return newPayload
  }

  private fun sendPushClaimTokenEvent(localId: String, credifyId: String) {
    val payload = createEventPayload(
      type = EventType.PUSH_CLAIM_TOKEN.rawValue,
      payload = Arguments.createMap().apply {
        putString("localId", localId)
        putString("credifyId", credifyId)
      }
    )
    sendEvent(payload = payload)
  }

  private fun sendRedeemedOfferEvent(status: RedemptionResult) {
    val payload = createEventPayload(
      type = EventType.REDEEM_COMPLETED.rawValue,
      payload = Arguments.createMap().apply {
        putString("status", status.name)
      }
    )
    sendEvent(payload = payload)
  }

  private fun sendCompletionEvent() {
    val payload = createEventPayload(type = EventType.COMPLETION.rawValue, payload = null)
    sendEvent(payload = payload)
  }

  @ReactMethod
  fun initialize(
    apiKey: String,
    environment: String,
    marketName: String,
    packageVersion: String,
    theme: ReadableMap?
  ) {
    mMarketName = marketName
    val themObj = if (theme == null) null else Parser.parseThemeObject(theme)

    CredifySDK.Builder().apply {
      withApiKey(apiKey)
      withContext(reactApplicationContext)
      withEnvironment(Environment.valueOf(environment))
      if (themObj != null) {
        withTheme(themObj)
      }
      withVersion("servicex/rn/android/$packageVersion")
    }.build();

  }

  @ReactMethod
  fun getOfferList(productTypes: ReadableArray, promise: Promise) {
    val params = GetOfferListParam(
      phoneNumber = mUserProfile?.phone?.phoneNumber,
      countryCode = mUserProfile?.phone?.countryCode,
      localId = mUserProfile?.id!!,
      credifyId = mUserProfile?.credifyId,
      productTypes = Parser.toArrayList(productTypes)
    )

    CredifySDK.instance.offerApi.getOfferList(
      params = params,
      callback = object : OfferListCallback {
        override fun onSuccess(model: OfferList) {
          Log.d(
            "CredifySDK",
            "Offer size : ${model.offerList.size}, credifyId: ${model.credifyId}"
          )
          // Cached credify id. If it is null that means the user does not have
          // credify account yet
          mOfferList = model
          val gson = Gson()
          val json = gson.toJson(model)
          promise.resolve(json);
        }

        override fun onError(throwable: CredifyError) {
          Log.d("CredifySDK", "Error: ${throwable.throwable}")
          promise.reject(throwable.throwable);
        }
      }
    )
  }

  @ReactMethod
  fun setUserProfile(userDict: ReadableMap) {
    mUserProfile = UserProfile(
      id = userDict.getInt("id").toString(),
      name = UserName(
        firstName = userDict.getString("first_name") ?: "",
        lastName = userDict.getString("last_name") ?: "",
        middleName = userDict.getString("middle_name"),
        fullName = userDict.getString("full_name"),
      ),
      phone = UserPhoneNumber(
        phoneNumber = userDict.getString("phone_number")!!,
        countryCode = userDict.getString("country_code")!!,
      ),
      email = userDict.getString("email") ?: "",
      dob = null,
      address = null,
      credifyId = userDict.getString("credify_id"),
    )
  }

  @ReactMethod
  fun setPushClaimRequestStatus(isSuccess: Boolean) {
    mPushClaimResultCallback?.onPushClaimResult(isSuccess == isSuccess)
    // Dereference the callback to avoid memory leak
    mPushClaimResultCallback = null
  }

  private fun getOffer(id: String): Offer? {
    return mOfferList?.offerList?.single { it.id == id }
  }

  @ReactMethod
  fun showOfferDetail(offerId: String) {
    val context = currentActivity ?: return
    val offer = getOffer(offerId) ?: return
    val userProfile = mUserProfile ?: return
    Log.d("CredifySDK", "OFFER ID = " + offer.id)
    Log.d("CredifySDK", "mCredifyId = " + mUserProfile?.credifyId)
    Log.d("CredifySDK", "mUserProfile ID = " + mUserProfile?.id)

    CredifySDK.instance.offerApi.showOffer(
      context = context,
      offer = offer,
      userProfile = userProfile,
      pushClaimCallback = object : CredifySDK.PushClaimCallback {
        override fun onPushClaim(
          credifyId: String,
          resultCallback: CredifySDK.PushClaimResultCallback
        ) {
          mPushClaimResultCallback = resultCallback
          sendPushClaimTokenEvent(localId = userProfile.id, credifyId = credifyId)
        }
      },
      offerPageCallback = object : CredifySDK.OfferPageCallback {
        override fun onClose(status: RedemptionResult) {
          Log.d("CredifySDK", "Redemption Status is " + status.name)
          sendRedeemedOfferEvent(status = status)
          sendCompletionEvent()
        }

        override fun onOpenUrl(url: String) {

        }
      }
    )
  }

  @ReactMethod
  fun showPromotionOffers() {
    val context = currentActivity ?: return
    val offers = mOfferList?.offerList ?: return
    val userProfile = mUserProfile ?: return

    if (offers.isEmpty())
      return

    currentActivity?.runOnUiThread {
      CredifySDK.instance.offerApi.showPromotionOffers(
        context = context,
        offers = offers,
        userProfile = userProfile,
        pushClaimCallback = object : CredifySDK.PushClaimCallback {
          override fun onPushClaim(
            credifyId: String,
            resultCallback: CredifySDK.PushClaimResultCallback
          ) {
            mPushClaimResultCallback = resultCallback
            sendPushClaimTokenEvent(localId = userProfile.id, credifyId = credifyId)
          }
        },
        offerPageCallback = object : CredifySDK.OfferPageCallback {
          override fun onClose(status: RedemptionResult) {
            Log.d("CredifySDK", "Redemption Status is " + status.name)
            sendRedeemedOfferEvent(status = status)
            sendCompletionEvent()
          }

          override fun onOpenUrl(url: String) {

          }
        }
      )
    }
  }

  @ReactMethod
  fun showPassport() {
    val context = currentActivity ?: return
    val userProfile = mUserProfile ?: return

    CredifySDK.instance.passportApi.showPassport(
      context = context,
      userProfile = userProfile,
      pushClaimCallback = object : CredifySDK.PushClaimCallback {
        override fun onPushClaim(
          credifyId: String,
          resultCallback: CredifySDK.PushClaimResultCallback
        ) {
          mPushClaimResultCallback = resultCallback
          sendPushClaimTokenEvent(userProfile.id, credifyId)
        }
      },
      callback = object : CredifySDK.PassportPageCallback {
        override fun onShow() {

        }

        override fun onClose() {
          sendCompletionEvent()
        }
      }
    )
  }

  @ReactMethod
  fun showServiceInstance(marketId: String, productTypes: ReadableArray) {
    val context = currentActivity ?: return
    val userProfile = mUserProfile ?: return

    val types = ArrayList<ProductType>()
    Parser.toArrayList(productTypes).forEach { strValue ->
      ProductType.values().find { it.value == strValue }?.run {
        types.add(this)
      }
    }

    CredifySDK.instance.passportApi.showServiceInstance(
      context = context,
      userProfile = userProfile,
      marketId = marketId,
      productTypeList = types,
      callback = object : CredifySDK.PassportPageCallback {
        override fun onShow() {

        }

        override fun onClose() {
          sendCompletionEvent()
        }
      }
    )
  }
}
