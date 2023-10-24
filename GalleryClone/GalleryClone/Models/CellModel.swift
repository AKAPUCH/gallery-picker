
import Photos
import UIKit

// MARK: - 컬렉션 뷰에 사용되는 셀의 데이터모델
final class CellModel: NSObject {
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
