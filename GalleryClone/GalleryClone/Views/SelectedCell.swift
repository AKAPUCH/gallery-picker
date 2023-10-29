
import UIKit

import Then

final class SelectedCell: UICollectionViewCell {

    static let cellIdentifier = "Selected"

    var selectedCellModel: CellModel?

    let selectedImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
    }

    let xmarkView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.backgroundColor = .clear
        $0.tintColor = .systemGray
        $0.image = UIImage(systemName: "xmark.circle.fill")
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
        prepareCell(selectedCellModel)
    }

    // 셀 UI 업데이트
    func prepareCell(_ cellModel: CellModel?) {
        guard let cellModel else { return }
        selectedImageView.image = cellModel.image
    }

    func setLayout() {
        layer.masksToBounds = true
        [selectedImageView,xmarkView].forEach{ addSubview($0) }
        selectedImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        xmarkView.snp.makeConstraints { make in
            make.top.right.equalTo(selectedImageView)
            make.width.height.equalTo(15)
        }
    }
}
