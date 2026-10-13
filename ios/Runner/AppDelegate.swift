import Flutter
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
