//
//  CareerView.swift
//  NovaXR-VisionOS-DiplomaProject
//
//  Created by Maks Lakhman on 22.06.2025.
//

import SwiftUI
import RealityKit
import RealityKitContent
import Combine

struct CareerView: View {
    @EnvironmentObject private var backgroundModel: BackgroundFullSpaceModel
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    ScrollView(.horizontal, showsIndicators: true) {
                        HStack(spacing: 15) {
                            NavigationLink {
                                PlayerProfileView()
                            } label: {
                                Text("Профіль")
                            }
                            
                            NavigationLink {
                                GameMapView()
                            } label: {
                                Text("Карта Гри")
                            }
                            
                            NavigationLink {
                                AdditionalMissionsView()
                            } label: {
                                Text("Додаткові Місії")
                            }
                            
                            NavigationLink {
                                InventarView()
                            } label: {
                                Text("Інвентар")
                            }
                            
                            
                            NavigationLink {
                                TeamView()
                            } label: {
                                Text("Команда")
                            }
                            
                            
                            NavigationLink {
                                LeaderboardView()
                            } label: {
                                Text("Рейтинг")
                            }
                            
                            
                            NavigationLink {
                                EventsView()
                            } label: {
                                Text("Події")
                            }
                        }
                        .padding(.vertical, 10)
                    }
                }
                .padding(.horizontal, 20)
                HStack {
                    LevelsListView()
                    RobotStatusView()
                }
            }
            .environmentObject(backgroundModel)
            .navigationBarTitleDisplayMode(.large)
            .navigationTitle("Career")
            .font(.largeTitle)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Option 1") { print("Home Option 1") }
                        Button("Option 2") { print("Home Option 2") }
                        Button("Option 3") { print("Home Option 3") }
                    } label: {
                        Label("Menu", systemImage: "ellipsis.circle")
                    }
                }
            }
        }
    }
}

