
import UIKit

final class BaseViewController: UIViewController {
    
    private let authService: AuthService = GalleryAuthService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        view.backgroundColor = .green
        checkPermission()
    }

    // MARK: - 시스템 앨범 접근 권한 확인
    func checkPermission() {
        authService.requestAuthorization { [weak self] result in
            switch result {
            case .success :
                let nextVC = GalleryViewController()
                nextVC.modalPresentationStyle = .fullScreen
                DispatchQueue.main.async { [weak self] in
                    self?.present(nextVC,animated: true)
                }
            case .failure :
                return
            }
        }
    }
}
