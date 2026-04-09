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

struct MainTabView: View {
    let container: DependencyContainer
    let authViewModel: AuthViewModel

    var body: some View {
        TabView {
            Tab("図鑑", systemImage: "book") {
                EncyclopediaView(
                    viewModel: EncyclopediaViewModel(
                        fetchBirdsUseCase: container.fetchBirdsUseCase,
                        fetchObservationsUseCase: container.fetchObservationsUseCase
                    ),
                    container: container
                )
            }
            Tab("撮影", systemImage: "camera") {
                CameraView(
                    viewModel: IdentifyViewModel(
                        identifyBirdUseCase: container.identifyBirdUseCase,
                        createObservationUseCase: container.createObservationUseCase
                    )
                )
            }
            Tab("プロフィール", systemImage: "person") {
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
