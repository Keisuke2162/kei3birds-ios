import SwiftUI

@main
struct Kei3BirdsApp: App {
    @State private var container = DependencyContainer()
    @State private var authViewModel: AuthViewModel?

    var body: some Scene {
        WindowGroup {
            Group {
                if let authVM = authViewModel {
                    if authVM.isLoading {
                        LoadingView(message: "起動中...")
                    } else if !authVM.isAuthenticated {
                        LoginView(viewModel: authVM)
                    } else if authVM.needsUsername {
                        UsernameSetupView(viewModel: authVM)
                    } else {
                        MainTabView(container: container, authViewModel: authVM)
                    }
                } else {
                    LoadingView(message: "起動中...")
                }
            }
            .task {
                let vm = AuthViewModel(authUseCase: container.authUseCase)
                authViewModel = vm
                await vm.restoreSession()
            }
        }
    }
}

enum AppTab: Hashable {
    case encyclopedia
    case camera
    case profile
}

struct MainTabView: View {
    let container: DependencyContainer
    let authViewModel: AuthViewModel
    @State private var selectedTab: AppTab = .encyclopedia
    @State private var encyclopediaViewModel: EncyclopediaViewModel

    init(container: DependencyContainer, authViewModel: AuthViewModel) {
        self.container = container
        self.authViewModel = authViewModel
        self._encyclopediaViewModel = State(initialValue: EncyclopediaViewModel(
            fetchBirdsUseCase: container.fetchBirdsUseCase,
            fetchObservationsUseCase: container.fetchObservationsUseCase
        ))
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("図鑑", systemImage: "book", value: AppTab.encyclopedia) {
                EncyclopediaView(
                    viewModel: encyclopediaViewModel,
                    container: container
                )
            }
            Tab("撮影", systemImage: "camera", value: AppTab.camera) {
                CameraView(
                    viewModel: IdentifyViewModel(
                        identifyBirdUseCase: container.identifyBirdUseCase,
                        createObservationUseCase: container.createObservationUseCase
                    ),
                    onRegistrationComplete: {
                        selectedTab = .encyclopedia
                        Task { await encyclopediaViewModel.loadData() }
                    }
                )
            }
            Tab("プロフィール", systemImage: "person", value: AppTab.profile) {
                ProfileView(
                    viewModel: ProfileViewModel(
                        fetchBirdsUseCase: container.fetchBirdsUseCase,
                        fetchObservationsUseCase: container.fetchObservationsUseCase,
                        authUseCase: container.authUseCase,
                        username: authViewModel.currentUser?.username ?? "ゲスト"
                    ),
                    authViewModel: authViewModel,
                    container: container
                )
            }
        }
    }
}
