
import UIKit
import SnapKit

class GalleryCell: UICollectionViewCell {
    
    static let cellIdentifier = "Gallery"
    
    let galleryImageView = {
       let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let selectedEffectView = {
        let view = UIView()
        view.backgroundColor = .systemPink
        view.alpha = 0.1
        view.isHidden = true
        return view
    }()
    
    let orderLabel = {
       let label = UILabel()
        label.backgroundColor = .systemPink
        label.textColor = .white
        label.clipsToBounds = true
        label.layer.cornerRadius = 7.5
        label.isHidden = true
        label.text = "0"
        label.numberOfLines = 1
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        return label
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
        [galleryImageView,selectedEffectView,orderLabel].forEach{self.addSubview($0)}
        galleryImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        selectedEffectView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        orderLabel.snp.makeConstraints { make in
            make.top.equalTo(selectedEffectView).offset(5)
            make.right.equalTo(selectedEffectView).offset(-5)
            make.width.height.equalTo(15)
        }
    }
}
