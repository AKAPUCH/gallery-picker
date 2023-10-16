재사용을 염두에 둔 계층은 프로토콜 - 구현체로 설계하여 재사용에 용이하도록 만들기
    단, 필수 구현부는 프로토콜 확장으로 빼서 미리 구현

화면 이동로직은 주체가 되는 뷰컨에서 작성할 것

화면 1  : 최초 화면이자 권한 체크하는 위치

화면 2 : 앨범 접근 및 애셋 가져오기,  컬렉션 뷰에애셋을 표시하는 화면.
    최상단은 선택시 앨범 종류 및 수를 표기하는 테이블 뷰를 표시하는 버튼
    최하단은 1개 이상 선택 시 활성화되는 버튼
# 카메라, 앨범 권한 확인(PhotoAuthService)
여러 곳에서 재사용할 가능성이 높으므로 따로 분리

프로토콜 속성, 함수
- property
    - authorizationStatus : 앨범 권한 상태 속성
    - isAuthorizationLimited : 앨범 권한 상태 확인 속성(확장에서 limited인지 검사)
- method
    - requestAuthorization : 권한 요청 메서드로, authorizationStatus를 검사하고 .authorized 상태가 아니라면 PHPhotoLibrary.requestAuthorization(for: .readWrite) 메서드를 통해 권한 얻어오기

화면1에서 requestAuthorization 호출 및 성공 시 화면2으로 present

# 앨범 접속 및 가져오기(AlbumService)
여러곳에서 재사용 가능하므로 따로 분리
먼저 Photos 라이브러리를 통해 뭉치(`PHFetchResult<PHAsset>`) 형태로 앨범을 가져와야함

 - PHAsset: 사진 라이브러리에 있는 이미지, 비디오와 같은 하나의 애셋을 의미

 - PHAssetCollection: PHAsset의 컬렉션

 - PHFetchResult: 앨범 하나


프로토콜 함수
-  getAlbums
`[PHFetchResult<PHAsset>]` 반환 타입
PHFetchOptions 인스턴스 선언 및 정렬 옵션과 format 설정(생성자가 있음)

앨범에는 스마트 앨범과 기본 앨범이 있음.
    기본적으로 PHAsset.fetchAssets로 Asset뭉치 추출
    스마트 앨범은 PHAssetCollections.fetchAssetCollection을 통해 AssetCollection 1차 분리 후 2차로 Asset뭉치 추출

# Asset, 이미지 추출(PhotoService)
- PHCachingImageManager: 요청한 크기에 맞게 이미지를 로드하여 캐싱까지 수행

프로토콜 함수
- convertAlbumsToAssets : enumerateObjects 메서드를 통해 비동기로 Asset 추출 후 [PHAsset] 타입으로 반환
- fetchImage : PHImageRequestOptions 인스턴스 선언을 통해 fetch 옵션 설정 및 PHCachingImageManager.requestImage 메서드로 이미지 로드
    - 이 때 requestImage의 파라미터 resultHandler에 Image결과값을 completion으로 가져옴


