package com.asso.asso

import android.os.Bundle
import android.util.Log
import com.stripe.android.connect.AccountOnboardingController
import com.stripe.android.connect.AccountOnboardingListener
import com.stripe.android.connect.AccountOnboardingProps
import com.stripe.android.connect.EmbeddedComponentManager
import com.stripe.android.connect.FetchClientSecretTask
import com.stripe.android.connect.StripeComponentController
import com.stripe.android.connect.appearance.Appearance
import com.stripe.android.connect.appearance.Colors
import com.stripe.android.connect.appearance.CornerRadius
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

// flutter_stripe exige que l'Activity hôte étende FlutterFragmentActivity
// (et non FlutterActivity) pour présenter la Payment Sheet native.
class MainActivity : FlutterFragmentActivity() {

    private var connectChannel: MethodChannel? = null
    private var connectManager: EmbeddedComponentManager? = null
    private var onboardingController: AccountOnboardingController? = null
    private var pendingResult: MethodChannel.Result? = null
    private var initialSecret: String? = null
    private var lastError: String? = null
    private var connectReady = false

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Exigé par le SDK Stripe Connect avant toute création de composant.
        connectReady = try {
            EmbeddedComponentManager.onActivityCreate(this)
            true
        } catch (e: Throwable) {
            Log.e(TAG, "Stripe Connect indisponible", e)
            false
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        connectChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).also {
            it.setMethodCallHandler(::handleConnectCall)
        }
    }

    /**
     * Inscription vendeur Stripe Connect INTÉGRÉE à l'app (composant « account
     * onboarding »), aux couleurs d'ASSO.
     *  - Dart → natif `present` { publishableKey, clientSecret, title, primaryColor }
     *    → répond à la fermeture { event: "exit", error: String? } ;
     *  - natif → Dart `fetchClientSecret` quand la session Stripe expire.
     */
    private fun handleConnectCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "isSupported" -> result.success(connectReady)
            "present" -> presentOnboarding(call, result)
            else -> result.notImplemented()
        }
    }

    private fun presentOnboarding(call: MethodCall, result: MethodChannel.Result) {
        if (!connectReady) {
            result.error("unsupported", "Stripe Connect SDK unavailable", null)
            return
        }
        if (pendingResult != null) {
            result.error("busy", "Onboarding already open", null)
            return
        }
        val key = call.argument<String>("publishableKey")
        val secret = call.argument<String>("clientSecret")
        if (key.isNullOrEmpty() || secret.isNullOrEmpty()) {
            result.error("bad_args", "Missing publishable key or client secret", null)
            return
        }

        try {
            val primary = (call.argument<Number>("primaryColor"))?.toInt()
            val appearance = Appearance.Builder()
                .colors(
                    Colors.Builder()
                        .primary(primary)
                        .formAccent(primary)
                        .formHighlightBorder(primary)
                        .build()
                )
                .cornerRadius(
                    CornerRadius.Builder()
                        .base(12f)
                        .button(12f)
                        .form(10f)
                        .build()
                )
                .build()

            initialSecret = secret
            lastError = null
            pendingResult = result

            val manager = EmbeddedComponentManager(
                publishableKey = key,
                fetchClientSecret = object : FetchClientSecretTask() {
                    override fun fetchClientSecret(callback: ResultCallback) {
                        fetchSecret(callback)
                    }
                },
                appearance = appearance,
            )
            val controller = manager.createAccountOnboardingController(
                activity = this,
                title = call.argument<String>("title"),
                props = AccountOnboardingProps(
                    collectionOptions = AccountOnboardingProps.CollectionOptions(
                        fields = AccountOnboardingProps.FieldOption.EVENTUALLY_DUE,
                    ),
                ),
            )
            controller.listener = object : AccountOnboardingListener {
                override fun onExit() {
                    controller.dismiss()
                }

                override fun onLoadError(error: Throwable) {
                    // Peut arriver plusieurs fois : la dernière erreur est rendue à la fermeture.
                    lastError = error.message ?: error.javaClass.simpleName
                    runOnUiThread { connectChannel?.invokeMethod("loadError", lastError) }
                }
            }
            controller.onDismissListener = StripeComponentController.OnDismissListener { finishOnboarding() }

            connectManager = manager
            onboardingController = controller
            controller.show()
        } catch (e: Throwable) {
            Log.e(TAG, "Ouverture de l'inscription Stripe impossible", e)
            pendingResult = null
            result.error("present_failed", e.message, null)
        }
    }

    /** Premier appel : le secret fourni par Dart ; ensuite Dart en redemande un au serveur. */
    private fun fetchSecret(callback: FetchClientSecretTask.ResultCallback) {
        initialSecret?.let {
            initialSecret = null
            callback.onResult(it)
            return
        }
        runOnUiThread {
            val channel = connectChannel
            if (channel == null) {
                callback.onResult(null)
                return@runOnUiThread
            }
            channel.invokeMethod("fetchClientSecret", null, object : MethodChannel.Result {
                override fun success(value: Any?) = callback.onResult(value as? String)
                override fun error(code: String, message: String?, details: Any?) = callback.onResult(null)
                override fun notImplemented() = callback.onResult(null)
            })
        }
    }

    private fun finishOnboarding() {
        val result = pendingResult ?: return
        pendingResult = null
        onboardingController = null
        connectManager = null
        initialSecret = null
        val payload = mutableMapOf<String, Any>("event" to "exit")
        lastError?.let { payload["error"] = it }
        result.success(payload)
    }

    private companion object {
        const val CHANNEL = "asso/stripe_connect_onboarding"
        const val TAG = "AssoStripeConnect"
    }
}
