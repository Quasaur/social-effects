import Foundation

/// Minimal RSS feed parser for wisdombook.life feeds.
/// Extracts title, content (description), link, source, and content type from <item> elements.
struct RSSFetcher {
    
    struct FeedItem: Codable {
        let title: String
        let content: String
        let link: String
        /// For PASSAGE items: Book/Chapter/Verse (e.g., "Proverbs 3:34")
        /// For THOUGHT items: "wisdombook.life"
        let source: String
        /// Content type: "passage", "thought", "quote", etc.
        let contentType: String
    }
    
    static let feedURLs: [String: String] = [
        "daily":    "https://www.wisdombook.life/feed/daily.xml",
        "wisdom":   "https://www.wisdombook.life/feed/wisdom.xml",
        "thoughts": "https://www.wisdombook.life/feed/thoughts.xml",
        "quotes":   "https://www.wisdombook.life/feed/quotes.xml",
        "passages": "https://www.wisdombook.life/feed/passages.xml"
    ]
    
    /// Fetch a single item from the specified feed (defaults to "daily").
    static func fetchItem(feed: String = "daily") async throws -> FeedItem {
        guard let urlString = feedURLs[feed],
              let url = URL(string: urlString) else {
            throw NSError(domain: "RSSFetcher", code: 1,
                          userInfo: [NSLocalizedDescriptionKey: "Unknown feed: \(feed)"])
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NSError(domain: "RSSFetcher", code: 2,
                          userInfo: [NSLocalizedDescriptionKey: "RSS feed returned non-200 status"])
        }
        
        guard let xml = String(data: data, encoding: .utf8) else {
            throw NSError(domain: "RSSFetcher", code: 3,
                          userInfo: [NSLocalizedDescriptionKey: "Failed to decode RSS feed"])
        }
        
        // Parse first <item> from RSS XML
        guard let item = parseFirstItem(from: xml) else {
            throw NSError(domain: "RSSFetcher", code: 4,
                          userInfo: [NSLocalizedDescriptionKey: "No items found in RSS feed"])
        }
        
        return item
    }
    
    /// Simple XML extraction — pulls first <item>'s title, description, link, source, and type
    private static func parseFirstItem(from xml: String) -> FeedItem? {
        guard let itemStart = xml.range(of: "<item>"),
              let itemEnd = xml.range(of: "</item>") else { return nil }
        
        let itemXML = String(xml[itemStart.upperBound..<itemEnd.lowerBound])
        
        // Extract basic fields - use title exactly as provided in RSS (no prefix stripping)
        let title = extractTag("title", from: itemXML) ?? "Untitled"
        let content = extractTag("description", from: itemXML) ?? ""
        let link = extractTag("link", from: itemXML) ?? "https://wisdombook.life"
        
        // Extract content type from category tags (look for "Passage", "Thought", "Quote")
        let contentType = extractContentType(from: itemXML)
        
        // Extract source: for PASSAGE items (Bible reference) and QUOTE items (book name)
        // use wisdom:source tag. THOUGHT items don't have a source.
        let source: String
        if contentType == "passage" || contentType == "quote" {
            source = extractWisdomSource(from: itemXML) ?? "wisdombook.life"
        } else {
            source = "wisdombook.life"
        }
        
        return FeedItem(
            title: title,
            content: content,
            link: link,
            source: source,
            contentType: contentType
        )
    }
    
    /// Extract content type from category tags (passage, thought, quote, etc.)
    private static func extractContentType(from xml: String) -> String {
        // Look for category tags and find the content type
        var searchRange = xml.startIndex..<xml.endIndex
        while let categoryStart = xml.range(of: "<category>", range: searchRange) {
            guard let categoryEnd = xml.range(of: "</category>", range: categoryStart.upperBound..<xml.endIndex) else { break }
            
            let categoryValue = String(xml[categoryStart.upperBound..<categoryEnd.lowerBound])
                .trimmingCharacters(in: .whitespacesAndNewlines)
            
            let lowerValue = categoryValue.lowercased()
            if ["passage", "thought", "quote", "scripture"].contains(lowerValue) {
                return lowerValue
            }
            
            searchRange = categoryEnd.upperBound..<xml.endIndex
        }
        return "thought" // Default to thought if no specific type found
    }
    
    /// Extract wisdom:source tag (Book/Chapter/Verse for scripture passages)
    private static func extractWisdomSource(from xml: String) -> String? {
        // Try wisdom:source namespace tag (e.g., <wisdom:source>Proverbs 3:34</wisdom:source>)
        let patterns = [
            "<wisdom:source>",
            "<source>"
        ]
        
        for pattern in patterns {
            if let start = xml.range(of: pattern),
               let endPattern = pattern == "<wisdom:source>" ? "</wisdom:source>" : "</source>",
               let end = xml.range(of: endPattern, range: start.upperBound..<xml.endIndex) {
                let source = String(xml[start.upperBound..<end.lowerBound])
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                return source.isEmpty ? nil : source
            }
        }
        return nil
    }
    
    /// Extract text content between <tag> and </tag>
    private static func extractTag(_ tag: String, from xml: String) -> String? {
        // Try CDATA first
        let cdataPattern = "<\(tag)><![CDATA["
        if let cdataStart = xml.range(of: cdataPattern),
           let cdataEnd = xml.range(of: "]]></\(tag)>", range: cdataStart.upperBound..<xml.endIndex) {
            return String(xml[cdataStart.upperBound..<cdataEnd.lowerBound])
        }
        
        // Plain text
        guard let openEnd = xml.range(of: "<\(tag)>"),
              let closeStart = xml.range(of: "</\(tag)>", range: openEnd.upperBound..<xml.endIndex) else {
            return nil
        }
        
        let value = String(xml[openEnd.upperBound..<closeStart.lowerBound])
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return value.isEmpty ? nil : value
    }
}
