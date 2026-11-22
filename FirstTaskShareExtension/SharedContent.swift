import Foundation
import UniformTypeIdentifiers

struct SharedContent: Equatable, Sendable {
    var title: String = ""
    var url: String = ""

    @MainActor
    static func load(from items: [NSExtensionItem]) async -> SharedContent {
        var content = SharedContent()
        for item in items {
            for provider in item.attachments ?? [] {
                if provider.hasItemConformingToTypeIdentifier(UTType.propertyList.identifier), let page = await loadWebPage(from: provider) {
                    content.title = content.title.isEmpty ? page.title : content.title
                    content.url = content.url.isEmpty ? page.url : content.url
                } else if provider.hasItemConformingToTypeIdentifier(UTType.url.identifier), let url = await loadObject(URL.self, from: provider) {
                    content.url = content.url.isEmpty ? url.absoluteString : content.url
                } else if provider.hasItemConformingToTypeIdentifier(UTType.plainText.identifier), let text = await loadObject(String.self, from: provider) {
                    content.title = content.title.isEmpty ? text : content.title
                }
            }
            if content.title.isEmpty, let text = item.attributedContentText?.string ?? item.attributedTitle?.string {
                content.title = text
            }
        }
        content.title = content.title.trimmingCharacters(in: .whitespacesAndNewlines)
        if content.title.isEmpty {
            content.title = content.url
        }
        return content
    }

    // Safari runs Preprocessing.js and passes its result as a property list.
    @MainActor
    private static func loadWebPage(from provider: NSItemProvider) async -> (title: String, url: String)? {
        await withCheckedContinuation { continuation in
            provider.loadItem(forTypeIdentifier: UTType.propertyList.identifier) { item, _ in
                let results = (item as? NSDictionary)?[NSExtensionJavaScriptPreprocessingResultsKey] as? NSDictionary
                guard let results else {
                    continuation.resume(returning: nil)
                    return
                }
                continuation.resume(returning: (results["title"] as? String ?? "", results["url"] as? String ?? ""))
            }
        }
    }

    @MainActor
    private static func loadObject<T: _ObjectiveCBridgeable & Sendable>(_ type: T.Type, from provider: NSItemProvider) async -> T?
    where T._ObjectiveCType: NSItemProviderReading {
        await withCheckedContinuation { continuation in
            _ = provider.loadObject(ofClass: type) { object, _ in
                continuation.resume(returning: object)
            }
        }
    }
}
