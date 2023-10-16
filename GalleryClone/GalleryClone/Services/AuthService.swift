
import UIKit
import Photos

protocol AuthService {
    var authorizationStatus : PHAuthorizationStatus { get }
    func requestAuthorization(completion: @escaping (Result<Void, NSError>) -> Void)
}

final class GalleryAuthService : AuthService {
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
            DispatchQueue.main.async {
                completion(.success(()))
            }
        }
    }
    
    
}
