import Foundation
import Domain
import Infra
import UseCase

@MainActor
final class DependencyContainer {
    // Repositories
    let authRepository: AuthRepository
    let birdRepository: BirdRepository
    let observationRepository: ObservationRepository
    let mapRepository: MapRepository
    let uploadRepository: UploadRepository

    // UseCases
    let authUseCase: AuthUseCase
    let fetchBirdsUseCase: FetchBirdsUseCase
    let fetchObservationsUseCase: FetchObservationsUseCase
    let createObservationUseCase: CreateObservationUseCase
    let fetchMapPointsUseCase: FetchMapPointsUseCase
    let identifyBirdUseCase: IdentifyBirdUseCase

    init() {
        let supabaseURL = URL(string: "https://daipnjjutqcvjgjvajhm.supabase.co")!
        let supabaseKey = "sb_publishable_8B0MFU16uDxiprtY9wFPVg_LfC3_4bJ"

        let apiClient = APIClient()
        let supabaseAuth = SupabaseAuthClient(supabaseURL: supabaseURL, supabaseKey: supabaseKey)

        // Token provider: AuthRepositoryからアクセストークンを取得
        let tokenProvider: @Sendable () async -> String? = {
            await supabaseAuth.getAccessToken()
        }

        // Repositories
        self.authRepository = supabaseAuth
        self.birdRepository = BirdRepositoryImpl(apiClient: apiClient, tokenProvider: tokenProvider)
        self.observationRepository = ObservationRepositoryImpl(apiClient: apiClient, tokenProvider: tokenProvider)
        self.mapRepository = MapRepositoryImpl(apiClient: apiClient, tokenProvider: tokenProvider)
        self.uploadRepository = UploadRepositoryImpl(apiClient: apiClient, tokenProvider: tokenProvider)

        // UseCases
        self.authUseCase = AuthUseCase(repository: supabaseAuth)
        self.fetchBirdsUseCase = FetchBirdsUseCase(repository: birdRepository)
        self.fetchObservationsUseCase = FetchObservationsUseCase(repository: observationRepository)
        self.createObservationUseCase = CreateObservationUseCase(observationRepository: observationRepository, uploadRepository: uploadRepository)
        self.fetchMapPointsUseCase = FetchMapPointsUseCase(repository: mapRepository)
        self.identifyBirdUseCase = IdentifyBirdUseCase(repository: uploadRepository)
    }
}
