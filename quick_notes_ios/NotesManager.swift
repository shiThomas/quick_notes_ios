import Foundation

class NotesManager: ObservableObject {
    @Published var notes: [Note] = []
    
    private var notesFilePath: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("notes.json")
    }
    
    init() {
        loadNotes()
    }
    
    func saveNotes() {
        do {
            let data = try JSONEncoder().encode(notes)
            try data.write(to: notesFilePath, options: [.atomicWrite, .completeFileProtection])
            print("Notes saved successfully to \(notesFilePath.path)")
        } catch {
            print("Failed to save notes: \(error.localizedDescription)")
        }
    }
    
    func loadNotes() {
        do {
            let data = try Data(contentsOf: notesFilePath)
            notes = try JSONDecoder().decode([Note].self, from: data)
            print("Notes loaded successfully: \(notes.count) notes")
        } catch {
            print("Failed to load notes: \(error.localizedDescription)")
            notes = []
        }
    }
} 