package com.metrica

import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.ReadableMap
import io.appmetrica.analytics.AppMetrica
import io.appmetrica.analytics.AppMetricaConfig

class MetricaModule(reactContext: ReactApplicationContext) :
  ReactContextBaseJavaModule(reactContext) {

  override fun getName(): String {
    return NAME
  }

  @ReactMethod
  fun activate(apiKey: String) {
    val config = AppMetricaConfig.newConfigBuilder(apiKey).build()
    AppMetrica.activate(reactApplicationContext, config)
  }

  @ReactMethod
  fun reportEvent(eventName: String, params: ReadableMap?) {
    AppMetrica.reportEvent(eventName, params?.toHashMap())
  }

  companion object {
    const val NAME = "Metrica"
  }
}
