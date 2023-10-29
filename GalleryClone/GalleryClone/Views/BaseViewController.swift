
import UIKit

final class BaseViewController: UIViewController {

    private let authService: AuthService = GalleryAuthService()

    // 다음 화면(GalleryViewController)에서 복귀했을 때 viewDidLoad가 호출되지 않으므로 이곳에 구현
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = .green
        checkPermission()
    }

    // 시스템 앨범 접근 권한 확인
    func checkPermission() {
        authService.requestAuthorization { [weak self] result in
            switch result {
            
            // 권한 획득 시 다음 화면으로 이동
            case .success :
                let nextVC = GalleryViewController()
                nextVC.modalPresentationStyle = .fullScreen
                DispatchQueue.main.async { [weak self] in
                    self?.present(nextVC,animated: true)
                }
                
            // 권한 획득 실패 시 알림 후 설정 화면으로 이동( 단, 설정 변경 시 실행중인 앱 종료)
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
