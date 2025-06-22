//
//  LevelProgressManager.swift
//  NovaXR-VisionOS-DiplomaProject
//
//  Created by Maks Lakhman on 22.06.2025.
//

import SwiftUI

struct Level: Identifiable, Codable {
    let id: Int
    let title: String
    var isUnlocked: Bool
    var tasks: [LevelTask]
}

struct LevelTask: Identifiable, Codable {
    let id: Int
    let description: String
    var isCompleted: Bool
    let viewType: String
}

struct TeamMember: Identifiable, Codable {
    let id: UUID
    let name: String
    let role: String
    let contribution: Int
}

struct Event: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
    let date: Date
    let reward: String
    var isParticipating: Bool
}

class LevelProgressManager {
    static let shared = LevelProgressManager()
    private let levelsKey = "LevelsKey"
    private let teamKey = "TeamKey"
    private let eventsKey = "EventsKey"

    func saveLevels(_ levels: [Level]) {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(levels)
            UserDefaults.standard.set(data, forKey: levelsKey)
            UserDefaults.standard.synchronize()
        } catch {
            print("Failed to save levels: \(error)")
        }
    }

    func loadLevels() -> [Level] {
        guard let data = UserDefaults.standard.data(forKey: levelsKey) else {
            let defaultLevels = [
                Level(id: 1, title: "Криворізькі залізні руди", isUnlocked: true, tasks: [
                    LevelTask(id: 1, description: "Знайди гематит серед інших мінералів у віртуальній шахті", isCompleted: false, viewType: "FullSpace"),
                    LevelTask(id: 2, description: "Створи магнітне поле для левітації магнетиту", isCompleted: false, viewType: "Progressive")
                ]),
                Level(id: 2, title: "Марганцеві руди Придніпров’я", isUnlocked: false, tasks: [
                    LevelTask(id: 3, description: "Скануй піролюзит для визначення складу (MnO₂)", isCompleted: false, viewType: "Progressive"),
                    LevelTask(id: 4, description: "Нейтралізуй витік марганцевих сполук реагентами", isCompleted: false, viewType: "FullSpace")
                ]),
                Level(id: 3, title: "Вугілля Донбасу", isUnlocked: false, tasks: [
                    LevelTask(id: 5, description: "Проведи спектральний аналіз антрациту (вуглець)", isCompleted: false, viewType: "CoalSpace"),
                    LevelTask(id: 6, description: "Симулюй горіння вугілля, регулюючи кисень", isCompleted: false, viewType: "FullSpace")
                ])
            ]
            saveLevels(defaultLevels)
            return defaultLevels
        }
        do {
            let decoder = JSONDecoder()
            return try decoder.decode([Level].self, from: data)
        } catch {
            print("Failed to load levels: \(error)")
            return []
        }
    }

    func saveTeam(_ team: [TeamMember]) {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(team)
            UserDefaults.standard.set(data, forKey: teamKey)
            UserDefaults.standard.synchronize()
        } catch {
            print("Failed to save team: \(error)")
        }
    }

    func loadTeam() -> [TeamMember] {
        guard let data = UserDefaults.standard.data(forKey: teamKey) else {
            let defaultTeam = [
                TeamMember(id: UUID(), name: "Олена", role: "Геолог", contribution: 50),
                TeamMember(id: UUID(), name: "Ігор", role: "Інженер", contribution: 30),
                TeamMember(id: UUID(), name: "Софія", role: "Хімік", contribution: 20)
            ]
            saveTeam(defaultTeam)
            return defaultTeam
        }
        do {
            let decoder = JSONDecoder()
            return try decoder.decode([TeamMember].self, from: data)
        } catch {
            print("Failed to load team: \(error)")
            return []
        }
    }

    func saveEvents(_ events: [Event]) {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(events)
            UserDefaults.standard.set(data, forKey: eventsKey)
            UserDefaults.standard.synchronize()
        } catch {
            print("Failed to save events: \(error)")
        }
    }

    func loadEvents() -> [Event] {
        guard let data = UserDefaults.standard.data(forKey: eventsKey) else {
            let defaultEvents = [
                Event(id: UUID(), title: "Експедиція до шахти", description: "Досліджуй нову шахту для пошуку гематиту.", date: Date().addingTimeInterval(-86400), reward: "100 XP", isParticipating: false),
                Event(id: UUID(), title: "Аналіз вугілля", description: "Проведи аналіз зразків антрациту.", date: Date().addingTimeInterval(86400), reward: "Сканер", isParticipating: false)
            ]
            saveEvents(defaultEvents)
            return defaultEvents
        }
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode([Event].self, from: data)
        } catch {
            print("Failed to load events: \(error)")
            return []
        }
    }
}
