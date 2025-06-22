//
//  SplashView.swift
//  NovaXR-VisionOS-DiplomaProject
//
//  Created by Maks Lakhman on 22.06.2025.
//

import SwiftUI
import RealityKit
import RealityKitContent
import Combine

struct SplashView: View {
    @State private var showMainView = false
    @EnvironmentObject private var backgroundModel: BackgroundFullSpaceModel
    var body: some View {
        ZStack {
            if showMainView {
                MainView()
            } else {
                VStack {
                    Model3D(named: "GeoBot") { model in
                        model
                            .resizable()
                            .scaledToFit()
                            .frame(width: 300, height: 300)
                    } placeholder: {
                        ProgressView()
                    }
                    Text("Loading NovaXR")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            showMainView = true
                        }
                    }
                }
            }
        }
        .environmentObject(backgroundModel)
    }
}

