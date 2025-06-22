//
//  CoalView.swift
//  NovaXR-VisionOS-DiplomaProject
//
//  Created by Maks Lakhman on 22.06.2025.
//

import SwiftUI
import RealityKit
import RealityKitContent
import Combine

struct CoalView: View {
    let taskId: Int
    @EnvironmentObject private var backgroundFullSpaceRaw: BackgroundFullSpaceModel
    @Environment(\.dismissImmersiveSpace) var dismissImmersive
    
    var body: some View {
        RealityView { content in
            if let background = createBackgroundFullSpace(backgroundFullSpaceType: backgroundFullSpaceRaw.backgroundFullSpaceRaw) {
                content.add(background)
            }
            // Додайте моделі для вугілля, шахти тощо
            if let coalModel = try? Entity.load(named: "Coal") {
                coalModel.position = SIMD3<Float>(0, 1, -2)
                coalModel.scale = SIMD3<Float>(0.5, 0.5, 0.5)
                coalModel.components.set(CollisionComponent(shapes: [.generateBox(size: [0.5, 0.5, 0.5])]))
                coalModel.components.set(InputTargetComponent())
                coalModel.name = "Coal_1"
                content.add(coalModel)
            }
        }
        .gesture(
            SpatialTapGesture()
                .targetedToAnyEntity()
                .onEnded { value in
                    if value.entity.name.hasPrefix("Coal_") {
                        value.entity.removeFromParent()
                        NotificationCenter.default.post(
                            name: NSNotification.Name("TaskCompleted"),
                            object: nil,
                            userInfo: ["taskId": taskId]
                        )
                    }
                }
        )
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

