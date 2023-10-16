
import UIKit
import Photos

protocol PhotoService {
    func convertAlbumToAssets(album: PHFetchResult<PHAsset>, completion: @escaping ([PHAsset]) -> Void)
    func fetchImage(asset: PHAsset, size: CGSize, contentMode: PHImageContentMode, completion: @escaping (UIImage) -> Void)
}

final class GalleryPhotoService : NSObject, PhotoService {
    
    private let imageManager = PHImageManager()
    weak var delegate: PHPhotoLibraryChangeObserver?
    
    override init() {
        super.init()
        PHPhotoLibrary.shared().register(self)
    }
    
    func convertAlbumToAssets(album: PHFetchResult<PHAsset>, completion: @escaping ([PHAsset]) -> Void) {
        var assets = [PHAsset]()
        
        defer {completion(assets)}
        
        guard album.count > 0 else {return}
        album.enumerateObjects { asset, index, pointer in
            guard index <= album.count - 1 else {
                pointer.pointee = true
                return
            }
            assets.append(asset)
        }
        
    }
    
    func fetchImage(asset: PHAsset, size: CGSize, contentMode: PHImageContentMode, completion: @escaping (UIImage) -> Void) {
        let requestOptions = {
            let options = PHImageRequestOptions()
            options.isNetworkAccessAllowed = true
            options.deliveryMode = .highQualityFormat
            return options
        }()
        
        imageManager.requestImage(for: asset, targetSize: size, contentMode: contentMode, options: requestOptions) { image, _ in
            guard let image else {return}
            completion(image)
        }
    }
    
    
}

extension GalleryPhotoService : PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        delegate?.photoLibraryDidChange(changeInstance)
    }
}
