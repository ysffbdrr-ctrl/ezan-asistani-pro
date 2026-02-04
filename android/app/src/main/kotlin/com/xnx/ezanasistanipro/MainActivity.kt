package com.xnx.ezanasistanipro

import android.content.Context
import android.media.AudioManager
import android.media.AudioAttributes
import android.media.AudioFocusRequest
import android.os.Build
import android.os.Bundle
import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
    }
    private val CHANNEL = "com.xnx.ezanasistanipro/audio"
    private val COUNTDOWN_CHANNEL = "com.xnx.ezanasistanipro/countdown_service"
    private var audioManager: AudioManager? = null
    private var audioFocusRequest: AudioFocusRequest? = null
    private var wasPlayingBeforeDuck = false
    private var flutterEngineInstance: FlutterEngine? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        flutterEngineInstance = flutterEngine
        
        audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            when (call.method) {
                "requestAudioFocus" -> {
                    if (requestAudioFocus()) {
                        result.success(true)
                    } else {
                        result.error("AUDIO_FOCUS_ERROR", "Failed to get audio focus", null)
                    }
                }
                "abandonAudioFocus" -> {
                    abandonAudioFocus()
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, COUNTDOWN_CHANNEL).setMethodCallHandler {
            call, result ->
            when (call.method) {
                "startOrUpdateCountdown" -> {
                    val title = call.argument<String>("title") ?: ""
                    val body = call.argument<String>("body") ?: ""
                    val targetEpochMs = call.argument<Long>("targetEpochMs") ?: -1L

                    val intent = Intent(this, CountdownForegroundService::class.java).apply {
                        action = CountdownForegroundService.ACTION_START_OR_UPDATE
                        putExtra("title", title)
                        putExtra("body", body)
                        putExtra("targetEpochMs", targetEpochMs)
                    }

                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        startForegroundService(intent)
                    } else {
                        startService(intent)
                    }

                    result.success(true)
                }
                "stopCountdown" -> {
                    val intent = Intent(this, CountdownForegroundService::class.java).apply {
                        action = CountdownForegroundService.ACTION_STOP
                    }
                    startService(intent)
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun requestAudioFocus(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val focusRequest = AudioFocusRequest.Builder(AudioManager.AUDIOFOCUS_GAIN)
                .setAudioAttributes(
                    AudioAttributes.Builder()
                        .setUsage(AudioAttributes.USAGE_MEDIA)
                        .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                        .build()
                )
                .setAcceptsDelayedFocusGain(true)
                .setOnAudioFocusChangeListener { focusChange ->
                    when (focusChange) {
                        AudioManager.AUDIOFOCUS_GAIN -> {
                            // Resume playback or raise volume back to normal
                            if (wasPlayingBeforeDuck) {
                                wasPlayingBeforeDuck = false
                                // Notify Flutter to resume playback
                                flutterEngineInstance?.dartExecutor?.binaryMessenger?.let {
                                    MethodChannel(it, CHANNEL).invokeMethod("onAudioFocusGain", null)
                                }
                            }
                        }
                        AudioManager.AUDIOFOCUS_LOSS_TRANSIENT -> {
                            // Pause playback
                            wasPlayingBeforeDuck = true
                            flutterEngineInstance?.dartExecutor?.binaryMessenger?.let {
                                MethodChannel(it, CHANNEL).invokeMethod("onAudioFocusLoss", null)
                            }
                        }
                        AudioManager.AUDIOFOCUS_LOSS -> {
                            // Stop playback and release resources
                            wasPlayingBeforeDuck = false
                            flutterEngineInstance?.dartExecutor?.binaryMessenger?.let {
                                MethodChannel(it, CHANNEL).invokeMethod("onAudioFocusLoss", null)
                            }
                        }
                        AudioManager.AUDIOFOCUS_LOSS_TRANSIENT_CAN_DUCK -> {
                            // Lower the volume or pause
                            wasPlayingBeforeDuck = true
                            flutterEngineInstance?.dartExecutor?.binaryMessenger?.let {
                                MethodChannel(it, CHANNEL).invokeMethod("onAudioDuck", null)
                            }
                        }
                    }
                }
                .build()
            
            audioFocusRequest = focusRequest
            val result = audioManager?.requestAudioFocus(focusRequest) ?: AudioManager.AUDIOFOCUS_REQUEST_FAILED
            result == AudioManager.AUDIOFOCUS_REQUEST_GRANTED
        } else {
            @Suppress("DEPRECATION")
            val result = audioManager?.requestAudioFocus(
                { focusChange ->
                    when (focusChange) {
                        AudioManager.AUDIOFOCUS_GAIN -> {
                            if (wasPlayingBeforeDuck) {
                                wasPlayingBeforeDuck = false
                                flutterEngineInstance?.dartExecutor?.binaryMessenger?.let {
                                    MethodChannel(it, CHANNEL).invokeMethod("onAudioFocusGain", null)
                                }
                            }
                        }
                        AudioManager.AUDIOFOCUS_LOSS -> {
                            wasPlayingBeforeDuck = false
                            flutterEngineInstance?.dartExecutor?.binaryMessenger?.let {
                                MethodChannel(it, CHANNEL).invokeMethod("onAudioFocusLoss", null)
                            }
                        }
                        AudioManager.AUDIOFOCUS_LOSS_TRANSIENT -> {
                            wasPlayingBeforeDuck = true
                            flutterEngineInstance?.dartExecutor?.binaryMessenger?.let {
                                MethodChannel(it, CHANNEL).invokeMethod("onAudioFocusLoss", null)
                            }
                        }
                        AudioManager.AUDIOFOCUS_LOSS_TRANSIENT_CAN_DUCK -> {
                            wasPlayingBeforeDuck = true
                            flutterEngineInstance?.dartExecutor?.binaryMessenger?.let {
                                MethodChannel(it, CHANNEL).invokeMethod("onAudioDuck", null)
                            }
                        }
                    }
                },
                AudioManager.STREAM_MUSIC,
                AudioManager.AUDIOFOCUS_GAIN
            )
            result == AudioManager.AUDIOFOCUS_REQUEST_GRANTED
        }
    }

    private fun abandonAudioFocus() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            audioFocusRequest?.let { request ->
                audioManager?.abandonAudioFocusRequest(request)
            }
        } else {
            @Suppress("DEPRECATION")
            audioManager?.abandonAudioFocus(null)
        }
        wasPlayingBeforeDuck = false
    }

    override fun onDestroy() {
        abandonAudioFocus()
        super.onDestroy()
    }
}
