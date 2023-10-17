
import UIKit

class SelectedCell: UICollectionViewCell {
    
    static let cellIdentifier = "Selected"
    
    let selectedImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let xmarkView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .clear
        imageView.tintColor = .systemGray
        imageView.image = UIImage(systemName: "xmark.circle.fill")
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func configureUI() {
        layer.masksToBounds = true
        [selectedImageView,xmarkView].forEach{self.addSubview($0)}
        selectedImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        xmarkView.snp.makeConstraints { make in
            make.top.right.equalTo(selectedImageView)
            make.width.height.equalTo(15)
        }
    }
}