package com.example059;

import android.widget.Toast;
import com.facebook.react.bridge.NativeModule;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import java.util.Map;
import java.util.HashMap;
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
import com.facebook.react.bridge.Callback;
import com.google.gson.annotations.SerializedName
import org.json.JSONObject

class CredifySdkModule(reactContext: ReactApplicationContext) : ReactContextBaseJavaModule(reactContext) {

    private var mMarketAccessToken: String? = null

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

        getMarketAccessTokenByApiKey(Constants.API_KEY) { isSuccess ->

        }
    }

    /**
     * Get access token by API key. After getting access token successfully, you can using
     * the [pushClaim] method for pushing claims.
     *
     * When you integrate with Credify you will receive a API from Credify
     */
    private fun getMarketAccessTokenByApiKey(
            apiKey: String,
            callback: (isSuccess: Boolean) -> Unit
    ) {
        // Instantiate the RequestQueue.
        val queue = newRequestQueue(this.reactApplicationContext)

        // Request a string response from the provided URL.
        val stringRequest = object : StringRequest(
                Method.POST,
                Constants.GET_ACCESS_TOKEN_BY_API_KEY_URL,
                { response ->
                    // Display the first 500 characters of the response string.
                    val gson = Gson()
                    val accessToken = gson.fromJson(response, AccessTokenResponse::class.java)

                    mMarketAccessToken = accessToken.data?.accessToken
                    Toast.makeText(this.reactApplicationContext, "AccessToken Get successfully",Toast.LENGTH_SHORT).show()
                    callback(true)
                },
                {
                    // Error
                    Log.d("OfferExampleActivity", "$it")
                    callback(false)
                }
        ) {
            override fun getHeaders(): MutableMap<String, String> {
                return HashMap<String, String>().apply {
                    put("X-API-KEY", apiKey)
                }
            }
        }
        queue.add(stringRequest)
    }

    override fun getName() = "CredifySdk"
    var offer: Offer? = null

    @ReactMethod
    fun getOfferList(message: String, successCallback: Callback,
                     errorCallback: Callback) {
        val params = GetOfferListParam(
                phoneNumber = "707245595",
                countryCode = "+84",
                localId = "1",
                credifyId = ""
        )

        CredifySDK.instance.getOfferList(
                params = params,
                callback = object : OfferListCallback {
                    override fun onSuccess(model: OfferList) {
                        Log.d(
                                "MainActivity",
                                "Offer size : ${model.offerList.size}, credifyId: ${model.credifyId}"
                        )
                        // Cached credify id. If it is null that means the user does not have
                        // credify account yet

                        offer = model.offerList.get(0)
                        val gson = Gson()
                        val json = gson.toJson(model)
                        Log.d("CredifySDK", json)
                        successCallback.invoke(json)
                    }

                    override fun onError(throwable: CredifyError) {
                        Log.d("CredifySDK", "Error: ${throwable.throwable}")
                        errorCallback.invoke(throwable.throwable?.message);
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
    fun showOfferDetail(message: String) {

        val mUserProfile = UserProfile(
                id = "1",
                name = Name(
                        firstName = "Garnet",
                        lastName = "Mertz",
                        middleName = null,
                        name = null,
                        verified = true
                ),
                phone = Phone(
                        phoneNumber = "707245595",
                        countryCode = "+84",
                        verified = true
                ),
                email = "Myrl17@yahoo.com",
                dob = null,
                address = null
        )

        CredifySDK.instance.showOffer(
                context = this.currentActivity!!,
                offer = offer!!,
                userProfile = mUserProfile,
                credifyId = "",
                marketName = Constants.MARKET_NAME,
                pushClaimCallback = object : CredifySDK.PushClaimCallback {
                    override fun onPushClaim(
                            credifyId: String,
                            user: UserProfile,
                            resultCallback: CredifySDK.PushClaimResultCallback
                    ) {
                        pushClaim(
                                localId = user.id,
                                credifyId = credifyId,
                                marketAccessToken = mMarketAccessToken ?: ""
                        ) { isSuccess ->
                            resultCallback.onPushClaimResult(isSuccess = isSuccess)
                        }
                    }
                },
                offerPageCallback = object : CredifySDK.OfferPageCallback {
                    override fun onClose() {
                        Log.d("CredifySDK", "Offer page is close")
                    }
                }
        )
    }
}