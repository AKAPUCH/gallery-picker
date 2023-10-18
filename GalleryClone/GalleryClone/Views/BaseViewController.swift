
import UIKit

final class BaseViewController: UIViewController {
    
    private let authService : AuthService = GalleryAuthService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    override func viewDidAppear(_ animated: Bool) {
        self.view.backgroundColor = .green
        checkPermission()
    }
    func checkPermission() {
        authService.requestAuthorization { [weak self] result in
            guard let self else {return}
            
            switch result {
            case .success :
                let nextVC = GalleryViewController()
                nextVC.modalPresentationStyle = .fullScreen
                present(nextVC,animated: true)
            case .failure :
                return
            }
        }
    }


}
