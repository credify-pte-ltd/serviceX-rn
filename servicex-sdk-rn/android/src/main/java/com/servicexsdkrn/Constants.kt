package com.servicexsdkrn

import one.credify.sdk.core.model.Environment
import java.util.*

object Constants {
    const val MARKET_NAME = "Sendo" // Your name
    const val API_KEY = "WaXSjOqK0JqSOH1VJ6Op1kkQTdPAhffv5bflck7SzwRjCK0MqUmjSHyvfAan3djf" // Your API key
    val ENVIRONMENT = Environment.UAT // Should not be changed in this example

    val GET_USER_URL: String
        get() {
            return "https://uat-demo-api.credify.dev/${MARKET_NAME.toLowerCase(Locale.ENGLISH)}/demo-user"
        }

    val PUSH_CLAIMS_URL: String
        get() {
            return "https://uat-demo-api.credify.dev/${MARKET_NAME.toLowerCase(Locale.ENGLISH)}/push-claims"
        }

    const val GET_ACCESS_TOKEN_BY_API_KEY_URL =  "https://uat-api.credify.dev/v1/token"
}