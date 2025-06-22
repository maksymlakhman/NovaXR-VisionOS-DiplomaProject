//
//  RobotStatusView.swift
//  NovaXR-VisionOS-DiplomaProject
//
//  Created by Maks Lakhman on 22.06.2025.
//

import SwiftUI
import RealityKit
import RealityKitContent
import Combine

struct RobotStatusView: View {
    @State private var rotationAngleX: Angle = .degrees(0)
    @State private var rotationAngleY: Angle = .degrees(0)
    
    var body: some View {
        VStack {
            Model3D(named: "GeoBot") { model in
                model
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(0.8)
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
            Text("GeoBot-47")
                .font(.title)
            Text("Статус: Готовий до місії")
                .font(.headline)
            Text("Наступна локація: Криворізький басейн")
                .font(.subheadline)
        }
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
    }
}

