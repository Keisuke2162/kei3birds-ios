import Foundation
import MapKit
import Domain
import UseCase

enum MapLayer: String, CaseIterable {
    case gbif = "GBIFデータ"
    case my = "自分の記録"
    case both = "両方"
}

@Observable
@MainActor
final class MapViewModel {
    private let fetchMapPointsUseCase: FetchMapPointsUseCase

    var selectedLayer: MapLayer = .gbif
    var gbifPoints: [GBIFMapPoint] = []
    var myPoints: [MyMapPoint] = []
    var isLoading = false
    var errorMessage: String?
    var selectedGBIFPoint: GBIFMapPoint?
    var selectedMyPoint: MyMapPoint?

    var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 35.6812, longitude: 139.7671),
            span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
        )
    )

    private var debounceTask: Task<Void, Never>?

    init(fetchMapPointsUseCase: FetchMapPointsUseCase) {
        self.fetchMapPointsUseCase = fetchMapPointsUseCase
    }

    func onRegionChanged(center: CLLocationCoordinate2D) {
        debounceTask?.cancel()
        debounceTask = Task {
            try? await Task.sleep(for: .milliseconds(500))
            guard !Task.isCancelled else { return }
            await loadData(lat: center.latitude, lng: center.longitude)
        }
    }

    func loadData(lat: Double, lng: Double) async {
        isLoading = true
        errorMessage = nil

        do {
            switch selectedLayer {
            case .gbif:
                gbifPoints = try await fetchMapPointsUseCase.executeGBIF(lat: lat, lng: lng)
            case .my:
                myPoints = try await fetchMapPointsUseCase.executeMy()
            case .both:
                async let gbif = fetchMapPointsUseCase.executeGBIF(lat: lat, lng: lng)
                async let my = fetchMapPointsUseCase.executeMy()
                gbifPoints = try await gbif
                myPoints = try await my
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func onLayerChanged(lat: Double, lng: Double) {
        Task { await loadData(lat: lat, lng: lng) }
    }
}
