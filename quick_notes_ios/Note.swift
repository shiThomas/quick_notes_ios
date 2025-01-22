import Foundation

struct Note: Identifiable, Codable {
    var id: UUID
    var content: String
    var timestamp: Date
    
    init(id: UUID = UUID(), content: String = "", timestamp: Date = Date()) {
        self.id = id
        self.content = content
        self.timestamp = timestamp
    }
} 