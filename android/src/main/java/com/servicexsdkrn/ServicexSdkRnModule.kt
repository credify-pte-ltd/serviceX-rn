package com.servicexsdkrn

import android.graphics.Color
import one.credify.sdk.core.request.GetOfferListParam
import one.credify.sdk.core.callback.OfferListCallback
import one.credify.sdk.core.model.*
import android.util.Log
import com.facebook.react.bridge.*
import com.facebook.react.modules.core.DeviceEventManagerModule
import one.credify.sdk.core.CredifyError
import com.google.gson.Gson
import one.credify.sdk.*
import javax.annotation.Nullable
import kotlin.collections.ArrayList

class ServicexSdkRnModule(reactContext: ReactApplicationContext) :
  ReactContextBaseJavaModule(reactContext) {

  override fun getName(): String {
    return "ServicexSdkRn"
  }

  private var mCredifyId: String? = null
  private var mUserProfile: UserProfile? = null
  private var mOfferList: OfferList? = null
  private var mPushClaimResultCallback: CredifySDK.PushClaimResultCallback? = null
  private var mMarketName: String? = null

  @ReactMethod
  fun initialize(
    apiKey: String,
    environment: String,
    marketName: String,
    packageVersion: String,
    theme: ReadableMap?
  ) {
    mMarketName = marketName
    val themObj = if (theme == null) null else parseThemeObject(theme)

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

  fun parseFloatValueFromReadableMap(map: ReadableMap, key: String): Float? {
    var result: Float? = null
    try {
      if (map.hasKey(key)) {
        result = map.getDouble(key).toFloat()
      }
    } catch (e: Exception) {

    }

    return result
  }

  fun parseThemeObject(themeObj: ReadableMap): ServiceXThemeConfig {
    val primaryBrandyStart = themeObj.getString("primaryBrandyStart")
    val primaryBrandyEnd = themeObj.getString("primaryBrandyEnd")
    val primaryText = themeObj.getString("primaryText")
    val secondaryActive = themeObj.getString("secondaryActive")
    val secondaryText = themeObj.getString("secondaryText")
    val secondaryComponentBackground = themeObj.getString("secondaryComponentBackground")
    val secondaryBackground = themeObj.getString("secondaryBackground")

    val pageHeaderRadius = parseFloatValueFromReadableMap(themeObj, "pageHeaderRadius")
    val elevation = parseFloatValueFromReadableMap(themeObj, "shadowHeight")
    val inputFieldRadius = parseFloatValueFromReadableMap(themeObj, "inputFieldRadius")
    val buttonRadius = parseFloatValueFromReadableMap(themeObj, "buttonRadius")

    val theme = ServiceXThemeConfig(
      context = this.reactApplicationContext,
      color = ThemeColor(
        primaryBrandyStart = if (primaryBrandyStart != null) Color.parseColor(primaryBrandyStart) else Color.parseColor(
          "#AB2185"
        ),
        primaryBrandyEnd = if (primaryBrandyEnd != null) Color.parseColor(primaryBrandyEnd) else Color.parseColor(
          "#5A24B3"
        ),
        primaryText = if (primaryText != null) Color.parseColor(primaryText) else Color.parseColor(
          "#333333"
        ),
        secondaryActive = if (secondaryActive != null) Color.parseColor(secondaryActive) else Color.parseColor(
          "#9147D7"
        ),
        secondaryText = if (secondaryText != null) Color.parseColor(secondaryText) else Color.parseColor(
          "#999999"
        ),
        secondaryComponentBackground = if (secondaryComponentBackground != null) Color.parseColor(
          secondaryComponentBackground
        ) else Color.parseColor("#F0E9F9"),
        secondaryBackground = if (secondaryBackground != null) Color.parseColor(secondaryBackground) else Color.parseColor(
          "#F6F8FF"
        ),
      ),
      actionBarTopLeftRadius = pageHeaderRadius ?: 0F,
      actionBarBottomLeftRadius = pageHeaderRadius ?: 30F,
      actionBarTopRightRadius = pageHeaderRadius ?: 0F,
      actionBarBottomRightRadius = pageHeaderRadius ?: 30F,
      elevation = elevation ?: 4F,
      inputFieldRadius = inputFieldRadius ?: 5F,
      buttonRadius = buttonRadius ?: 50F,
    )
    return theme

  }


  @ReactMethod
  fun clearCache() {
    CredifySDK.instance.clearCache()
  }

  fun toArrayList(array: ReadableArray): ArrayList<String> {
    val size = array.size()
    val arrayList = ArrayList<String>(size)
    for (i: Int in 0 until size) {
      when (array.getType(i)) {
        ReadableType.String -> array.getString(i)?.let { arrayList.add(it) }
        else -> throw java.lang.Exception("Item in Product types must be a String type")
      }
    }
    return arrayList
  }


  @ReactMethod
  fun getOfferList(productTypes: ReadableArray, promise: Promise) {
    val params = GetOfferListParam(
      phoneNumber = mUserProfile?.phone?.phoneNumber,
      countryCode = mUserProfile?.phone?.countryCode,
      localId = mUserProfile?.id!!,
      credifyId = mCredifyId,
      productTypes = toArrayList(productTypes)
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
      address = null
    )
    mCredifyId = userDict.getString("credify_id")
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

  private fun sendEvent(
    eventName: String,
    @Nullable params: WritableMap
  ) {
    this.reactApplicationContext
      .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter::class.java)
      .emit(eventName, params)
  }

  @ReactMethod
  fun showOfferDetail(offerId: String, pushClaimCB: Callback) {
    val _offer = getOffer(offerId)
    Log.d("CredifySDK", "OFFER ID = " + _offer?.id)
    Log.d("CredifySDK", "mCredifyId = " + mCredifyId)
    Log.d("CredifySDK", "mUserProfile ID = " + mUserProfile?.id?.toString())

    CredifySDK.instance.offerApi.showOffer(
      context = this.currentActivity!!,
      offer = _offer!!,
      userProfile = mUserProfile!!,
      credifyId = mCredifyId,
      marketName = mMarketName,
      pushClaimCallback = object : CredifySDK.PushClaimCallback {
        override fun onPushClaim(
          credifyId: String,
          user: UserProfile,
          resultCallback: CredifySDK.PushClaimResultCallback
        ) {
          mPushClaimResultCallback = resultCallback
          pushClaimCB.invoke(mUserProfile?.id, credifyId)
        }
      },
      offerPageCallback = object : CredifySDK.OfferPageCallback {
        override fun onClose(status: RedemptionResult) {
          Log.d("CredifySDK", "Redemtion Status is " + status.name)
          val params = Arguments.createMap();
          params.putString("status", status.name);
          sendEvent("onRedeemCompleted", params);
        }
      }
    )
  }

  @ReactMethod
  fun showPassport(dismissCB: Callback) {
    CredifySDK.instance.offerApi.showPassport(
      this.currentActivity!!,
      userProfile = mUserProfile!!,
      callback = object : CredifySDK.PassportPageCallback {
        override fun onShow() {

        }

        override fun onClose() {
          dismissCB.invoke()
        }
      })
  }

  @ReactMethod
  fun showReferral() {
    CredifySDK.instance.referralApi.showReferralResult(
      context = this.currentActivity!!,
      userProfile = mUserProfile!!,
      marketName = mMarketName,
      callback = object : CredifySDK.OnShowReferralResultCallback {
        override fun onShow() {
          Log.d("CredifySDK", "Referral page on Show")
        }

        override fun onError(ex: Exception) {
          Log.d("CredifySDK", "Referral page Error" + ex.message)
        }

        override fun onClose() {
          Log.d("CredifySDK", "Referral page is close")
        }
      }
    )
  }
}
