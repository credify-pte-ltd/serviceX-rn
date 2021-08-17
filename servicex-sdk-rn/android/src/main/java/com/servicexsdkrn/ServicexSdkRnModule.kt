package com.servicexsdkrn

import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import one.credify.sdk.CredifySDK
import one.credify.sdk.core.request.GetOfferListParam
import one.credify.sdk.core.callback.OfferListCallback
import one.credify.sdk.core.model.*
import android.util.Log
import one.credify.sdk.core.CredifyError
import com.google.gson.Gson
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReadableMap
import com.facebook.react.bridge.Callback;

class ServicexSdkRnModule(reactContext: ReactApplicationContext) : ReactContextBaseJavaModule(reactContext) {

  override fun getName(): String {
    return "ServicexSdkRn"
  }

  private var mCredifyId: String? = null
  private var mUserProfile: UserProfile? = null
  private var mOfferList: OfferList? = null
  private var mPushClaimResultCallback: CredifySDK.PushClaimResultCallback? = null
  private var mMarketName: String? = null

  @ReactMethod
  fun initialize(apiKey: String, environment: String, marketName: String) {
    mMarketName = marketName
    CredifySDK.Builder()
      .withApiKey(apiKey)
      .withContext(this.reactApplicationContext)
      .withEnvironment(Environment.valueOf(environment))
      .build();
  }

  @ReactMethod
  fun clearCache() {
    CredifySDK.instance.clearCache()
  }

  @ReactMethod
  fun getOfferList(promise: Promise) {
    val params = GetOfferListParam(
      phoneNumber = mUserProfile?.phone?.phoneNumber,
      countryCode = mUserProfile?.phone?.countryCode,
      localId = mUserProfile?.id!!,
      credifyId = mCredifyId
    )

    CredifySDK.instance.getOfferList(
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
          promise.reject(throwable.throwable?.message);
        }
      }
    )
  }

  @ReactMethod
  fun setUserProfile(userDict: ReadableMap) {
    mUserProfile = UserProfile(
      id = userDict.getInt("id")!!.toString(),
      name = UserName(
        firstName = userDict.getString("first_name")!!,
        lastName = userDict.getString("last_name")!!,
        middleName = userDict.getString("middle_name"),
        fullName = userDict.getString("full_name"),
      ),
      phone = UserPhoneNumber(
        phoneNumber = userDict.getString("phone_number")!!,
        countryCode = userDict.getString("country_code")!!,
      ),
      email = userDict.getString("email")!!,
      dob = null,
      address = null
    )
    mCredifyId = userDict.getString("credify_id")
  }


  @ReactMethod
  fun setCredifyId(credifyId: String) {
    mCredifyId = credifyId
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
  fun showOfferDetail(offerId: String, pushClaimCB: Callback) {
    val _offer = getOffer(offerId)
    Log.d("CredifySDK", "OFFER ID = " + _offer?.id)
    Log.d("CredifySDK", "mCredifyId = " + mCredifyId)
    Log.d("CredifySDK", "mUserProfile ID = " + mUserProfile?.id?.toString())

    CredifySDK.instance.showOffer(
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
        override fun onClose() {
          Log.d("CredifySDK", "Offer page is close")
        }
      }
    )
  }

  @ReactMethod
  fun showReferral() {
    CredifySDK.instance.showReferralResult(
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
