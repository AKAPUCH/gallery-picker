
import UIKit

final class BaseViewController: UIViewController {
    
    private let authService: AuthService = GalleryAuthService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
                let alertView = UIAlertController(title: "권한 설정", message: "원활한 앱 사용을 위해 앨범 접근 권한이 필요합니다.", preferredStyle: .alert)
                let alertAction = UIAlertAction(title: "확인", style: .default) { _ in self?.authService.goToSetting()
                }
                alertView.addAction(alertAction)
                DispatchQueue.main.async { [weak self] in
                    self?.present(alertView,animated: true)
                }
                return
            }
        }
    }
}
