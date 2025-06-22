//
//  InventarView.swift
//  NovaXR-VisionOS-DiplomaProject
//
//  Created by Maks Lakhman on 22.06.2025.
//

import SwiftUI

struct InventoryItem: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let description: String
}

struct InventarView: View {
    let items: [InventoryItem] = [
        InventoryItem(name: "Сканер мінералів", icon: "wave.3.right.circle", description: "Дозволяє визначати мінерали на відстані."),
        InventoryItem(name: "Щит для робота", icon: "shield.lefthalf.filled", description: "Захищає від каменепадів."),
        InventoryItem(name: "Покращене свердло", icon: "gearshape.2.fill", description: "Дає змогу проходити тверді породи."),
        InventoryItem(name: "Колекція зразків", icon: "cube.transparent", description: "Зібрані унікальні мінерали.")
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Інвентар")
                    .font(.largeTitle.bold())
                    .padding(.top)

                ForEach(items) { item in
                    HStack(spacing: 16) {
                        Image(systemName: item.icon)
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.cyan)
                            .padding()
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())

                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.name)
                                .font(.headline)
                            Text(item.description)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }

                        Spacer()
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

