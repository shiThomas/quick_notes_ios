//
//  ContentView.swift
//  quick_notes_ios
//
//  Created by Weicheng  Shi on 1/21/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var notesManager = NotesManager()
    @State private var isShowingNewNote = false
    @State private var editingNote: Note?
    
    var body: some View {
        NavigationView {
            List {
                ForEach(notesManager.notes) { note in
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
                    Button(action: { isShowingNewNote = true }) {
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
                NoteEditorView(notesManager: notesManager)
            }
            .sheet(item: $editingNote) { note in
                NoteEditorView(notesManager: notesManager, editingNote: note)
            }
        }
    }
    
    private func moveNotes(from source: IndexSet, to destination: Int) {
        notesManager.notes.move(fromOffsets: source, toOffset: destination)
        notesManager.saveNotes()
    }
    
    private func deleteNotes(at offsets: IndexSet) {
        notesManager.notes.remove(atOffsets: offsets)
        notesManager.saveNotes()
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
    @ObservedObject var notesManager: NotesManager
    var editingNote: Note?
    
    @State private var noteContent: String = ""
    
    init(notesManager: NotesManager, editingNote: Note? = nil) {
        self.notesManager = notesManager
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
                               let index = notesManager.notes.firstIndex(where: { $0.id == editingNote.id }) {
                                notesManager.notes[index] = Note(id: editingNote.id, content: noteContent, timestamp: Date())
                            } else {
                                notesManager.notes.append(Note(content: noteContent))
                            }
                            notesManager.saveNotes()
                            dismiss()
                        }
                        .frame(minWidth: 44, minHeight: 44)
                        .disabled(noteContent.isEmpty)
                    }
                }
        }
    }
}

#Preview {
    ContentView()
}
