
import Photos
import UIKit

protocol AuthService {
    var authorizationStatus: PHAuthorizationStatus { get }
    func requestAuthorization(completion: @escaping (Result<Void, NSError>) -> Void)
}

// MARK: - 시스템 사진 라이브러리 접근권한 요청
final class GalleryAuthService: AuthService {
    var authorizationStatus: PHAuthorizationStatus {
        PHPhotoLibrary.authorizationStatus(for: .readWrite)
    }

    func requestAuthorization(completion: @escaping (Result<Void, NSError>) -> Void) {
        guard authorizationStatus != .authorized else {
            completion(.success(()))
            return
        }

        guard authorizationStatus != .denied else {
            completion(.failure(.init()))
            return
        }

        guard authorizationStatus == .notDetermined else {
            completion(.failure(.init()))
            return
        }

        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            if status == .authorized || status == .limited {
                    completion(.success(()))
                }
        }
    }
}
