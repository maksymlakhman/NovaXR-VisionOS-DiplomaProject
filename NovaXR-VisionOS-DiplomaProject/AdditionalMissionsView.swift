//
//  AdditionalMissionsView.swift
//  NovaXR-VisionOS-DiplomaProject
//
//  Created by Maks Lakhman on 22.06.2025.
//

import SwiftUI

struct AdditionalMission: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let reward: String
    var isCompleted: Bool
}

struct AdditionalMissionsView: View {
    @State private var missions: [AdditionalMission] = [
        AdditionalMission(title: "Знайди рідкісний мінерал",
                          description: "Виявити рідкісний екземпляр берилу серед інших зразків.",
                          reward: "Сканер мінералів", isCompleted: false),
        AdditionalMission(title: "Очисть шахту",
                          description: "Прибери уламки породи, щоб отримати доступ до нового тунелю.",
                          reward: "Покращене свердло", isCompleted: true),
        AdditionalMission(title: "Зберіть уламки обсидіану",
                          description: "Використай маніпулятор для збирання шматків обсидіану.",
                          reward: "Щит для робота", isCompleted: false)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Додаткові місії")
                    .font(.largeTitle.bold())
                    .padding(.top)

                ForEach(missions) { mission in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(mission.title)
                                .font(.title3.bold())
                            Spacer()
                            Image(systemName: mission.isCompleted ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(mission.isCompleted ? .green : .gray)
                        }

                        Text(mission.description)
                            .font(.body)
                            .foregroundStyle(.secondary)

                        HStack {
                            Label(mission.reward, systemImage: "gift.fill")
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
}

