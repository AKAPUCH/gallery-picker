
import Photos
import UIKit

protocol AuthService {

    var authorizationStatus: PHAuthorizationStatus { get }

    func goToSetting()
    func requestAuthorization(completion: @escaping (Result<Void, NSError>) -> Void)

}

final class GalleryAuthService: AuthService {

    var authorizationStatus: PHAuthorizationStatus {
        PHPhotoLibrary.authorizationStatus(for: .readWrite)
    }

    // 접근권한 획득 실패 시 앱 설정 열기
    func goToSetting() {
        guard
            let url = URL(string: UIApplication.openSettingsURLString),
            UIApplication.shared.canOpenURL(url)
        else { return }

        UIApplication.shared.open(url, completionHandler: nil)
    }

    // 시스템 사진 라이브러리 접근권한 요청
    func requestAuthorization(completion: @escaping (Result<Void, NSError>) -> Void) {
        guard authorizationStatus != .authorized else {
            completion(.success(()))
            return
        }

        guard authorizationStatus != .limited else {
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
