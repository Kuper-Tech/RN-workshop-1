package com.qoi

import android.graphics.Color
import com.facebook.react.module.annotations.ReactModule
import com.facebook.react.uimanager.SimpleViewManager
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.ViewManagerDelegate
import com.facebook.react.uimanager.annotations.ReactProp
import com.facebook.react.viewmanagers.QoiViewManagerInterface
import com.facebook.react.viewmanagers.QoiViewManagerDelegate

@ReactModule(name = QoiViewManager.NAME)
class QoiViewManager : SimpleViewManager<QoiView>(),
  QoiViewManagerInterface<QoiView> {
  private val mDelegate: ViewManagerDelegate<QoiView>

  init {
    mDelegate = QoiViewManagerDelegate(this)
  }

  override fun getDelegate(): ViewManagerDelegate<QoiView>? {
    return mDelegate
  }

  override fun getName(): String {
    return NAME
  }

  public override fun createViewInstance(context: ThemedReactContext): QoiView {
    return QoiView(context)
  }

  @ReactProp(name = "color")
  override fun setColor(view: QoiView?, color: String?) {
    view?.setBackgroundColor(Color.parseColor(color))
  }

  companion object {
    const val NAME = "QoiView"
  }
}
