
import UIKit
import Photos

struct CellModel: Equatable {
    let asset: PHAsset?
    var albumIndex: Int
    var order: Int
    var image: UIImage?
    var indexPath: IndexPath?
    var isVisible: Bool?
    init(asset: PHAsset? = nil, albumIndex: Int, order: Int, image: UIImage? = nil, indexPath: IndexPath? = nil, isVisible: Bool? = nil) {
        self.asset = asset
        self.albumIndex = albumIndex
        self.order = order
        self.image = image
        self.indexPath = indexPath
        self.isVisible = isVisible
    }
}
