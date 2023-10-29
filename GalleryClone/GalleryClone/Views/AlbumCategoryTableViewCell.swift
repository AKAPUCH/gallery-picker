
import UIKit

import SnapKit

final class AlbumCategoryTableViewCell: UITableViewCell {

    static let cellIdentifier = "albumCategory"

    var cellAlbum: Album?

    let categoryLabel = UILabel().then {
        $0.numberOfLines = 1
        $0.adjustsFontSizeToFitWidth = true
        $0.textColor = .black
    }

    let countLabel = UILabel().then {
        $0.numberOfLines = 0
        $0.adjustsFontSizeToFitWidth = true
        $0.textColor = .black
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // 셀 재사용 전 이전 데이터 모델의 값을 초기화
    override func prepareForReuse() {
        super.prepareForReuse()
        prepareCell(cellAlbum)
    }

    // 셀 UI 업데이트
    func prepareCell(_ cellAlbum: Album?) {
        guard let cellAlbum else { return }
        categoryLabel.text = cellAlbum.name
        countLabel.text = "\(cellAlbum.assets.count)"
    }

    func setLayout() {
        backgroundColor = .white
        [categoryLabel,countLabel].forEach{ addSubview($0) }
        categoryLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(bounds.size.height / 2)
        }
        countLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(bounds.size.height / -4)
        }
    }
}
