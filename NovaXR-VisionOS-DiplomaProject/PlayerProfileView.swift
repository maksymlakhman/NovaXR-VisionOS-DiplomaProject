//
//  PlayerProfileView.swift
//  NovaXR-VisionOS-DiplomaProject
//
//  Created by Maks Lakhman on 22.06.2025.
//

import SwiftUI
import Combine

struct PlayerStats {
    let name: String
    let title: String
    let xp: Int
    let completedTasks: Int
    let totalTasks: Int
    let completedLevels: Int
    let totalLevels: Int
    let discoveredMinerals: [String]
    let lastActivity: String
    let favoriteMineral: String
    let playTime: TimeInterval
    let rank: Int
    let achievements: [String]
    let avatarImage: String?
    let joinDate: String
    let bio: String
}

class PlayerProfileViewModel: ObservableObject {
    @Published var stats: PlayerStats?

    init() {
        loadStats()
    }

    func loadStats() {
        let levels = LevelProgressManager.shared.loadLevels()
        let tasks = levels.flatMap { $0.tasks }

        let completedTasks = tasks.filter { $0.isCompleted }.count
        let totalTasks = tasks.count
        let completedLevels = levels.filter { $0.tasks.allSatisfy { $0.isCompleted } }.count
        let totalLevels = levels.count

        let xp = completedTasks * 10 + completedLevels * 50
        let title = getTitle(for: xp)

        let discoveredMinerals = tasks
            .filter { $0.isCompleted }
            .map { $0.description }
            .compactMap { desc in
                if desc.contains("гематит") { return "Гематит" }
                if desc.contains("магнетит") { return "Магнетит" }
                if desc.contains("піролюзит") { return "Піролюзит" }
                if desc.contains("антрацит") { return "Антрацит" }
                return nil
            }
            .uniqued()

        let favoriteMineral = discoveredMinerals.randomElement() ?? "—"
        let playTime = TimeInterval(xp * 5)
        let rank = xp / 100 + 1

        let achievements = [
            completedTasks >= 10 ? "Майстер завдань" : nil,
            completedLevels >= 5 ? "Завойовник рівнів" : nil,
            discoveredMinerals.count >= 3 ? "Колекціонер мінералів" : nil
        ].compactMap { $0 }

        stats = PlayerStats(
            name: "Максим",
            title: title,
            xp: xp,
            completedTasks: completedTasks,
            totalTasks: totalTasks,
            completedLevels: completedLevels,
            totalLevels: totalLevels,
            discoveredMinerals: discoveredMinerals,
            lastActivity: "1 день тому",
            favoriteMineral: favoriteMineral,
            playTime: playTime,
            rank: rank,
            achievements: achievements,
            avatarImage: nil,
            joinDate: "Січень 2025",
            bio: "Пристрасний геолог, який досліджує мінерали та відкриває нові горизонти!"
        )
    }

    private func getTitle(for xp: Int) -> String {
        switch xp {
        case 0..<50: return "Юний геолог"
        case 50..<150: return "Гірничий технік"
        case 150..<300: return "Дослідник руд"
        case 300..<500: return "Майстер геології"
        default: return "Професор рудознавства"
        }
    }
}

extension Array where Element: Hashable {
    func uniqued() -> [Element] {
        Array(Set(self))
    }
}

extension TimeInterval {
    func formattedPlayTime() -> String {
        let hours = Int(self) / 3600
        let minutes = (Int(self) % 3600) / 60
        return String(format: "%02d:%02d", hours, minutes)
    }
}

struct PlayerProfileView: View {
    @StateObject private var viewModel = PlayerProfileViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                if let stats = viewModel.stats {
                    ZStack {
                        LinearGradient(gradient: Gradient(colors: [.blue.opacity(0.8), .cyan.opacity(0.6)]), startPoint: .top, endPoint: .bottom)
                            .frame(height: 250)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(.white.opacity(0.2), lineWidth: 2)
                            )

                        VStack(spacing: 12) {
                            if let avatar = stats.avatarImage {
                                Image(avatar)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 120, height: 120)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(.white, lineWidth: 3))
                                    .shadow(radius: 5)
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .frame(width: 120, height: 120)
                                    .foregroundStyle(.white.opacity(0.9))
                                    .overlay(Circle().stroke(.white, lineWidth: 3))
                                    .shadow(radius: 5)
                            }

                            Text(stats.name)
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)

                            Text("«\(stats.title)»")
                                .font(.system(size: 18, weight: .medium, design: .rounded))
                                .foregroundStyle(.white.opacity(0.8))
                        }
                        .padding(.top, 20)
                    }
                    .padding(.horizontal)

                    VStack(spacing: 24) {
                        VStack(spacing: 8) {
                            Text("Ранг: \(stats.rank)")
                                .font(.system(size: 22, weight: .semibold, design: .rounded))
                                .foregroundStyle(.blue)
                            Text("XP: \(stats.xp)")
                                .font(.system(size: 16, weight: .regular, design: .rounded))
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                        .background(.white.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(.gray.opacity(0.2), lineWidth: 1)
                        )

                        VStack(alignment: .leading, spacing: 16) {
                            Text("📊 Прогрес")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundStyle(.primary)

                            VStack(spacing: 12) {
                                ProgressView(value: Double(stats.completedTasks), total: Double(stats.totalTasks)) {
                                    Text("Завдання: \(stats.completedTasks)/\(stats.totalTasks)")
                                        .font(.system(size: 16, weight: .medium))
                                }
                                .progressViewStyle(.linear)
                                .tint(.cyan)
                                .padding(.vertical, 4)

                                ProgressView(value: Double(stats.completedLevels), total: Double(stats.totalLevels)) {
                                    Text("Рівні: \(stats.completedLevels)/\(stats.totalLevels)")
                                        .font(.system(size: 16, weight: .medium))
                                }
                                .progressViewStyle(.linear)
                                .tint(.green)
                                .padding(.vertical, 4)
                            }
                        }
                        .padding()
                        .background(.white.opacity(0.05))
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(.gray.opacity(0.2), lineWidth: 1)
                        )

                        VStack(alignment: .leading, spacing: 16) {
                            Text("🏆 Досягнення")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundStyle(.primary)

                            if stats.achievements.isEmpty {
                                Text("Ще немає досягнень.")
                                    .font(.system(size: 16))
                                    .foregroundStyle(.secondary)
                            } else {
                                LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible())], spacing: 12) {
                                    ForEach(stats.achievements, id: \.self) { achievement in
                                        Text(achievement)
                                            .font(.system(size: 14, weight: .medium))
                                            .padding(.vertical, 8)
                                            .padding(.horizontal, 12)
                                            .background(.yellow.opacity(0.2))
                                            .clipShape(Capsule())
                                            .overlay(Capsule().stroke(.yellow.opacity(0.5), lineWidth: 1))
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(.white.opacity(0.05))
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(.gray.opacity(0.2), lineWidth: 1)
                        )

                        VStack(alignment: .leading, spacing: 16) {
                            Text("🧪 Знайдені мінерали")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundStyle(.primary)

                            if stats.discoveredMinerals.isEmpty {
                                Text("Ще нічого не знайдено.")
                                    .font(.system(size: 16))
                                    .foregroundStyle(.secondary)
                            } else {
                                LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible())], spacing: 12) {
                                    ForEach(stats.discoveredMinerals, id: \.self) { mineral in
                                        HStack {
                                            Image(systemName: "sparkles")
                                                .foregroundStyle(.blue)
                                            Text(mineral)
                                                .font(.system(size: 14))
                                        }
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 12)
                                        .background(.blue.opacity(0.1))
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                    }
                                }
                            }

                            Text("⭐ Улюблений мінерал: \(stats.favoriteMineral)")
                                .font(.system(size: 16, weight: .medium))
                        }
                        .padding()
                        .background(.white.opacity(0.05))
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(.gray.opacity(0.2), lineWidth: 1)
                        )

                        VStack(alignment: .leading, spacing: 12) {
                            Text("ℹ️ Інформація")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundStyle(.primary)

                            VStack(alignment: .leading, spacing: 8) {
                                Text("Час у грі: \(stats.playTime.formattedPlayTime())")
                                    .font(.system(size: 16))
                                Text("Остання активність: \(stats.lastActivity)")
                                    .font(.system(size: 16))
                                Text("Дата приєднання: \(stats.joinDate)")
                                    .font(.system(size: 16))
                                Text("Біо: \(stats.bio)")
                                    .font(.system(size: 16))
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding()
                        .background(.white.opacity(0.05))
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(.gray.opacity(0.2), lineWidth: 1)
                        )
                    }
                    .padding(.horizontal)
                    .padding(.top, 16)
                    .padding(.bottom, 40)
                } else {
                    VStack {
                        ProgressView("Завантаження профілю...")
                            .tint(.blue)
                            .padding()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.gray.opacity(0.1))
                }
            }
        }
        .background(
            LinearGradient(gradient: Gradient(colors: [.gray.opacity(0.05), .gray.opacity(0.1)]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
        )
    }
}
