//
//  AlbumCategoryTableViewCell.swift
//  GalleryClone
//
//  Created by 84360 on 2023/10/18.
//

import UIKit
import SnapKit
class AlbumCategoryTableViewCell: UITableViewCell {
    
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
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .black
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUI() {
        self.backgroundColor = .white
        [categoryLabel,countLabel].forEach{self.addSubview($0)}
        categoryLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(self.bounds.size.height / 4)
        }
        countLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(self.snp.trailing).offset( self.bounds.size.height / -2)
        }
    }
    
}
