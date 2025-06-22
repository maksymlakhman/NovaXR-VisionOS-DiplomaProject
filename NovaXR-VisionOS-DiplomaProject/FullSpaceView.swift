//
//  FullSpaceView.swift
//  NovaXR-VisionOS-DiplomaProject
//
//  Created by Maks Lakhman on 22.06.2025.
//

import SwiftUI
import RealityKit
import RealityKitContent
import Combine

@MainActor
struct FullSpaceView: View {
    let levelId: Int
    let taskId: Int
    @State private var hematiteFoundCount = 0
    @State private var showCompletionMessage = false
    private let totalHematites = 5
    @EnvironmentObject private var backgroundModel: BackgroundFullSpaceModel
    @EnvironmentObject private var gameProgress: GameProgressViewModel
    @Environment(\.dismissImmersiveSpace) var dismissImmersive
    
    var body: some View {
        RealityView { content in
            print("FullSpaceView initialized with levelId=\(levelId), taskId=\(taskId)")
            if let backgroundFullSpace = createBackgroundFullSpace(backgroundFullSpaceType: backgroundModel.backgroundFullSpaceRaw) {
                content.add(backgroundFullSpace)
            } else {
                print("Помилка: не вдалося завантажити BackgroundFullSpace")
            }
            
            for i in 0..<totalHematites {
                if let hematiteModel = try? Entity.load(named: "Hematite") {
                    let x = Float.random(in: -5...5)
                    let y = Float.random(in: 0.5...2.5)
                    let z = Float.random(in: -7 ... -1)
                    hematiteModel.position = SIMD3(x, y, z)
                    hematiteModel.scale = SIMD3(0.5, 0.5, 0.5)
                    hematiteModel.components.set(CollisionComponent(shapes: [.generateBox(size: [0.5, 0.5, 0.5])]))
                    hematiteModel.components.set(InputTargetComponent())
                    hematiteModel.name = "Hematite_\(i)"
                    content.add(hematiteModel)
                    print("Added hematite entity \(i) at position (\(x), \(y), \(z))")
                } else {
                    print("Failed to load Hematite entity for index \(i)")
                }
            }
        } update: { content in
            if showCompletionMessage {
                if let textEntity = createCompletionTextEntity() {
                    textEntity.name = "CompletionText"
                    if content.entities.first(where: { $0.name == "CompletionText" }) == nil {
                        content.add(textEntity)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            textEntity.removeFromParent()
                        }
                    }
                } else {
                    print("Failed to create completion text entity")
                }
            }
        }
        .gesture(
            SpatialTapGesture()
                .targetedToAnyEntity()
                .onEnded { value in
                    print("Tapped entity: \(value.entity.name)")
                    if value.entity.name.hasPrefix("Hematite_") && hematiteFoundCount < totalHematites {
                        hematiteFoundCount += 1
                        
                        var combinedTransform = Transform()
                        combinedTransform.scale = SIMD3<Float>(1.5, 1.5, 1.5)
                        combinedTransform.rotation = simd_quatf(angle: .pi, axis: [0, 1, 0])
                        
                        if let particleSystem = createParticleEffect() {
                            particleSystem.position = value.entity.position
                            value.entity.parent?.addChild(particleSystem)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                particleSystem.removeFromParent()
                            }
                        }
                        
                        value.entity.move(to: combinedTransform, relativeTo: value.entity, duration: 0.3)
                        
                        if let sound = try? AudioFileResource.load(named: "collect.wav", in: nil) {
                            let audioEntity = Entity()
                            audioEntity.playAudio(sound)
                            value.entity.parent?.addChild(audioEntity)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                audioEntity.removeFromParent()
                            }
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            value.entity.removeFromParent()
                        }
                        
                        if hematiteFoundCount == totalHematites {
                            showCompletionMessage = true
                            print("Task completed: levelId=\(levelId), taskId=\(taskId)")
                            gameProgress.taskCompleted = (levelId: levelId, taskId: taskId)
                            NotificationCenter.default.post(
                                name: NSNotification.Name("TaskCompleted"),
                                object: nil,
                                userInfo: ["levelId": levelId, "taskId": taskId]
                            )
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                Task {
                                    await dismissImmersive()
                                }
                            }
                        }
                    }
                }
        )
    }
    
    private func createCompletionTextEntity() -> Entity? {
        let textMesh = MeshResource.generateText(
            "Завдання завершено! Ви зібрали всі гематити!",
            extrusionDepth: 0.01,
            font: .systemFont(ofSize: 0.1),
            containerFrame: .zero,
            alignment: .center
        )
        
        let material = UnlitMaterial(color: .white)
        let textEntity = ModelEntity(mesh: textMesh, materials: [material])
        textEntity.position = SIMD3<Float>(0, 1.5, -1) // Closer for visibility
        textEntity.scale = SIMD3<Float>(1, 1, 1)
        textEntity.transform.rotation = simd_quatf(angle: .pi, axis: [0, 1, 0])
        
        return textEntity
    }
    
    private func createParticleEffect() -> Entity? {
        var particleComponent = ParticleEmitterComponent()
        particleComponent.emitterShape = .sphere
        particleComponent.emitterShapeSize = SIMD3<Float>(0.1, 0.1, 0.1)
        particleComponent.birthLocation = .surface
        particleComponent.birthDirection = .normal
        particleComponent.speed = 0.5
        particleComponent.burstCount = 20
        particleComponent.isEmitting = true
        
        var mainEmitter = particleComponent.mainEmitter
        mainEmitter.size = 0.05
        mainEmitter.sizeVariation = 0.02
        mainEmitter.lifeSpan = 0.5
        mainEmitter.lifeSpanVariation = 0.1
        mainEmitter.opacityCurve = .quickFadeInOut
        mainEmitter.color = .constant(.single(UIColor.white))
        mainEmitter.billboardMode = .billboard
        
        particleComponent.mainEmitter = mainEmitter
        
        let particleEntity = Entity()
        particleEntity.components.set(particleComponent)
        return particleEntity
    }
    
    private func createBackgroundFullSpace(backgroundFullSpaceType: FullBackgroundType) -> Entity? {
        let backgroundFullSpaceMesh = MeshResource.generateSphere(radius: 1000)
        
        guard let backgroundFullSpaceTexture = try? TextureResource.load(named: backgroundFullSpaceType.rawValue, in: nil) else {
            print("Помилка завантаження текстури: \(backgroundFullSpaceType.rawValue)")
            return nil
        }
        
        var backgroundFullSpaceMaterial = UnlitMaterial()
        backgroundFullSpaceMaterial.color = .init(texture: .init(backgroundFullSpaceTexture))
        
        let backgroundFullSpaceEntity = Entity()
        backgroundFullSpaceEntity.components.set(ModelComponent(mesh: backgroundFullSpaceMesh, materials: [backgroundFullSpaceMaterial]))
        backgroundFullSpaceEntity.name = "BackgroundFullSpace"
        backgroundFullSpaceEntity.scale = .init(x: -1, y: 1, z: 1)
        
        return backgroundFullSpaceEntity
    }
}

