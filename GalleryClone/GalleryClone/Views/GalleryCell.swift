
import UIKit

class GalleryCell: UICollectionViewCell {
    let galleryImageView = {
       let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let selectedEffectView = {
        let view = UIView()
        view.backgroundColor = .systemPurple
        view.alpha = 0.7
        return view
    }()
    
    let orderLabel = {
       let label = UILabel()
        label.backgroundColor = .systemPurple
        label.textColor = .white
        label.layer.cornerRadius = 0.7
        return label
    }()
}
