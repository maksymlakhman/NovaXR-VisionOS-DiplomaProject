//
//  GameMapView.swift
//  NovaXR-VisionOS-DiplomaProject
//
//  Created by Maks Lakhman on 22.06.2025.
//

import SwiftUI
import MapKit
import CoreLocation
import Combine

struct GameMapView: View {
    @StateObject private var viewModel = GameMapViewModel()

    var body: some View {
        Map(coordinateRegion: $viewModel.region, annotationItems: viewModel.annotations) { annotation in
            MapAnnotation(coordinate: annotation.coordinate) {
                VStack(spacing: 6) {
                    ZStack {
                        Circle()
                            .fill(annotation.isUnlocked ? .green : .gray)
                            .frame(width: 38, height: 38)
                            .overlay(
                                Image(systemName: annotation.isUnlocked ? "location.circle.fill" : "lock.fill")
                                    .foregroundColor(.white)
                                    .font(.title3)
                            )
                            .scaleEffect(annotation.isUnlocked ? 1.15 : 1.0)
                            .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 3)
                            .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: annotation.isUnlocked)
                    }

                    Text(annotation.title)
                        .font(.caption2)
                        .bold()
                        .padding(.horizontal, 6)
                        .padding(.vertical, 4)
                        .background(.ultraThinMaterial)
                        .cornerRadius(8)
                }
            }
        }
        .mapStyle(.standard(elevation: .realistic))
        .edgesIgnoringSafeArea(.all)
    }
}

class GameMapViewModel: ObservableObject {
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 48.5, longitude: 32.0),
        span: MKCoordinateSpan(latitudeDelta: 5.0, longitudeDelta: 5.0)
    )

    @Published var annotations: [GameLocation] = []

    init() {
        loadAnnotations()
    }

    private func loadAnnotations() {
        let levels = LevelProgressManager.shared.loadLevels()

        let locationsByLevel: [Int: (String, CLLocationCoordinate2D)] = [
            1: ("Кривий Ріг", CLLocationCoordinate2D(latitude: 47.9097, longitude: 33.3790)),
            2: ("Нікополь", CLLocationCoordinate2D(latitude: 47.5675, longitude: 34.4067)),
            3: ("Донецьк", CLLocationCoordinate2D(latitude: 48.0159, longitude: 37.8028))
        ]

        annotations = levels.compactMap { level in
            guard let (city, coordinate) = locationsByLevel[level.id] else { return nil }
            return GameLocation(title: city, coordinate: coordinate, isUnlocked: level.isUnlocked)
        }
    }
}

struct GameLocation: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let coordinate: CLLocationCoordinate2D
    let isUnlocked: Bool

    static func == (lhs: GameLocation, rhs: GameLocation) -> Bool {
        lhs.title == rhs.title &&
        lhs.coordinate.latitude == rhs.coordinate.latitude &&
        lhs.coordinate.longitude == rhs.coordinate.longitude &&
        lhs.isUnlocked == rhs.isUnlocked
    }
}


