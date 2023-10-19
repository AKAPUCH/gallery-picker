
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
        view.alpha = 0.3
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
        label.numberOfLines = 1
        label.textAlignment = .center
        label.text = "0"
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        prepareCell(nil)
    }
    
    func prepareCell(_ cellModel: CellModel?) {
        galleryImageView.contentMode = .scaleAspectFill
        selectedEffectView.isHidden = true
        orderLabel.isHidden = true
        guard let cellModel else {return}
        galleryImageView.image = cellModel.image
        guard let currentOrder = Int(orderLabel.text!) else{return}
        if currentOrder == cellModel.order && currentOrder > 0 {
            selectedEffectView.isHidden = false
            orderLabel.text = "\(cellModel.order)"
            orderLabel.isHidden = false
        }


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
