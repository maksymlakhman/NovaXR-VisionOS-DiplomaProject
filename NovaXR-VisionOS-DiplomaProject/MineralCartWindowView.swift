//
//  MineralCartWindowView.swift
//  NovaXR-VisionOS-DiplomaProject
//
//  Created by Maks Lakhman on 22.06.2025.
//

import SwiftUI
import RealityKit
import RealityKitContent
import Combine

struct MineralCartWindowView: View {
    @Environment(\.dismissWindow) private var dismissWindow
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    dismissWindow(id: "MineralCart")
                } label: {
                    Image(systemName: "xmark")
                        .font(.title)
                        .padding()
                        .foregroundColor(.white)
                }
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.vertical, 20)
                .padding(.leading, 20)
                Spacer()
            }
            
            VStack {
                Image("NaturalResources")
                    .resizable()
                    .scaledToFit()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            VStack {
                Text("Карта копалин України")
                    .font(.title)
                    .foregroundColor(.white)
                    .padding()
                    .background(.black.opacity(0.5))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.bottom, 20)
            }
        }
    }
}
