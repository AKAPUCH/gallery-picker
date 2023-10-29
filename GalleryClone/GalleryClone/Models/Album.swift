
import Photos

// 시스템 사진 라이브러리의 fetch 결과를 저장하는 데이터 모델
final class Album {

    let name: String
    let assets: PHFetchResult<PHAsset>

    init(name: String, assets: PHFetchResult<PHAsset>) {
        self.name = name
        self.assets = assets
    }
}
