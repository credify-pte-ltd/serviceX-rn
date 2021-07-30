package com.servicexsdkrn

import one.credify.sdk.core.model.Environment
import java.util.*

object Constants {
    const val MARKET_NAME = "tiki" // Your name
    const val API_KEY = "4nN5UifKTRxR1At4syeBHM6e4p0cFOdoqsuUKOIgSYBEJRa8UpGprqorfyWFgdVk" // Your API key
    val ENVIRONMENT = Environment.SANDBOX // Should not be changed in this example

    val GET_USER_URL: String
        get() {
            return "https://sandbox-demo-api.credify.dev/${MARKET_NAME.toLowerCase(Locale.ENGLISH)}/demo-user"
        }

    val PUSH_CLAIMS_URL: String
        get() {
            return "https://sandbox-demo-api.credify.dev/${MARKET_NAME.toLowerCase(Locale.ENGLISH)}/push-claims"
        }

    const val GET_ACCESS_TOKEN_BY_API_KEY_URL =  "https://sandbox-api.credify.dev/v1/token"
}
