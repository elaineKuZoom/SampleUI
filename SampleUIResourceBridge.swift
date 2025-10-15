import Foundation
@objc(SampleUIResourceBridge)
public class SampleUIResourceBridge: NSObject {
  @objc public static var bundle: Bundle { .module }
}
