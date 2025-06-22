//
//  LeaderboardView.swift
//  NovaXR-VisionOS-DiplomaProject
//
//  Created by Maks Lakhman on 22.06.2025.
//

import SwiftUI
import Combine

struct LeaderboardEntry: Identifiable {
    let id = UUID()
    let name: String
    let rank: Int
    let xp: Int
}

class LeaderboardViewModel: ObservableObject {
    @Published var entries: [LeaderboardEntry] = []

    init() {
        loadLeaderboard()
    }

    func loadLeaderboard() {
        // Get player's stats
        let playerViewModel = PlayerProfileViewModel()
        playerViewModel.loadStats()
        guard let playerStats = playerViewModel.stats else { return }

        // Simulate other players (in a real app, this would come from a server)
        let otherPlayers = [
            LeaderboardEntry(name: "Олена", rank: 1, xp: 500),
            LeaderboardEntry(name: "Ігор", rank: 2, xp: 400),
            LeaderboardEntry(name: "Софія", rank: 3, xp: 300)
        ]

        // Add player to leaderboard
        var allEntries = otherPlayers
        allEntries.append(LeaderboardEntry(name: playerStats.name, rank: playerStats.rank, xp: playerStats.xp))
        
        // Sort by XP descending
        entries = allEntries.sorted { $0.xp > $1.xp }.enumerated().map { (index, entry) in
            LeaderboardEntry(name: entry.name, rank: index + 1, xp: entry.xp)
        }
    }
}

struct LeaderboardView: View {
    @StateObject private var viewModel = LeaderboardViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Рейтинг")
                    .font(.largeTitle.bold())
                    .padding(.top)

                ForEach(viewModel.entries) { entry in
                    HStack(spacing: 16) {
                        Text("\(entry.rank)")
                            .font(.title2.bold())
                            .frame(width: 40)
                            .foregroundColor(.yellow)

                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.cyan)
                            .padding()
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())

                        VStack(alignment: .leading, spacing: 4) {
                            Text(entry.name)
                                .font(.headline)
                            Text("XP: \(entry.xp)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
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
