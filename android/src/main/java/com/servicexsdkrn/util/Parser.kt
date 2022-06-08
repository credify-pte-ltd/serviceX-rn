package com.servicexsdkrn.util

import com.facebook.react.bridge.ReadableArray
import com.facebook.react.bridge.ReadableMap
import com.facebook.react.bridge.ReadableType
import one.credify.sdk.ServiceXThemeConfig
import one.credify.sdk.ThemeColor

object Parser {
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
    return ServiceXThemeConfig(
      color = ThemeColor(
        primaryBrandyStart = themeObj.getString("primaryBrandyStart") ?: "#AB2185",
        primaryBrandyEnd = themeObj.getString("primaryBrandyEnd") ?: "#5A24B3",
        primaryText = themeObj.getString("primaryText") ?: "#333333",
        secondaryActive = themeObj.getString("secondaryActive") ?: "#9147D7",
        secondaryText = themeObj.getString("secondaryText") ?: "#999999",
        secondaryComponentBackground = themeObj.getString("secondaryComponentBackground")
          ?: "#F0E9F9",
        secondaryBackground = themeObj.getString("secondaryBackground") ?: "#F6F8FF",
      ),
      pageHeaderRadius = parseFloatValueFromReadableMap(themeObj, "pageHeaderRadius") ?: 0F,
      inputFieldRadius = parseFloatValueFromReadableMap(themeObj, "inputFieldRadius") ?: 5F,
      buttonRadius = parseFloatValueFromReadableMap(themeObj, "buttonRadius") ?: 50F,
    )
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
}
