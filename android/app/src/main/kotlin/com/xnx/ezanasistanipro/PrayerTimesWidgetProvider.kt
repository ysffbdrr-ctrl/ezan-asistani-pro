package com.xnx.ezanasistanipro

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

open class BasePrayerTimesWidgetProvider(
    private val layoutId: Int
) : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { appWidgetId ->
            val views = RemoteViews(context.packageName, layoutId)

            val city = widgetData.getString("city", "Ezan Asistanı Pro") ?: "Ezan Asistanı Pro"
            val updatedAt = widgetData.getString("updatedAt", null)
            val nextPrayer = widgetData.getString("nextPrayer", null)
            val nextPrayerTime = widgetData.getString("nextPrayerTime", null)

            val fajr = widgetData.getString("time_Fajr", "--:--") ?: "--:--"
            val sunrise = widgetData.getString("time_Sunrise", "--:--") ?: "--:--"
            val dhuhr = widgetData.getString("time_Dhuhr", "--:--") ?: "--:--"
            val asr = widgetData.getString("time_Asr", "--:--") ?: "--:--"
            val maghrib = widgetData.getString("time_Maghrib", "--:--") ?: "--:--"
            val isha = widgetData.getString("time_Isha", "--:--") ?: "--:--"

            views.trySetText(R.id.widget_city, city)
            views.trySetText(
                R.id.widget_updated,
                updatedAt?.let { "Güncellendi: $it" }
            )

            val nextLabel = if (!nextPrayer.isNullOrBlank()) {
                "Sonraki: $nextPrayer"
            } else {
                "Sonraki vakit bilgisi yok"
            }
            views.trySetText(R.id.widget_next_prayer, nextLabel)
            views.trySetText(R.id.widget_next_prayer_time, nextPrayerTime ?: "--:--")

            views.trySetText(R.id.widget_fajr, fajr)
            views.trySetText(R.id.widget_sunrise, sunrise)
            views.trySetText(R.id.widget_dhuhr, dhuhr)
            views.trySetText(R.id.widget_asr, asr)
            views.trySetText(R.id.widget_maghrib, maghrib)
            views.trySetText(R.id.widget_isha, isha)

            val launchPendingIntent = HomeWidgetLaunchIntent.getActivity(
                context,
                MainActivity::class.java
            )
            views.setOnClickPendingIntent(R.id.widget_root, launchPendingIntent)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}

class PrayerTimesLargeWidgetProvider : BasePrayerTimesWidgetProvider(R.layout.prayer_times_widget)

class PrayerTimesCompactWidgetProvider : BasePrayerTimesWidgetProvider(R.layout.prayer_times_widget_compact)

class PrayerTimesNextWidgetProvider : BasePrayerTimesWidgetProvider(R.layout.prayer_times_widget_next)

class PrayerTimesHorizontalWidgetProvider : BasePrayerTimesWidgetProvider(R.layout.prayer_times_widget_horizontal)

private fun RemoteViews.trySetText(viewId: Int, text: CharSequence?) {
    runCatching {
        setTextViewText(viewId, text ?: "")
    }
}
