package com.pisey.flutter_native_player.utils

import org.json.JSONException
import org.json.JSONObject
import kotlin.reflect.KClass

object JsonUtil {
    @Throws(JSONException::class)
    fun jsonToMap(t: String):HashMap<String,String> {
        val map = HashMap<String, String>()
        val jObject = JSONObject(t)
        val keys: Iterator<*> = jObject.keys()
        while (keys.hasNext()) {
            val key = keys.next() as String
            val value: String = jObject.getString(key)
            map[key] = value
        }
        return map
    }

}