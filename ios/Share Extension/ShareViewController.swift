//
//  ShareViewController.swift
//  Share Extension
//
//  Created by iMac on 19/12/23.
//

import UIKit
import Social
import MobileCoreServices

class ShareViewController: SLComposeServiceViewController {
    var sharedText: [String] = []
    let sharedKey = "ShareKey"
    let hostAppBundleIdentifier = "com.whatsappDirect"
    let textContentType = kUTTypeText as String
    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        return true
    }

    override func didSelectPost() {
        // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
    
        // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }

    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        return []
    }

    private func handleText (content: NSExtensionItem, attachment: NSItemProvider, index: Int) {
        attachment.loadItem(forTypeIdentifier: textContentType, options: nil) { [weak self] data, error in

            if error == nil, let item = data as? String, let this = self {

                this.sharedText.append(item)

                // If this is the last item, save imagesData in userDefaults and redirect to host app
                if index == (content.attachments?.count)! - 1 {
                    let userDefaults = UserDefaults(suiteName: "group.\(this.hostAppBundleIdentifier)")
                    userDefaults?.set(this.sharedText, forKey: this.sharedKey)
                    userDefaults?.synchronize()
                    this.redirectToHostApp(type: .text)
                }

            } else {
                self?.dismissWithError()
            }
        }
    }
    private func redirectToHostApp(type: RedirectType) {
         let url = URL(string: "ShareMedia://dataUrl=\(sharedKey)#\(type)")
         var responder = self as UIResponder?
         let selectorOpenURL = sel_registerName("openURL:")

         while (responder != nil) {
             if (responder?.responds(to: selectorOpenURL))! {
                 let _ = responder?.perform(selectorOpenURL, with: url)
             }
             responder = responder!.next
         }
         extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
     }

    enum RedirectType {
          case media
          case text
          case file
      }
    private func dismissWithError() {
          print("[ERROR] Error loading data!")
          let alert = UIAlertController(title: "Error", message: "Error loading data", preferredStyle: .alert)

          let action = UIAlertAction(title: "Error", style: .cancel) { _ in
              self.dismiss(animated: true, completion: nil)
          }

          alert.addAction(action)
          present(alert, animated: true, completion: nil)
          extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
      }
}
