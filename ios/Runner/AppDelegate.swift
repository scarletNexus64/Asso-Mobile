import Flutter
import StripeConnect
import StripeCore
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "AssoStripeConnectOnboarding") {
      AssoStripeConnectOnboarding.shared.register(messenger: registrar.messenger())
    }
  }
}

/// Inscription vendeur Stripe Connect INTÉGRÉE à l'app (composant « account
/// onboarding » du SDK StripeConnect), aux couleurs d'ASSO.
///
/// Canal `asso/stripe_connect_onboarding` :
///  - Dart → natif `present` { publishableKey, clientSecret, title, primaryColor }
///    → répond à la fermeture { event: "exit", error: String? } ;
///  - natif → Dart `fetchClientSecret` quand la session Stripe expire.
final class AssoStripeConnectOnboarding: NSObject, AccountOnboardingControllerDelegate {
  static let shared = AssoStripeConnectOnboarding()

  private var channel: FlutterMethodChannel?
  private var manager: EmbeddedComponentManager?
  private var controller: AccountOnboardingController?
  private var pendingResult: FlutterResult?
  private var initialSecret: String?
  private var lastError: String?

  func register(messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: "asso/stripe_connect_onboarding", binaryMessenger: messenger)
    channel.setMethodCallHandler { [weak self] call, result in
      self?.handle(call, result: result)
    }
    self.channel = channel
  }

  private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "isSupported":
      result(true)
    case "present":
      present(call.arguments as? [String: Any] ?? [:], result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func present(_ args: [String: Any], result: @escaping FlutterResult) {
    guard pendingResult == nil else {
      result(FlutterError(code: "busy", message: "Onboarding already open", details: nil))
      return
    }
    guard let key = args["publishableKey"] as? String, !key.isEmpty,
          let secret = args["clientSecret"] as? String, !secret.isEmpty else {
      result(FlutterError(code: "bad_args", message: "Missing publishable key or client secret", details: nil))
      return
    }
    guard let presenter = Self.topViewController() else {
      result(FlutterError(code: "no_view", message: "No view controller to present from", details: nil))
      return
    }

    var appearance = EmbeddedComponentManager.Appearance()
    if let argb = (args["primaryColor"] as? NSNumber)?.uint32Value {
      let color = UIColor(
        red: CGFloat((argb >> 16) & 0xFF) / 255,
        green: CGFloat((argb >> 8) & 0xFF) / 255,
        blue: CGFloat(argb & 0xFF) / 255,
        alpha: 1
      )
      appearance.colors.primary = color
      appearance.colors.formAccent = color
      appearance.colors.formHighlightBorder = color
    }
    appearance.cornerRadius.base = 12
    appearance.cornerRadius.button = 12
    appearance.cornerRadius.form = 10

    initialSecret = secret
    lastError = nil
    pendingResult = result

    let manager = EmbeddedComponentManager(
      apiClient: STPAPIClient(publishableKey: key),
      appearance: appearance,
      fetchClientSecret: { [weak self] in await self?.fetchClientSecret() }
    )
    var options = AccountCollectionOptions()
    options.fields = .eventuallyDue
    let controller = manager.createAccountOnboardingController(collectionOptions: options)
    controller.title = args["title"] as? String
    controller.delegate = self

    self.manager = manager
    self.controller = controller
    controller.present(from: presenter)
  }

  /// Premier appel : le secret fourni par Dart ; ensuite (session expirée) Dart
  /// en demande un nouveau au serveur.
  @MainActor
  private func fetchClientSecret() async -> String? {
    if let secret = initialSecret {
      initialSecret = nil
      return secret
    }
    guard let channel else { return nil }
    return await withCheckedContinuation { continuation in
      channel.invokeMethod("fetchClientSecret", arguments: nil) { value in
        continuation.resume(returning: value as? String)
      }
    }
  }

  func accountOnboardingDidExit(_ accountOnboarding: AccountOnboardingController) {
    finish()
  }

  func accountOnboarding(_ accountOnboarding: AccountOnboardingController,
                         didFailLoadWithError error: Error) {
    // Peut arriver plusieurs fois : on garde la dernière erreur, transmise à la fermeture.
    lastError = error.localizedDescription
    channel?.invokeMethod("loadError", arguments: error.localizedDescription)
  }

  private func finish() {
    let result = pendingResult
    pendingResult = nil
    controller = nil
    manager = nil
    initialSecret = nil
    var payload: [String: Any] = ["event": "exit"]
    if let lastError { payload["error"] = lastError }
    result?(payload)
  }

  private static func topViewController() -> UIViewController? {
    let window = UIApplication.shared.connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .flatMap { $0.windows }
      .first { $0.isKeyWindow }
      ?? (UIApplication.shared.delegate as? FlutterAppDelegate)?.window
    var top = window?.rootViewController
    while let presented = top?.presentedViewController {
      top = presented
    }
    return top
  }
}

/// Délégué de scène : la fenêtre de la scène est aussi exposée par
/// `AppDelegate.window`. stripe_ios 11.x y cherche l'écran d'où présenter la
/// Payment Sheet ; depuis le passage au cycle de vie par scènes elle restait
/// nil, et la feuille de paiement par carte ne s'affichait plus.
///
/// La copie est différée : si `AppDelegate.window` a déjà un rootViewController
/// quand la scène se connecte, FlutterSceneDelegate croit à une ancienne
/// configuration et recrée la fenêtre, sans contrôleur racine → écran noir.
class SceneDelegate: FlutterSceneDelegate {
  override var window: UIWindow? {
    didSet {
      let appDelegate = UIApplication.shared.delegate as? FlutterAppDelegate
      appDelegate?.window = nil
      DispatchQueue.main.async { [weak self] in appDelegate?.window = self?.window }
    }
  }
}
