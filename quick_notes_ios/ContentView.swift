//
//  ContentView.swift
//  quick_notes_ios
//
//  Created by Weicheng  Shi on 1/21/25.
//

import SwiftUI

struct ContentView: View {
    @State private var notes: [Note] = []
    @State private var isShowingNewNote = false
    @State private var editingNote: Note?
    
    var body: some View {
        NavigationView {
            List {
                ForEach(notes) { note in
                    NoteRow(note: note)
                        .onTapGesture {
                            editingNote = note
                        }
                }
                .onMove(perform: moveNotes)
                .onDelete(perform: deleteNotes)
            }
            .navigationTitle("Quick Notes")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        isShowingNewNote = true
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 20))
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                        .frame(minWidth: 44, minHeight: 44)
                }
            }
            .sheet(isPresented: $isShowingNewNote) {
                NoteEditorView(notes: $notes)
            }
            .sheet(item: $editingNote) { note in
                NoteEditorView(notes: $notes, editingNote: note)
            }
        }
        .onAppear(perform: loadNotes)
    }
    
    private func moveNotes(from source: IndexSet, to destination: Int) {
        notes.move(fromOffsets: source, toOffset: destination)
        saveNotes()
    }
    
    private func deleteNotes(at offsets: IndexSet) {
        notes.remove(atOffsets: offsets)
        saveNotes()
    }
    
    private func saveNotes() {
        if let encoded = try? JSONEncoder().encode(notes) {
            UserDefaults.standard.set(encoded, forKey: "SavedNotes")
        }
    }
    
    private func loadNotes() {
        if let savedNotes = UserDefaults.standard.data(forKey: "SavedNotes"),
           let decodedNotes = try? JSONDecoder().decode([Note].self, from: savedNotes) {
            notes = decodedNotes
        }
    }
}

struct NoteRow: View {
    let note: Note
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(note.content)
                .lineLimit(2)
                .font(.body)
                .padding(.vertical, 4)
            Text(note.timestamp, style: .date)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(minHeight: 44)
        .contentShape(Rectangle())
    }
}

struct NoteEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var notes: [Note]
    var editingNote: Note?
    
    @State private var noteContent: String = ""
    
    init(notes: Binding<[Note]>, editingNote: Note? = nil) {
        self._notes = notes
        self.editingNote = editingNote
        self._noteContent = State(initialValue: editingNote?.content ?? "")
    }
    
    var body: some View {
        NavigationView {
            TextEditor(text: $noteContent)
                .font(.body)
                .padding()
                .navigationTitle(editingNote == nil ? "New Note" : "Edit Note")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            dismiss()
                        }
                        .frame(minWidth: 44, minHeight: 44)
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Save") {
                            if let editingNote = editingNote,
                               let index = notes.firstIndex(where: { $0.id == editingNote.id }) {
                                notes[index] = Note(id: editingNote.id, content: noteContent)
                            } else {
                                notes.append(Note(content: noteContent))
                            }
                            dismiss()
                        }
                        .frame(minWidth: 44, minHeight: 44)
                        .disabled(noteContent.isEmpty)
                    }
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
