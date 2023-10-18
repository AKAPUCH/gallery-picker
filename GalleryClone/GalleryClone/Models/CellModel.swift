
import UIKit
import Photos

struct CellModel {
    let asset: PHAsset?
    var order: Int
    var image: UIImage?
    var indexPath: IndexPath?
    var isVisible: Bool?
    init(asset: PHAsset? = nil, order: Int, image: UIImage? = nil, indexPath: IndexPath? = nil, isVisible: Bool? = nil) {
        self.asset = asset
        self.order = order
        self.image = image
        self.indexPath = indexPath
        self.isVisible = isVisible
    }
}
