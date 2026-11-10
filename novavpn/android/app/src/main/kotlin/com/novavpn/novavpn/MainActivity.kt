package com.novavpn.novavpn

import android.app.Activity
import android.content.Intent
import android.net.VpnService
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import com.wireguard.android.backend.GoBackend
import com.wireguard.android.backend.Tunnel
import com.wireguard.config.Config
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayInputStream
import java.nio.charset.StandardCharsets
import java.util.concurrent.Executors

/** Android WireGuard bridge. Configuration is accepted in-memory and is never logged. */
class MainActivity : FlutterActivity() {
    private val channelName = "com.novavpn/wireguard"
    private val requestVpnPermission = 4107
    private val executor = Executors.newSingleThreadExecutor()
    private val mainHandler = Handler(Looper.getMainLooper())
    private lateinit var backend: GoBackend
    private val tunnel = AppTunnel("NovaVPN")
    private var pendingConfig: String? = null
    private var pendingResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        backend = GoBackend(applicationContext)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName).setMethodCallHandler { call, result ->
            when (call.method) {
                "connect" -> {
                    val configText = call.argument<String>("config")?.trim()
                    if (configText.isNullOrEmpty()) {
                        result.error("INVALID_CONFIG", "Paste a complete WireGuard configuration first.", null)
                    } else if (pendingResult != null) {
                        result.error("BUSY", "A VPN authorization request is already in progress.", null)
                    } else {
                        connect(configText, result)
                    }
                }
                "disconnect" -> executor.execute {
                    try {
                        backend.setState(tunnel, Tunnel.State.DOWN, null)
                        mainHandler.post { result.success(null) }
                    } catch (error: Exception) {
                        mainHandler.post { result.error("DISCONNECT_FAILED", safeMessage(error), null) }
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun connect(configText: String, result: MethodChannel.Result) {
        val config = try {
            Config.parse(ByteArrayInputStream(configText.toByteArray(StandardCharsets.UTF_8)))
        } catch (_: Exception) {
            result.error("INVALID_CONFIG", "WireGuard config is invalid or incomplete. Verify it with your VPN provider.", null)
            return
        }

        val permissionIntent = VpnService.prepare(this)
        if (permissionIntent != null) {
            pendingConfig = configText
            pendingResult = result
            try {
                @Suppress("DEPRECATION")
                startActivityForResult(permissionIntent, requestVpnPermission)
            } catch (_: Exception) {
                pendingConfig = null
                pendingResult = null
                result.error("VPN_PERMISSION", "Android VPN permission could not be requested.", null)
            }
            return
        }
        startTunnel(config, result)
    }

    @Deprecated("Required for the Android VPN consent activity result")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode != requestVpnPermission) return
        val result = pendingResult ?: return
        val configText = pendingConfig
        pendingResult = null
        pendingConfig = null
        if (resultCode != Activity.RESULT_OK || configText == null) {
            result.error("VPN_PERMISSION_DENIED", "VPN permission was not granted.", null)
            return
        }
        val config = try {
            Config.parse(ByteArrayInputStream(configText.toByteArray(StandardCharsets.UTF_8)))
        } catch (_: Exception) {
            result.error("INVALID_CONFIG", "WireGuard config is invalid or incomplete.", null)
            return
        }
        startTunnel(config, result)
    }

    private fun startTunnel(config: Config, result: MethodChannel.Result) {
        executor.execute {
            try {
                backend.setState(tunnel, Tunnel.State.UP, config)
                mainHandler.post { result.success(null) }
            } catch (error: Exception) {
                mainHandler.post { result.error("CONNECT_FAILED", safeMessage(error), null) }
            }
        }
    }

    private fun safeMessage(error: Exception): String {
        val message = error.message.orEmpty()
        // Never allow configuration material or keys into platform error responses.
        return if (message.length > 240) "WireGuard operation failed. Check device network and configuration." else message
    }

    override fun onDestroy() {
        if (::backend.isInitialized) {
            executor.execute {
                try {
                    backend.setState(tunnel, Tunnel.State.DOWN, null)
                } catch (_: Exception) {
                    // Do not log tunnel config or key-bearing exceptions.
                }
            }
        }
        executor.shutdown()
        super.onDestroy()
    }

    private class AppTunnel(private val name: String) : Tunnel {
        @Volatile private var state: Tunnel.State = Tunnel.State.DOWN
        override fun getName(): String = name
        override fun onStateChange(newState: Tunnel.State) { state = newState }
        fun currentState(): Tunnel.State = state
    }
}
