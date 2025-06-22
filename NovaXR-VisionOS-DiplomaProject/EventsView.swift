//
//  EventsView.swift
//  NovaXR-VisionOS-DiplomaProject
//
//  Created by Maks Lakhman on 22.06.2025.
//

import SwiftUI
import Combine

struct EventsView: View {
    @StateObject private var viewModel = EventsViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Події")
                    .font(.largeTitle.bold())
                    .padding(.top)

                ForEach(viewModel.events) { event in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(event.title)
                                .font(.title3.bold())
                            Spacer()
                            Button(action: {
                                viewModel.toggleParticipation(for: event.id)
                            }) {
                                Text(event.isParticipating ? "Скасувати" : "Узяти участь")
                                    .font(.subheadline)
                                    .padding(6)
                                    .background(event.isParticipating ? Color.red : Color.green)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                        }

                        Text(event.description)
                            .font(.body)
                            .foregroundStyle(.secondary)

                        Text("Дата: \(event.date, formatter: dateFormatter)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        HStack {
                            Label(event.reward, systemImage: "gift.fill")
                                .font(.subheadline)
                                .foregroundColor(.yellow)
                        }
                        .padding(6)
                        .background(.ultraThinMaterial)
                        .cornerRadius(8)
                    }
                    .padding()
                    .background(.thinMaterial)
                    .cornerRadius(16)
                    .shadow(radius: 5)
                }
            }
            .padding()
        }
    }

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
}

class EventsViewModel: ObservableObject {
    @Published var events: [Event] = []

    init() {
        loadEvents()
    }

    func loadEvents() {
        events = LevelProgressManager.shared.loadEvents()
    }

    func toggleParticipation(for eventID: UUID) {
        if let index = events.firstIndex(where: { $0.id == eventID }) {
            events[index].isParticipating.toggle()
            LevelProgressManager.shared.saveEvents(events)
        }
    }
}

