//
//  TeamView.swift
//  NovaXR-VisionOS-DiplomaProject
//
//  Created by Maks Lakhman on 22.06.2025.
//

import SwiftUI
import Combine

struct TeamView: View {
    @StateObject private var viewModel = TeamViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Команда")
                    .font(.largeTitle.bold())
                    .padding(.top)

                ForEach(viewModel.teamMembers) { member in
                    HStack(spacing: 16) {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.cyan)
                            .padding()
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())

                        VStack(alignment: .leading, spacing: 4) {
                            Text(member.name)
                                .font(.headline)
                            Text("Роль: \(member.role)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text("Внесок: \(member.contribution) очок")
                                .font(.subheadline)
                                .foregroundColor(.yellow)
                        }

                        Spacer()
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
}

class TeamViewModel: ObservableObject {
    @Published var teamMembers: [TeamMember] = []

    init() {
        loadTeam()
    }

    func loadTeam() {
        teamMembers = LevelProgressManager.shared.loadTeam()
    }
}
