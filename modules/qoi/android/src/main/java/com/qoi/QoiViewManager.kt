package com.qoi

import android.graphics.Bitmap
import androidx.compose.ui.graphics.Color
import android.widget.ImageView
import androidx.compose.ui.graphics.toArgb
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.module.annotations.ReactModule
import com.facebook.react.uimanager.SimpleViewManager
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.ViewManagerDelegate
import com.facebook.react.uimanager.annotations.ReactProp
import com.facebook.react.viewmanagers.QoiViewManagerInterface
import com.facebook.react.viewmanagers.QoiViewManagerDelegate
import io.github.mzgreen.qoi.kotlin.QOIReader
import kotlinx.coroutines.*
import java.io.BufferedInputStream
import java.io.File
import java.net.URL

@ReactModule(name = QoiViewManager.NAME)
class QoiViewManager(reactContext: ReactApplicationContext) : SimpleViewManager<QoiView>(),
  QoiViewManagerInterface<QoiView> {
  private val mDelegate: ViewManagerDelegate<QoiView>

  val context: ReactApplicationContext

  init {
    mDelegate = QoiViewManagerDelegate(this)
    context = reactContext
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

  companion object {
    const val NAME = "QoiView"
  }

  @ReactProp(name = "url")
  override fun setUrl(view: QoiView?, value: String?) {
    if (value != null) {
      val url = URL(value)
      val name = value.substring(value.lastIndexOf("/")+1);

      val scope = CoroutineScope(Dispatchers.Default)
      scope.launch {
        val file = File("${context.filesDir.absolutePath}/${name}")
        BufferedInputStream(url.openStream()).use { inputStream ->
          file.outputStream().use { output ->
            inputStream.copyTo(output)
          }
        }

        withContext(Dispatchers.Main) {
          val qoiReader = QOIReader()
          val f = qoiReader.read(file.path)

          val colors = IntArray(f.colors.size / 4)

          for (index in f.colors.indices.step(4)) {
            val color = Color(f.colors[index], f.colors[index + 1], f.colors[index + 2], f.colors[index + 3]).toArgb()
            colors[index / 4] = color
          }
          val bitmap = Bitmap.createBitmap(f.width, f.height, Bitmap.Config.ARGB_8888)
          bitmap.setPixels(colors, 0, f.width,0,0, f.width, f.height)

          val iv = view!!.findViewById<ImageView>(R.id.image)
          iv.setImageBitmap(bitmap)
        }
      }
    }
  }
}
