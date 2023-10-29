
import UIKit

import SnapKit
import Then

final class GalleryCell: UICollectionViewCell {

    static let cellIdentifier = "Gallery"

    var galleryCellModel: CellModel?

    let galleryImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
    }

    let selectedEffectView = UIView().then {
        $0.backgroundColor = .systemPink
        $0.alpha = 0.3
        $0.isHidden = true
    }

    let orderLabel = UILabel().then {
        $0.backgroundColor = .systemPink
        $0.textColor = .white
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 7.5
        $0.isHidden = true
        $0.numberOfLines = 1
        $0.textAlignment = .center
        $0.text = "0"
        $0.adjustsFontSizeToFitWidth = true
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // 셀 재사용 전 이전 데이터 모델의 값을 초기화
    override func prepareForReuse() {
        super.prepareForReuse()
        prepareCell(galleryCellModel)
    }

    // 셀 UI 업데이트
    func prepareCell(_ cellModel: CellModel?) {
        guard let cellModel else { return }
        if cellModel.image == UIImage(systemName: "camera.fill") {
            galleryImageView.contentMode = .center
            galleryImageView.tintColor = .systemGray
        } else {
            galleryImageView.contentMode = .scaleAspectFill
        }
        selectedEffectView.isHidden = !cellModel.isSelected
        orderLabel.isHidden = !cellModel.isSelected
        galleryImageView.image = cellModel.image
        orderLabel.text = "\(cellModel.order)"
    }

    func setLayout() {
        layer.masksToBounds = true
        [galleryImageView,selectedEffectView,orderLabel].forEach{ addSubview($0) }
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
