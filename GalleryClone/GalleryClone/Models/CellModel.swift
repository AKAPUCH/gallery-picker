
import UIKit
import Photos

struct CellModel {
    let asset: PHAsset
    var order: Int
    var image: UIImage?
    
    init(asset: PHAsset, order: Int, image: UIImage? = nil) {
        self.asset = asset
        self.order = order
        self.image = image
    }
}
