
import Photos
import UIKit

protocol AlbumService {
    func getAlbums(completion: @escaping ([Album]) -> Void)
}

final class GalleryAlbumService: AlbumService {

    // MARK: - 시스템 사진 라이브러리에서 스마트 앨범을 가져오고 Album 데이터 모델 형태로 반환
    func getAlbums(completion: @escaping ([Album]) -> Void) {
        var albums = [Album]()
        // fetch 완료시 앨범 내 사진 수, 사전 오름차순으로 정렬하여 반환
        defer {completion(albums.sorted(by: {
            $0.assets.count == $1.assets.count ? $0.name < $1.name : $0.assets.count > $1.assets.count
        }))}
        // smartAlbum 전체 fetch
        let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: PHFetchOptions())
        // 순회하며 앨범단위로 fetch
        smartAlbums.enumerateObjects { [weak self] assetCollection, index, pointer in
            guard let albumTitle = assetCollection.localizedTitle,
                  index <= smartAlbums.count - 1 else {
                pointer.pointee = true
                return
            }
            if assetCollection.estimatedAssetCount == NSNotFound {
                let smartFetchoptions = self?.configureFetchOptions()
                let smartAlbum = PHAsset.fetchAssets(in: assetCollection, options: smartFetchoptions)
                albums.append(Album(name: albumTitle, assets: smartAlbum))
            }
        }
    }
    func configureFetchOptions() -> PHFetchOptions {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        options.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
        return options
    }
}
