//
//  LevelDetailView.swift
//  NovaXR-VisionOS-DiplomaProject
//
//  Created by Maks Lakhman on 22.06.2025.
//

import SwiftUI
import RealityKit
import RealityKitContent
import Combine

struct LevelDetailView: View {
    let level: Level
    @Binding var levels: [Level]
    @ObservedObject var backgroundModel: BackgroundFullSpaceModel
    @EnvironmentObject var gameProgress: GameProgressViewModel
    @EnvironmentObject var appState: AppState
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersive
    @State private var showImmersiveSpace = false
    @State private var currentImmersiveSpaceId: String?
    @State private var showTaskCompletionAlert = false
    @State private var showLevelCompletedAlert = false

    var body: some View {
        VStack {
            Text(level.title)
                .font(.title)
            List(level.tasks) { task in
                Button(action: {
                    openImmersiveSpace(for: task, levelId: level.id)
                    print("Opening task: id=\(task.id), viewType=\(task.viewType) for level: \(level.id)")
                }) {
                    HStack {
                        Text(task.description)
                            .foregroundColor(task.isCompleted ? .green : .white)
                        Spacer()
                        if task.isCompleted {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(task.isCompleted ? Color.green.opacity(0.1) : Color.clear)
                    .cornerRadius(8)
                }
                .disabled(task.isCompleted)
            }
        }
        .navigationTitle("Завдання")
        .alert("Завдання завершено!", isPresented: $showTaskCompletionAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Ви успішно завершили завдання!")
        }
        .alert("Рівень завершено!", isPresented: $showLevelCompletedAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Вітаємо! Ви завершили всі завдання рівня \(level.title). Наступний рівень розблоковано!")
        }
        .onAppear {
            print("LevelDetailView loaded for level: \(level.id)")
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("TaskCompleted"))) { notification in
            print("LevelDetailView received TaskCompleted notification: \(notification.userInfo ?? [:])")
            if let userInfo = notification.userInfo,
               let levelId = userInfo["levelId"] as? Int,
               let taskId = userInfo["taskId"] as? Int {
                if let levelIndex = levels.firstIndex(where: { $0.id == levelId }),
                   let taskIndex = levels[levelIndex].tasks.firstIndex(where: { $0.id == taskId }) {
                    levels[levelIndex].tasks[taskIndex].isCompleted = true
                    showTaskCompletionAlert = true
                    print("Task \(taskId) marked as completed for level \(levelId)")
                    
                    if levels[levelIndex].tasks.allSatisfy({ $0.isCompleted }) {
                        showLevelCompletedAlert = true
                        if levelIndex + 1 < levels.count {
                            levels[levelIndex + 1].isUnlocked = true
                            print("Unlocked level \(levels[levelIndex + 1].id)")
                        }
                    }
                    
                    LevelProgressManager.shared.saveLevels(levels)
                    Task {
                        await dismissImmersive()
                        showImmersiveSpace = false
                        currentImmersiveSpaceId = nil
                    }
                } else {
                    print("Failed to find level or task: levelId=\(levelId), taskId=\(taskId)")
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack {
                    Spacer()
                    Button(action: {
                        Task {
                            await dismissImmersive()
                            showImmersiveSpace = false
                            currentImmersiveSpaceId = nil
                            print("Closed immersive space")
                        }
                    }) {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .padding()
                            .foregroundColor(.white)
                    }
                    .padding(.top, 16)
                    .padding(.trailing, 16)
                    .disabled(!showImmersiveSpace)
                }
            }
        }
    }
    
    private func openImmersiveSpace(for task: LevelTask, levelId: Int) {
        Task {
            if showImmersiveSpace {
                await dismissImmersive()
                showImmersiveSpace = false
                currentImmersiveSpaceId = nil
            }
            
            appState.currentLevelId = levelId
            appState.currentTaskId = task.id
            print("Set appState: levelId=\(levelId), taskId=\(task.id)")
            
            let result = await openImmersiveSpace(id: task.viewType)
            switch result {
            case .opened:
                print("Successfully opened immersive space: \(task.viewType)")
                backgroundModel.setBackground(for: task.id)
                showImmersiveSpace = true
                currentImmersiveSpaceId = task.viewType
            case .error, .userCancelled:
                print("Failed to open immersive space: \(task.viewType)")
                showImmersiveSpace = false
                currentImmersiveSpaceId = nil
            @unknown default:
                print("Unknown result for immersive space: \(task.viewType)")
                showImmersiveSpace = false
                currentImmersiveSpaceId = nil
            }
        }
    }
}

