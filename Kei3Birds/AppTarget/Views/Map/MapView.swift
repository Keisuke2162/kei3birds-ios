import SwiftUI
import MapKit
import Domain

struct MapView: View {
    @State var viewModel: MapViewModel
    @State private var showGBIFSheet = false
    @State private var showMySheet = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Map(position: $viewModel.cameraPosition) {
                    if viewModel.selectedLayer == .gbif || viewModel.selectedLayer == .both {
                        ForEach(viewModel.gbifPoints) { point in
                            Annotation(point.nameJa, coordinate: CLLocationCoordinate2D(latitude: point.lat, longitude: point.lng)) {
                                BirdPinView(color: .blue)
                                    .onTapGesture {
                                        viewModel.selectedGBIFPoint = point
                                        showGBIFSheet = true
                                    }
                            }
                        }
                    }

                    if viewModel.selectedLayer == .my || viewModel.selectedLayer == .both {
                        ForEach(viewModel.myPoints) { point in
                            Annotation(point.nameJa ?? "不明", coordinate: CLLocationCoordinate2D(latitude: point.lat, longitude: point.lng)) {
                                BirdPinView(color: .orange)
                                    .onTapGesture {
                                        viewModel.selectedMyPoint = point
                                        showMySheet = true
                                    }
                            }
                        }
                    }
                }
                .onMapCameraChange(frequency: .onEnd) { context in
                    viewModel.onRegionChanged(center: context.camera.centerCoordinate)
                }

                VStack {
                    Picker("レイヤー", selection: $viewModel.selectedLayer) {
                        ForEach(MapLayer.allCases, id: \.self) { layer in
                            Text(layer.rawValue).tag(layer)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    .padding(.top, 8)

                    if viewModel.isLoading {
                        LoadingView()
                    }
                }
            }
            .navigationTitle("マップ")
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: viewModel.selectedLayer) {
                viewModel.onLayerChanged(lat: 35.6812, lng: 139.7671)
            }
            .sheet(isPresented: $showGBIFSheet) {
                if let point = viewModel.selectedGBIFPoint {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(point.nameJa).font(.title2.bold())
                        Text("観察日: \(point.observedAt)").foregroundStyle(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .presentationDetents([.fraction(0.3)])
                }
            }
            .sheet(isPresented: $showMySheet) {
                if let point = viewModel.selectedMyPoint {
                    VStack(alignment: .leading, spacing: 12) {
                        if let name = point.nameJa {
                            Text(name).font(.title2.bold())
                        }
                        AsyncImage(url: URL(string: point.photoUrl)) { image in
                            image.resizable().scaledToFit()
                        } placeholder: { ProgressView() }
                        .frame(height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        Text("撮影日: \(point.takenAt)").foregroundStyle(.secondary)
                        if let loc = point.locationName {
                            Text("場所: \(loc)").foregroundStyle(.secondary)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .presentationDetents([.fraction(0.4)])
                }
            }
        }
    }
}
