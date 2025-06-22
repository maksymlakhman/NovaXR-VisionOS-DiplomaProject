//
//  LevelsListView.swift
//  NovaXR-VisionOS-DiplomaProject
//
//  Created by Maks Lakhman on 22.06.2025.
//

import SwiftUI
import RealityKit
import RealityKitContent
import Combine

struct LevelsListView: View {
    @EnvironmentObject private var backgroundModel: BackgroundFullSpaceModel
    @State private var levels: [Level] = LevelProgressManager.shared.loadLevels()
    @State private var levelCompletedMessage: String?

    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    Text("Рівні")
                        .font(.title)
                    List(levels) { level in
                        NavigationLink(
                            destination: LevelDetailView(level: level, levels: $levels, backgroundModel: backgroundModel),
                            label: {
                                Text(level.title)
                                    .foregroundColor(level.isUnlocked ? .primary : .gray)
                            }
                        )
                        .disabled(!level.isUnlocked)
                    }
                }
                .navigationTitle("Рівні")
                .frame(maxWidth: .infinity)
                VStack {
                    Spacer()
                    ToastView(message: levelCompletedMessage ?? "", isShowing: .init(get: {
                        levelCompletedMessage != nil
                    }, set: { _ in
                        levelCompletedMessage = nil
                    }))
                    .padding(.bottom, 20)
                }
            }
            .onAppear {
                print("LevelsListView loaded with levels: \(levels.map { "\($0.id): \($0.title)" })")
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("TaskCompleted"))) { notification in
                if let userInfo = notification.userInfo,
                   let levelId = userInfo["levelId"] as? Int,
                   let taskId = userInfo["taskId"] as? Int {
                    if let levelIndex = levels.firstIndex(where: { $0.id == levelId }),
                       let taskIndex = levels[levelIndex].tasks.firstIndex(where: { $0.id == taskId }) {
                        // Mark task as completed
                        levels[levelIndex].tasks[taskIndex].isCompleted = true
                        print("Task \(taskId) completed for level \(levelId)")

                        // Check if all tasks in the level are completed
                        if levels[levelIndex].tasks.allSatisfy({ $0.isCompleted }) {
                            // Unlock the next level if it exists
                            if levelIndex + 1 < levels.count {
                                levels[levelIndex + 1].isUnlocked = true
                                print("Unlocked level \(levels[levelIndex + 1].id)")
                                levelCompletedMessage = "Рівень \(levels[levelIndex].title) завершено!" // Show toast
                            }
                        }

                        // Force UI refresh and save
                        levels = levels
                        LevelProgressManager.shared.saveLevels(levels)
                    }
                }
            }
        }
    }
}

struct ToastView: View {
    let message: String
    @Binding var isShowing: Bool
    
    var body: some View {
        if isShowing {
            Text(message)
                .padding()
                .background(Color.black.opacity(0.7))
                .foregroundColor(.white)
                .cornerRadius(10)
                .transition(.opacity)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            isShowing = false
                        }
                    }
                }
        }
    }
}
