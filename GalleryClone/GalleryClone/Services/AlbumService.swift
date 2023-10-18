
import UIKit
import Photos

protocol AlbumService {
    func getAlbums(completion: @escaping ([Album]) -> Void)
}

final class GalleryAlbumService : AlbumService {
    
    func getAlbums(completion: @escaping ([Album]) -> Void) {
        var albums = [Album]()
        let options = configureFetchOptions()
        let standardAlbum = PHAsset.fetchAssets(with: options)

        defer {completion(albums.sorted(by: {
            $0.assets.count == $1.assets.count ? $0.name.count < $1.name.count : $0.assets.count > $1.assets.count
        }))}

        albums.append(Album(name: "standard", assets: standardAlbum))

        let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: PHFetchOptions())

        smartAlbums.enumerateObjects { [weak self] assetCollection, index, pointer in
            guard let self,let albumTitle = assetCollection.localizedTitle, index <= smartAlbums.count - 1 else {
                pointer.pointee = true
                return
            }
            
            if assetCollection.estimatedAssetCount == NSNotFound {

                let smartFetchoptions = configureFetchOptions()
                
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
