
import Photos
import UIKit

protocol PhotoService {
    var delegate: PhotoServiceDelegate? {get set}
    func convertAlbumToAssets(album: PHFetchResult<PHAsset>, completion: @escaping ([PHAsset]) -> Void)
    func fetchImage(asset: PHAsset, size: CGSize, contentMode: PHImageContentMode, completion: @escaping (UIImage) -> Void)
}

protocol PhotoServiceDelegate: NSObject {
    func applyDatas()
}

// MARK: - 사진과 관련된 기능 담당(시스템 앨범 라이브러리 변경 감지, 이미지 변환)
final class GalleryPhotoService: NSObject, PhotoService {
    weak var delegate: PhotoServiceDelegate?
    private let imageManager = PHImageManager()

    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }

    override init() {
        super.init()
        PHPhotoLibrary.shared().register(self)
    }

    func convertAlbumToAssets(album: PHFetchResult<PHAsset>, completion: @escaping ([PHAsset]) -> Void) {
        var assets = [PHAsset]()
        defer {completion(assets)}
        
        guard album.count > 0 else { return }
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
            guard let image else { return }
            completion(image)
        }
    }
}
    // MARK: - PHPhotoLibraryChangeObserver
extension GalleryPhotoService: PHPhotoLibraryChangeObserver {
    // MARK: - 시스템 앨범 변경 감지시 GalleryViewController 데이터 및 UI 업데이트
    func photoLibraryDidChange(_ changeInstance: PHChange) {
            delegate?.applyDatas()
    }
}
