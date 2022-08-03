package com.servicexsdkrn.util

import com.facebook.react.bridge.ReadableArray
import com.facebook.react.bridge.ReadableMap
import com.facebook.react.bridge.ReadableType
import one.credify.sdk.ServiceXThemeConfig
import one.credify.sdk.ThemeColor
import one.credify.sdk.ThemeFont

object Parser {
  fun parseFloatValueFromReadableMap(map: ReadableMap?, key: String): Float? {
    if (map == null)
      return null

    var result: Float? = null
    try {
      if (map.hasKey(key)) {
        result = map.getDouble(key).toFloat()
      }
    } catch (e: Exception) {

    }

    return result
  }

  fun parseIntValueFromReadableMap(map: ReadableMap?, key: String): Int? {
    if (map == null)
      return null

    var result: Int? = null
    try {
      if (map.hasKey(key)) {
        result = map.getInt(key)
      }
    } catch (e: Exception) {

    }

    return result
  }

  fun parseThemeObject(themeObj: ReadableMap): ServiceXThemeConfig {
    val color = themeObj.getMap("color")
    val font = themeObj.getMap("font")
    
    return ServiceXThemeConfig(
      color = ThemeColor(
        primaryBrandyStart = color?.getString("primaryBrandyStart") ?: "#AB2185",
        primaryBrandyEnd = color?.getString("primaryBrandyEnd") ?: "#5A24B3",
        primaryButtonBrandyStart = color?.getString("primaryButtonBrandyStart") ?: "#AB2185",
        topBarTextColor = color?.getString("topBarTextColor") ?: "#FFFFFF",
        primaryButtonBrandyEnd = color?.getString("primaryButtonBrandyEnd") ?: "#5A24B3",
        primaryButtonTextColor = color?.getString("primaryButtonTextColor") ?: "#5A24B3",
        primaryText = color?.getString("primaryText") ?: "#333333",
        secondaryActive = color?.getString("secondaryActive") ?: "#9147D7",
        secondaryText = color?.getString("secondaryText") ?: "#999999",
        secondaryDisable = color?.getString("secondaryDisable") ?: "#E0E0E0",
        secondaryComponentBackground = color?.getString("secondaryComponentBackground")
          ?: "#F0E9F9",
        secondaryBackground = color?.getString("secondaryBackground") ?: "#FFFFFF",
      ),
      font = ThemeFont(
        primaryFontFamily = font?.getString("primaryFontFamily") ?: "Oswald",
        secondaryFontFamily = font?.getString("secondaryFontFamily") ?: "Roboto Slab",
        bigTitleFontSize = parseFloatValueFromReadableMap(font, "bigTitleFontSize") ?: 21F,
        bigTitleFontLineHeight = parseIntValueFromReadableMap(font, "bigTitleFontLineHeight") ?: 37,
        pageHeaderFontSize = parseIntValueFromReadableMap(font, "pageHeaderFontSize") ?: 21,
        pageHeaderLineHeight = parseIntValueFromReadableMap(font, "pageHeaderLineHeight") ?: 31,
        modelTitleFontSize = parseFloatValueFromReadableMap(font, "modelTitleFontSize") ?: 20F,
        modelTitleFontLineHeight = parseIntValueFromReadableMap(font, "modelTitleFontLineHeight") ?: 29,
        sectionTitleFontSize = parseFloatValueFromReadableMap(font, "sectionTitleFontSize") ?: 16F,
        sectionTitleFontLineHeight = parseIntValueFromReadableMap(font, "sectionTitleFontLineHeight") ?: 24,
        bigFontSize = parseFloatValueFromReadableMap(font, "bigFontSize") ?: 18F,
        bigFontLineHeight = parseIntValueFromReadableMap(font, "bigFontLineHeight") ?: 26,
        normalFontSize = parseFloatValueFromReadableMap(font, "normalFontSize") ?: 14F,
        normalFontLineHeight = parseIntValueFromReadableMap(font, "normalFontLineHeight") ?: 18,
        smallFontSize = parseFloatValueFromReadableMap(font, "smallFontSize") ?: 13F,
        smallFontLineHeight = parseIntValueFromReadableMap(font, "smallFontLineHeight") ?: 20,
        boldFontSize = parseFloatValueFromReadableMap(font, "boldFontSize") ?: 15F,
        boldFontLineHeight = parseIntValueFromReadableMap(font, "boldFontLineHeight") ?: 21,
      ),
      modelRadius = parseFloatValueFromReadableMap(themeObj, "modelRadius") ?: 10F,
      pageHeaderRadius = parseFloatValueFromReadableMap(themeObj, "pageHeaderRadius") ?: 0F,
      inputFieldRadius = parseFloatValueFromReadableMap(themeObj, "inputFieldRadius") ?: 10F,
      buttonRadius = parseFloatValueFromReadableMap(themeObj, "buttonRadius") ?: 50F,
      boxShadow = themeObj.getString("boxShadow") ?: "0px 4px 30px rgba(0, 0, 0, 0.1)",
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
