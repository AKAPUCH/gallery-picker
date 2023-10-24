
import UIKit

import SnapKit

final class AlbumCategoryTableViewCell: UITableViewCell {

    static let cellIdentifier = "albumCategory"

    let categoryLabel = {
       let label = UILabel()
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .black
        return label
    }()

    let countLabel = {
       let label = UILabel()
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .black
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
