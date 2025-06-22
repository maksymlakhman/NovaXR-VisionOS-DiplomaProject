//
//  MainView.swift
//  NovaXR-VisionOS-DiplomaProject
//
//  Created by Maks Lakhman on 22.06.2025.
//

import SwiftUI
import RealityKit
import RealityKitContent
import Combine

struct MainView: View {
    @Environment(\.openWindow) var openWindow
    @Environment(\.supportsMultipleWindows) private var supportsMultipleWindows
    @EnvironmentObject private var backgroundModel: BackgroundFullSpaceModel
    var body: some View {
        TabView {
            CareerView()
                .tabItem {
                    Label("Кар'єра", systemImage: "map")
                }
            LibraryView()
                .tabItem {
                    Label("Бібліотека", systemImage: "book")
                }
            SettingsView()
                .tabItem {
                    Label("Налаштування", systemImage: "gear")
                }
        }
        .environmentObject(backgroundModel)
    }
}
