//
//  NovaXR_VisionOS_DiplomaProjectApp.swift
//  NovaXR-VisionOS-DiplomaProject
//
//  Created by Maks Lakhman on 22.06.2025.
//

import SwiftUI
import Combine

class BackgroundFullSpaceModel: ObservableObject {
    @Published var backgroundFullSpaceRaw: FullBackgroundType = .fullBackgroundImage1
    
    func setBackground(for taskId: Int) {
        switch taskId {
        case 1:
            backgroundFullSpaceRaw = .fullBackgroundImage2
        case 2:
            backgroundFullSpaceRaw = .fullBackgroundImage1
        case 3:
            backgroundFullSpaceRaw = .fullBackgroundImage2
        default:
            backgroundFullSpaceRaw = .fullBackgroundImage1
        }
    }
}

enum FullBackgroundType: String {
    case fullBackgroundImage1 = "FullBackground1"
    case fullBackgroundImage2 = "FullBackground2"
}

class GameProgressViewModel: ObservableObject {
    @Published var taskCompleted: (levelId: Int, taskId: Int)? = nil
    @Published var levelCompleted: Int? = nil
    
    func resetNotifications() {
        taskCompleted = nil
        levelCompleted = nil
    }
}

class AppState: ObservableObject {
    @Published var currentLevelId: Int = 1
    @Published var currentTaskId: Int = 1
}

@main
struct NovaXR_VisionOS_DiplomaProjectApp: App {

    @StateObject var backgroundFullSpaceRaw = BackgroundFullSpaceModel()
    @StateObject var gameProgress = GameProgressViewModel()
    @StateObject var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            SplashView()
                .environmentObject(backgroundFullSpaceRaw)
                .environmentObject(gameProgress)
                .environmentObject(appState)
        }
        WindowGroup(id: "MineralCart") {
            MineralCartWindowView()
                .environmentObject(backgroundFullSpaceRaw)
                .environmentObject(gameProgress)
                .environmentObject(appState)
        }
        ImmersiveSpace(id: "TrainingSpace") {
            // TrainingView(levelId: appState.currentLevelId, taskId: appState.currentTaskId)
            // .environmentObject(backgroundFullSpaceRaw)
            // .environmentObject(gameProgress)
            // .environmentObject(appState)
        }
        .immersionStyle(selection: .constant(.full), in: .full)
        ImmersiveSpace(id: "FullSpace") {
            FullSpaceView(levelId: appState.currentLevelId, taskId: appState.currentTaskId)
                .environmentObject(backgroundFullSpaceRaw)
                .environmentObject(gameProgress)
                .environmentObject(appState)
        }
        .immersionStyle(selection: .constant(.full), in: .full)
        ImmersiveSpace(id: "Progressive") {
            ImmersiveView(levelId: appState.currentLevelId, taskId: appState.currentTaskId)
                .environmentObject(backgroundFullSpaceRaw)
                .environmentObject(gameProgress)
                .environmentObject(appState)
        }
        .immersionStyle(selection: .constant(.progressive), in: .progressive)
        ImmersiveSpace(id: "CoalSpace") {
            //            CoalView(levelId: 0, taskId: 0) // Will be set dynamically
            //                .environmentObject(backgroundFullSpaceRaw)
        }
        .immersionStyle(selection: .constant(.full), in: .full)
        ImmersiveSpace(id: "BrownCoalSpace") {
            // BrownCoalView(levelId: 0, taskId: 0)
            // .environmentObject(backgroundFullSpaceRaw)
        }
        .immersionStyle(selection: .constant(.full), in: .full)
    }
}
