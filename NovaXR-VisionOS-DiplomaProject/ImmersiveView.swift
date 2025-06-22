//
//  ImmersiveView.swift
//  NovaXR-VisionOS-DiplomaProject
//
//  Created by Maks Lakhman on 22.06.2025.
//

import SwiftUI
import RealityKit
import RealityKitContent
import Combine

@MainActor
struct ImmersiveView: View {
    let levelId: Int
    let taskId: Int
    @EnvironmentObject private var backgroundModel: BackgroundFullSpaceModel
    @EnvironmentObject private var gameProgress: GameProgressViewModel
    @Environment(\.dismissImmersiveSpace) var dismissImmersive
    @State private var isTaskCompleted: Bool = false
    @State private var magnetite: Entity?
    @State private var compass: Entity?
    @State private var arrowEntity: Entity?
    @State private var simulatedMagneticField: SIMD3<Float> = [0, 0, -1.7]

    var body: some View {
        RealityView { content in
            print("ImmersiveView initialized with levelId=\(levelId), taskId=\(taskId)")
            // Додавання фону
            if let background = createBackgroundFullSpace() {
                content.add(background)
                print("Background added successfully")
            } else {
                print("Failed to load background")
            }

            // Додавання магнетиту
            if let magnetiteModel = try? Entity.load(named: "Magnetite") {
                magnetiteModel.position = [-1.5, 2, -1.7]
                magnetiteModel.scale = [0.5, 0.5, 0.5]
                magnetiteModel.name = "Magnetite"
                magnetiteModel.generateCollisionShapes(recursive: true)
                magnetiteModel.components.set(InputTargetComponent())
                content.add(magnetiteModel)
                self.magnetite = magnetiteModel
            } else {
                print("Failed to load Magnetite entity")
            }

            // Додавання компаса
            if let compassModel = try? Entity.load(named: "Compas") {
                compassModel.position = [1.5, 2, -1.7]
                let angleInRadians = Float(45).degreesToRadians
                compassModel.transform.rotation = simd_quatf(angle: angleInRadians, axis: [-0.1, -0.5, 0])
                compassModel.scale = [0.5, 0.5, 0.5]
                compassModel.name = "Compas"
                compassModel.generateCollisionShapes(recursive: true)
                compassModel.components.set(InputTargetComponent())
                content.add(compassModel)
                self.compass = compassModel
            } else {
                print("Failed to load Compas entity")
            }

            // Додавання стрілки
            let arrowMesh = MeshResource.generateCone(height: 0.5, radius: 0.05)
            var arrowMaterial = UnlitMaterial(color: .gray)
            let arrowEntity = Entity()
            arrowEntity.components.set(ModelComponent(mesh: arrowMesh, materials: [arrowMaterial]))
            arrowEntity.position = [0, 2.5, -1.7]
            arrowEntity.orientation = simd_quatf(from: [0, 0, 1], to: simulatedMagneticField)
            arrowEntity.name = "Arrow"
            arrowEntity.generateCollisionShapes(recursive: true)
            content.add(arrowEntity)
            self.arrowEntity = arrowEntity
        } update: { content in
            guard let magnetite = magnetite, let compass = compass, let arrowEntity = arrowEntity else { return }
            guard !isTaskCompleted else { return } // Зупиняємо оновлення, якщо завдання завершено

            // Оновлення орієнтації компаса
            let magnetitePos = magnetite.position
            let compassPos = compass.position
            let direction = normalize(magnetitePos - compassPos)
            let fieldStrength = 1.0 / max(length(magnetitePos - compassPos), 0.1)
            let effectiveField = simulatedMagneticField + direction * fieldStrength
            compass.orientation = simd_quatf(from: [0, 0, 1], to: normalize(effectiveField))

            // Перевірка умов завершення завдання
            let targetPos = arrowEntity.position
            let distance = length(magnetitePos - targetPos)
            let alignment = dot(normalize(effectiveField), normalize(simulatedMagneticField))
            print("Debug: Distance = \(distance), Alignment = \(alignment), isTaskCompleted = \(isTaskCompleted)")

            if distance < 0.5 && alignment > 0.75 {
                print("Task completion condition met for levelId=\(levelId), taskId=\(taskId)")
                // Показуємо повідомлення синхронно
                showCompletionMessage(in: content)
                // Завершуємо завдання асинхронно
                Task {
                    await completeTask()
                }
            }
        }
        .gesture(
            DragGesture()
                .targetedToEntity(magnetite ?? Entity())
                .onChanged { value in
                    guard let magnetite = magnetite, let arrowEntity = arrowEntity else { return }
                    let newPosition = value.convert(value.location3D, from: .local, to: .scene)
                    magnetite.position = newPosition

                    print("Поточна позиція магнетиту: \(newPosition)")
                    let targetPos = arrowEntity.position
                    let distance = length(newPosition - targetPos)
                    print("Відстань до позиції стрілки [\(targetPos.x), \(targetPos.y), \(targetPos.z)]: \(distance)")
                }
        )
        .onAppear {
            print("ImmersiveView appeared with levelId=\(levelId), taskId=\(taskId)")
            backgroundModel.setBackground(for: taskId)
            // Ініціалізація стану завдання при появі
            isTaskCompleted = LevelProgressManager.shared.loadLevels()
                .first(where: { $0.id == levelId })?
                .tasks
                .first(where: { $0.id == taskId })?
                .isCompleted ?? false
        }
        .onDisappear {
            print("ImmersiveView disappeared")
        }
    }

    private func createBackgroundFullSpace() -> Entity? {
        let mesh = MeshResource.generateSphere(radius: 1000)
        guard let texture = try? TextureResource.load(named: backgroundModel.backgroundFullSpaceRaw.rawValue) else {
            print("Failed to load texture: \(backgroundModel.backgroundFullSpaceRaw.rawValue)")
            return nil
        }
        var material = UnlitMaterial()
        material.color = .init(texture: .init(texture))
        let entity = Entity()
        entity.components.set(ModelComponent(mesh: mesh, materials: [material]))
        entity.name = "BackgroundFullSpace"
        entity.scale = .init(x: -1, y: 1, z: 1)
        return entity
    }

    private func showCompletionMessage(in content: RealityViewContent) {
        let textMesh = MeshResource.generateText(
            "Завдання виконано!",
            extrusionDepth: 0.01,
            font: .systemFont(ofSize: 0.1),
            containerFrame: .zero,
            alignment: .center
        )
        var textMaterial = UnlitMaterial(color: .green)
        let textEntity = Entity()
        textEntity.components.set(ModelComponent(mesh: textMesh, materials: [textMaterial]))
        textEntity.position = [0, 2.5, -1.7]
        textEntity.name = "CompletionText"
        content.add(textEntity)

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            textEntity.removeFromParent()
        }
    }

    private func completeTask() async {
        guard !isTaskCompleted else {
            print("Task already completed, skipping: levelId=\(levelId), taskId=\(taskId)")
            return
        }
        isTaskCompleted = true
        print("Completing task: levelId=\(levelId), taskId=\(taskId)")
        gameProgress.taskCompleted = (levelId: levelId, taskId: taskId)
        updateLevelProgress()
        NotificationCenter.default.post(
            name: NSNotification.Name("TaskCompleted"),
            object: nil,
            userInfo: ["levelId": levelId, "taskId": taskId]
        )
        print("Dismissing immersive space for levelId=\(levelId)")
        await dismissImmersive()
    }

    private func updateLevelProgress() {
        var levels = LevelProgressManager.shared.loadLevels()
        guard let levelIndex = levels.firstIndex(where: { $0.id == levelId }),
              let taskIndex = levels[levelIndex].tasks.firstIndex(where: { $0.id == taskId }) else {
            print("Error: Level \(levelId) or Task \(taskId) not found")
            return
        }

        // Перевірка, чи завдання ще не завершено
        guard !levels[levelIndex].tasks[taskIndex].isCompleted else {
            print("Task already marked as completed in LevelProgressManager: levelId=\(levelId), taskId=\(taskId)")
            return
        }

        levels[levelIndex].tasks[taskIndex].isCompleted = true

        let allTasksCompleted = levels[levelIndex].tasks.allSatisfy { $0.isCompleted }
        if allTasksCompleted {
            print("All tasks in level \(levelId) completed!")
            gameProgress.levelCompleted = levelId
            if levelIndex + 1 < levels.count {
                levels[levelIndex + 1].isUnlocked = true
                print("Unlocked level \(levels[levelIndex + 1].id)")
            }
        }
        LevelProgressManager.shared.saveLevels(levels)
        print("Task \(taskId) completed for level \(levelId)")
    }
}

extension Float {
    var degreesToRadians: Float {
        return self * .pi / 180
    }
}


//#Preview(immersionStyle: .full) {
//    ImmersiveView()
//}
