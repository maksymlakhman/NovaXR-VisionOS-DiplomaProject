//
//  SettingsView.swift
//  NovaXR-VisionOS-DiplomaProject
//
//  Created by Maks Lakhman on 22.06.2025.
//

import SwiftUI
import RealityKit
import RealityKitContent
import Combine

struct SettingsView: View {
    @State private var notificationsEnabled: Bool = true
    @State private var immersiveMode: Bool = false
    @State private var volumeLevel: Double = 0.5
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Основні")) {
                    Toggle("Увімкнути Сповіщення", isOn: $notificationsEnabled)
                    Toggle("Immersive Mode", isOn: $immersiveMode)
                }
                Section(header: Text("Аудіо")) {
                    Slider(value: $volumeLevel, in: 0...1, step: 0.1) {
                        Text("Звук")
                    } minimumValueLabel: {
                        Image(systemName: "speaker.fill")
                    } maximumValueLabel: {
                        Image(systemName: "speaker.wave.3.fill")
                    }
                }
                Section(header: Text("Обліковий Запис")) {
                    Button("Вийти") {
                        print("User signed out")
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Налаштування")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        print("Save settings")
                    }) {
                        Text("Зберегти")
                    }
                }
            }
        }
    }
}

