
import UIKit
import Photos

protocol AlbumService {
    func getAlbums(completion: @escaping ([Album]) -> Void)
}

final class GalleryAlbumService : AlbumService {
    
    func getAlbums(completion: @escaping ([Album]) -> Void) {
        var albums = [Album]()
        let options = configureFetchOptions()
        defer {completion(albums)}
        let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: PHFetchOptions())
        
        smartAlbums.enumerateObjects { [weak self] assetCollection, index, pointer in
            guard let self, index <= smartAlbums.count - 1 else {
                pointer.pointee = true
                return
            }
            
            if assetCollection.estimatedAssetCount == NSNotFound {
                
                let smartFetchoptions = configureFetchOptions()
                
                let smartAlbum = PHAsset.fetchAssets(in: assetCollection, options: smartFetchoptions)
                albums.append(Album(name: "live", assets: smartAlbum))
            }
        }
        
        
    
    }
    
    func configureFetchOptions() -> PHFetchOptions {
        let options = PHFetchOptions()
        
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        options.predicate = NSPredicate(format: "mediaType == %d && mediaSubTypes == %d", PHAssetMediaType.image.rawValue,PHAssetMediaSubtype.photoLive.rawValue)
        
        return options
    }
    
    
}
