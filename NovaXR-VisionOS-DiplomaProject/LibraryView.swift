//
//  LibraryView.swift
//  NovaXR-VisionOS-DiplomaProject
//
//  Created by Maks Lakhman on 22.06.2025.
//

import SwiftUI
import RealityKit
import RealityKitContent
import Combine

struct LibraryView: View {
    let minerals = [
        Mineral(name: "Гематит", formula: "Fe₂O₃", properties: "Магнітний, червоний колір", experiment: "Тест на магнітність", modelName: "Hematite", level: 1, isUnlocked: true),
        Mineral(name: "Магнетит", formula: "Fe₃O₄", properties: "Сильномагнітний", experiment: "Симуляція магнітного поля", modelName: "Magnetite", level: 1, isUnlocked: true),
        Mineral(name: "Піролюзит", formula: "MnO₂", properties: "Окислювач", experiment: "Реакція окиснення", modelName: "Pyrolusite", level: 2, isUnlocked: true),
        Mineral(name: "Кам’яне вугілля", formula: "C", properties: "Горюче", experiment: "Симуляція горіння", modelName: "Coal", level: 2, isUnlocked: true),
        Mineral(name: "Буре вугілля", formula: "C", properties: "Низька теплотворність", experiment: "Тест теплотворності", modelName: "Lignite", level: 2, isUnlocked: true),
        Mineral(name: "Нафта", formula: "CnHm", properties: "В’язка рідина", experiment: "Симуляція буріння", modelName: "Oil", level: 2, isUnlocked: true),
        Mineral(name: "Природний газ", formula: "CH₄", properties: "Горючий газ", experiment: "Аналіз метану", modelName: "Gas", level: 2, isUnlocked: false),
        Mineral(name: "Горючі сланці", formula: "Органічні сполуки", properties: "Джерело синтетичного палива", experiment: "Переробка сланців", modelName: "Shale", level: 2, isUnlocked: false),
        Mineral(name: "Торф", formula: "Органічна маса", properties: "Вологоутримуючий", experiment: "Тест вологості", modelName: "Peat", level: 2, isUnlocked: false),
        Mineral(name: "Графіт", formula: "C", properties: "Електропровідний", experiment: "Тест електропровідності", modelName: "Graphite", level: 2, isUnlocked: false),
        Mineral(name: "Уран", formula: "UO₂", properties: "Радіоактивний", experiment: "Аналіз радіоактивності", modelName: "Uranium", level: 2, isUnlocked: false),
        Mineral(name: "Ільменіт", formula: "FeTiO₃", properties: "Джерело титану", experiment: "Симуляція сплаву", modelName: "Ilmenite", level: 2, isUnlocked: false),
        Mineral(name: "Цирконій", formula: "ZrSiO₄", properties: "Термостійкий", experiment: "Тест термостійкості", modelName: "Zirconium", level: 2, isUnlocked: false),
        Mineral(name: "Кам’яна сіль", formula: "NaCl", properties: "Розчинна", experiment: "Тест розчинності", modelName: "Salt", level: 2, isUnlocked: false),
        Mineral(name: "Каолін", formula: "Al₂Si₂O₅(OH)₄", properties: "Пластичний", experiment: "Симуляція кераміки", modelName: "Kaolin", level: 2, isUnlocked: false),
        Mineral(name: "Сірка", formula: "S", properties: "Хімічно активна", experiment: "Нейтралізація сірководню", modelName: "Sulfur", level: 2, isUnlocked: false),
        Mineral(name: "Вогнетривкі глини", formula: "Al₂O₃·SiO₂", properties: "Термостійкі", experiment: "Тест вогнетривкості", modelName: "Fireclay", level: 2, isUnlocked: false),
        Mineral(name: "Фосфорити", formula: "Ca₅(PO₄)₃(F,Cl,OH)", properties: "Джерело фосфору", experiment: "Аналіз фосфатів", modelName: "Phosphorite", level: 2, isUnlocked: false),
        Mineral(name: "Бурштин", formula: "C₁₀H₁₆O", properties: "Органічна смола", experiment: "Тест на статичну електрику", modelName: "Amber", level: 2, isUnlocked: false),
        Mineral(name: "Мінеральні води", formula: "H₂O+іони", properties: "Лікувальні", experiment: "Аналіз складу", modelName: "MineralWater", level: 2, isUnlocked: false),
        Mineral(name: "Літій", formula: "Li", properties: "Легкий метал", experiment: "Симуляція акумулятора", modelName: "Lithium", level: 2, isUnlocked: false)
    ]
    
    @Environment(\.openWindow) var openWindow
    @Environment(\.supportsMultipleWindows) private var supportsMultipleWindows
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Розблоковані копалини")) {
                    ForEach(minerals.filter { $0.isUnlocked }) { mineral in
                        NavigationLink(
                            destination: MineralDetailView(mineral: mineral),
                            label: {
                                Text(mineral.name)
                            }
                        )
                    }
                }
                Section(header: Text("Заблоковані копалини")) {
                    ForEach(minerals.filter { !$0.isUnlocked }) { mineral in
                        Text(mineral.name)
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("Бібліотека копалин")
            .ornament(
                visibility: .visible,
                attachmentAnchor: .scene(.bottom),
                contentAlignment: .bottom) {
                    Button {
                        openWindow(id: "MineralCart")
                    } label: {
                        Text("Карта Копалин")
                            .padding()
                    }
                    .glassBackgroundEffect(
                        in: RoundedRectangle(
                            cornerRadius: 32,
                            style: .continuous
                        )
                    )
                    .opacity(supportsMultipleWindows ? 1 : 0)
                }
        }
    }
}

struct Mineral: Identifiable {
    let id = UUID()
    let name: String
    let formula: String
    let properties: String
    let experiment: String
    let modelName: String
    let level: Int
    let isUnlocked: Bool
}

struct MineralDetailView: View {
    @State private var rotationAngleX: Angle = .degrees(0)
    @State private var rotationAngleY: Angle = .degrees(0)
    let mineral: Mineral
    
    var body: some View {
        VStack {
            Text(mineral.name)
                .font(.largeTitle)
            Text("Формула: \(mineral.formula)")
                .font(.title2)
            Text("Властивості: \(mineral.properties)")
                .font(.body)
            
            Model3D(named: mineral.modelName) { model in
                model
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(0.45)
                    .rotation3DEffect(
                        rotationAngleX,
                        axis: (x: 1, y: 0, z: 0)
                    )
                    .rotation3DEffect(
                        rotationAngleY,
                        axis: (x: 0, y: 1, z: 0)
                    )
                    .gesture(
                        DragGesture()
                            .onChanged { value in

                                let degreesY = Angle.degrees(value.translation.width)
                                rotationAngleY = .degrees(0) + degreesY

                                let degreesX = Angle.degrees(value.translation.height)
                                rotationAngleX = .degrees(0) + degreesX
                            }
                    )
            } placeholder: {
                ProgressView()
            }
            
            NavigationLink(
                destination: ExperimentView(mineral: mineral),
                label: {
                    Text("Перейти до експерименту")
                        .padding()
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            )
            .padding(.top)
        }
        .padding()
        .navigationTitle(mineral.name)
    }
}

struct ExperimentView: View {
    let mineral: Mineral
    
    var body: some View {
        VStack {
            Text("Експеримент: \(mineral.experiment)")
                .font(.largeTitle)
            Text("Тут буде відображено відео або зображення експерименту для \(mineral.name)")
                .font(.body)
                .padding()
        }
        .navigationTitle(mineral.experiment)
    }
}

