//
//  NovaXR_VisionOS_DiplomaProjectApp.swift
//  NovaXR-VisionOS-DiplomaProject
//
//  Created by Maks Lakhman on 22.06.2025.
//

import SwiftUI

@main
struct NovaXR_VisionOS_DiplomaProjectApp: App {

    @State private var appModel = AppModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appModel)
        }
        .windowStyle(.volumetric)

        ImmersiveSpace(id: appModel.immersiveSpaceID) {
            ImmersiveView()
                .environment(appModel)
                .onAppear {
                    appModel.immersiveSpaceState = .open
                }
                .onDisappear {
                    appModel.immersiveSpaceState = .closed
                }
        }
        .immersionStyle(selection: .constant(.full), in: .full)
    }
}
