import Flutter
import GoogleMaps
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    // TODO: Replace with your iOS Google Maps API key
    GMSServices.provideAPIKey("YOUR_IOS_API_KEY")
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
