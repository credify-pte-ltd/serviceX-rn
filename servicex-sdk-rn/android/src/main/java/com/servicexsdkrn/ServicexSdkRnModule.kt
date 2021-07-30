package com.servicexsdkrn

import android.widget.Toast
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import java.util.HashMap
import one.credify.sdk.CredifySDK
import one.credify.sdk.core.request.GetOfferListParam
import one.credify.sdk.core.callback.OfferListCallback
import one.credify.sdk.core.model.*
import android.util.Log
import com.android.volley.Request
import com.android.volley.toolbox.JsonObjectRequest
import com.android.volley.toolbox.StringRequest
import com.android.volley.toolbox.Volley.newRequestQueue
import one.credify.sdk.core.CredifyError
import com.google.gson.Gson
import com.google.gson.annotations.SerializedName
import org.json.JSONObject
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReadableMap
import com.facebook.react.bridge.Callback;

class ServicexSdkRnModule(reactContext: ReactApplicationContext) : ReactContextBaseJavaModule(reactContext) {

  override fun getName(): String {
    return "ServicexSdkRn"
  }

  private var mMarketAccessToken: String? = null
  private var mCredifyId: String? = null
  private var mUserProfile: UserProfile? = null
  private var mOfferList: OfferList? = null

  class AccessToken {
    @SerializedName("access_token")
    lateinit var accessToken: String
  }

  class AccessTokenResponse : BaseResponse<AccessToken>()

  open class BaseResponse<T> {
    @SerializedName("is_success")
    var isSuccess: Boolean = false

    @SerializedName("data")
    var data: T? = null
  }

  init {
    CredifySDK.Builder()
      .withApiKey(Constants.API_KEY)
      .withContext(reactContext)
      .withEnvironment(Constants.ENVIRONMENT)
      .build();
  }

  @ReactMethod
  fun getOfferList(userDict: ReadableMap, promise: Promise) {

    val params = GetOfferListParam(
      phoneNumber = userDict.getString("phone_number"),
      countryCode = userDict.getString("country_code"),
      localId = userDict.getInt("local_id")!!.toString(),
      credifyId = userDict.getString("credify_id")
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

  /**
   * This method will call to server for pushing claims
   */
  private fun pushClaim(
    localId: String,
    credifyId: String,
    marketAccessToken: String,
    callback: (isSuccess: Boolean) -> Unit
  ) {
    // Instantiate the RequestQueue.
    val queue = newRequestQueue(reactApplicationContext)

    // Request a string response from the provided URL.
    val stringRequest = object : JsonObjectRequest(
      Request.Method.POST,
      Constants.PUSH_CLAIMS_URL,
      JSONObject().apply {
        put("id", localId)
        put("credify_id", credifyId)
      },
      { _ ->
        callback(true)
      },
      {
        // Error
        Log.d("OfferExampleActivity", "${it}")
        callback(false)
      }
    ) {
      override fun getHeaders(): MutableMap<String, String> {
        return HashMap<String, String>().apply {
          put("Authorization", marketAccessToken)
        }
      }
    }
    queue.add(stringRequest)
  }

  @ReactMethod
  fun setUserProfile(userDict: ReadableMap) {
    mUserProfile = UserProfile(
      id = userDict.getInt("id")!!.toString(),
      name = Name(
        firstName = userDict.getString("first_name")!!,
        lastName = userDict.getString("last_name")!!,
        middleName = userDict.getString("middle_name"),
        name = userDict.getString("name"),
        verified = true
      ),
      phone = Phone(
        phoneNumber = userDict.getString("phone_number")!!,
        countryCode = userDict.getString("country_code")!!,
        verified = true
      ),
      email = userDict.getString("email")!!,
      dob = null,
      address = null
    )

    Log.d("CredifySDK", "SET PROFILE OKAY")
  }


  @ReactMethod
  fun setCredifyId(credifyId: String) {
    mCredifyId = credifyId
    Log.d("CredifySDK", "SET CredifyId OKAY")
  }


  var mPushClaimResultCallback: CredifySDK.PushClaimResultCallback? = null

  fun setPushClaimResultCB(resultCallback: CredifySDK.PushClaimResultCallback) {
    mPushClaimResultCallback = resultCallback
  }

  @ReactMethod
  fun setPushClaimRequestStatus(isSuccess: Boolean) {
    mPushClaimResultCallback?.onPushClaimResult(isSuccess == isSuccess)
  }

  private fun getOffer(id: String): Offer? {
    return mOfferList?.offerList?.single { it.id == id }
  }


  @ReactMethod
  fun showOfferDetail(offerId: String, pushClaimCB: Callback) {
    val _offer = getOffer(offerId)
    Log.d("CredifySDK", "OFFER ID = " + _offer?.id)
    Log.d("CredifySDK", "mCredifyId = " + mCredifyId)

    CredifySDK.instance.showOffer(
      context = this.currentActivity!!,
      offer = _offer!!,
      userProfile = mUserProfile!!,
      credifyId = mCredifyId,
      marketName = Constants.MARKET_NAME,
      pushClaimCallback = object : CredifySDK.PushClaimCallback {
        override fun onPushClaim(
          credifyId: String,
          user: UserProfile,
          resultCallback: CredifySDK.PushClaimResultCallback
        ) {
//          pushClaim(
//            localId = mUserProfile?.id!!,
//            credifyId = credifyId,
//            marketAccessToken = mMarketAccessToken ?: ""
//          ) { isSuccess ->
//            resultCallback.onPushClaimResult(isSuccess = isSuccess)
//          }
          setPushClaimResultCB(resultCallback)
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
      marketName = Constants.MARKET_NAME,
      callback = object : CredifySDK.OnShowReferralResultCallback {
        override fun onShow() {
        }

        override fun onError(ex: Exception) {
        }

        override fun onClose() {
        }
      }
    )
  }
}
