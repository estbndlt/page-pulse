import Flutter
import PDFKit
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller = window?.rootViewController as! FlutterViewController
    let pdfTextChannel = FlutterMethodChannel(
      name: "page_pulse/pdf_text",
      binaryMessenger: controller.binaryMessenger
    )
    pdfTextChannel.setMethodCallHandler { call, result in
      guard call.method == "extractText" else {
        result(FlutterMethodNotImplemented)
        return
      }

      Self.extractPdfText(call: call, result: result)
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private static func extractPdfText(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
      let path = args["path"] as? String
    else {
      result(FlutterError(code: "bad-args", message: "Missing PDF path.", details: nil))
      return
    }

    let password = args["password"] as? String ?? ""

    DispatchQueue.global(qos: .userInitiated).async {
      guard FileManager.default.fileExists(atPath: path) else {
        DispatchQueue.main.async {
          result(FlutterError(code: "not-found", message: "PDF file was not found.", details: path))
        }
        return
      }

      guard let document = PDFDocument(url: URL(fileURLWithPath: path)) else {
        DispatchQueue.main.async {
          result(FlutterError(code: "invalid-pdf", message: "Could not open PDF.", details: path))
        }
        return
      }

      if document.isLocked && !password.isEmpty && !document.unlock(withPassword: password) {
        DispatchQueue.main.async {
          result(FlutterError(code: "locked-pdf", message: "Could not unlock PDF.", details: nil))
        }
        return
      }

      if document.isLocked {
        DispatchQueue.main.async {
          result(FlutterError(code: "locked-pdf", message: "PDF is password protected.", details: nil))
        }
        return
      }

      var pages: [[String: Any]] = []
      for index in 0..<document.pageCount {
        let text = document.page(at: index)?.string ?? ""
        pages.append(["pageNumber": index + 1, "text": text])
      }

      var response: [String: Any] = ["pages": pages]
      if let title = document.documentAttributes?[PDFDocumentAttribute.titleAttribute] as? String {
        response["title"] = title
      }

      DispatchQueue.main.async {
        result(response)
      }
    }
  }
}
