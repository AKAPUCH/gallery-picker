
import Photos
import UIKit

import SnapKit

final class GalleryViewController: UIViewController {

    private let albumService: AlbumService = GalleryAlbumService()
    private var photoService: PhotoService = GalleryPhotoService()
    private var albums = [Album]()
    private var albumIndex = 0
    private var selectedIndex = 1
    private var galleryDataSources = [[CellModel]]()
    private var galleryDataSource = [CellModel]()
    private let albumCategoryTableView = UITableView()
    private let galleryCollectionViewFlowLayout = UICollectionViewFlowLayout()
    private let selectedCollectionViewFlowLayout = UICollectionViewFlowLayout()

    private var selectedDataSource = [CellModel]() {
        didSet{
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                submitButton.isEnabled = selectedDataSource.count > 0
                submitButton.backgroundColor = submitButton.isEnabled ? .black : .gray
            }
        }
    }
    private lazy var galleryCollectionView = UICollectionView(frame: .zero, collectionViewLayout: galleryCollectionViewFlowLayout)
    private lazy var selectedCollectionView = UICollectionView(frame: .zero, collectionViewLayout: selectedCollectionViewFlowLayout)
    private lazy var dropboxToggleButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(toggleDropbox), for: .touchUpInside)
        return button
    }()
    private lazy var undoButton = {
        let button = UIButton()
        button.tintColor = .black
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.addTarget(self, action: #selector(endSelection), for: .touchUpInside)
        return button
    }()
    private lazy var submitButton = {
        let button = UIButton()
        button.isEnabled = false
        button.setTitle("OK", for: .disabled)
        button.setTitle("OK", for: .normal)
        button.backgroundColor = .systemGray
        button.addTarget(self, action: #selector(endSelection), for: .touchUpInside)
        return button
    }()
    
    // MARK: - 앱 내 카메라 촬영을 통해 사진 추가를 위해 delegate 지정
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        photoService.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.layer.masksToBounds = true
        setGalleryCollectionView()
        setSelectedCollectionView()
        setAlbumCategoryTableView()
        setLayout()
        loadAlbums(completion: { [weak self] in
            self?.applyData()
        })
    }

    func loadAlbums(completion: @escaping () -> Void) {
        albumService.getAlbums { [weak self] fetchedAlbums in
            guard let self else { return }
            albums = fetchedAlbums
            completion()
        }
    }

    func loadImages(completion: @escaping ([[CellModel]]) -> Void) {
        var fetchedDataSourceArr = [[CellModel]]()
        defer{completion(fetchedDataSourceArr)}
        for currentAlbumIndex in 0..<albums.count {
            photoService.convertAlbumToAssets(album: albums[currentAlbumIndex].assets) { fetchedAssets in
                let currentDataSource = fetchedAssets.enumerated().map {
                    CellModel(asset: $1, albumIndex: currentAlbumIndex, order: .zero,indexPath: IndexPath(item: $0 + 1, section: 0),isVisible: false)
                }
                fetchedDataSourceArr.append(currentDataSource)
            }
        }
    }

    func setSelectedCollectionView() {
        selectedCollectionViewFlowLayout.scrollDirection = .horizontal
        selectedCollectionViewFlowLayout.minimumLineSpacing = 20
        selectedCollectionViewFlowLayout.itemSize = CGSize(width: 80, height: 80)
        selectedCollectionView.isSpringLoaded = true
        selectedCollectionView.showsVerticalScrollIndicator = false
        selectedCollectionView.showsHorizontalScrollIndicator = true
        selectedCollectionView.contentInset = .zero
        selectedCollectionView.dataSource = self
        selectedCollectionView.delegate = self
        selectedCollectionView.register(SelectedCell.self, forCellWithReuseIdentifier: SelectedCell.cellIdentifier)
        selectedCollectionView.backgroundColor = .white
    }

    func setGalleryCollectionView() {
        galleryCollectionViewFlowLayout.scrollDirection = .vertical
        galleryCollectionViewFlowLayout.minimumLineSpacing = 1
        galleryCollectionViewFlowLayout.minimumInteritemSpacing = 0
        galleryCollectionViewFlowLayout.itemSize = CGSize(width: (UIScreen.main.bounds.size.width - 2) / 3, height: (UIScreen.main.bounds.size.width - 2) / 3)
        galleryCollectionView.isSpringLoaded = true
        galleryCollectionView.showsHorizontalScrollIndicator = false
        galleryCollectionView.showsVerticalScrollIndicator = true
        galleryCollectionView.contentInset = .zero
        galleryCollectionView.dataSource = self
        galleryCollectionView.delegate = self
        galleryCollectionView.register(GalleryCell.self, forCellWithReuseIdentifier: GalleryCell.cellIdentifier)
        galleryCollectionView.backgroundColor = .white
    }

    func setAlbumCategoryTableView() {
        albumCategoryTableView.isHidden = true
        albumCategoryTableView.delegate = self
        albumCategoryTableView.dataSource = self
        albumCategoryTableView.rowHeight = 20
        albumCategoryTableView.backgroundColor = .white
        albumCategoryTableView.register(AlbumCategoryTableViewCell.self, forCellReuseIdentifier: AlbumCategoryTableViewCell.cellIdentifier)
    }

    func setLayout() {
        [dropboxToggleButton,selectedCollectionView,galleryCollectionView,submitButton,albumCategoryTableView].forEach{ view.addSubview($0) }
        dropboxToggleButton.addSubview(undoButton)
        dropboxToggleButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(40)
        }
        selectedCollectionView.snp.makeConstraints { make in
            make.top.equalTo(dropboxToggleButton.snp.bottom).offset(20)
            make.left.right.equalToSuperview()
            make.height.equalTo(0)
        }
        galleryCollectionView.snp.makeConstraints { make in
            make.top.equalTo(selectedCollectionView.snp.bottom).offset(20)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-40)
        }
        submitButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(galleryCollectionView.snp.bottom)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        albumCategoryTableView.snp.makeConstraints { make in
            make.top.equalTo(dropboxToggleButton.snp.bottom)
            make.height.equalTo(100)
            make.width.equalTo(view.bounds.size.width / 1.5)
            make.centerX.equalToSuperview()
        }
        undoButton.snp.makeConstraints { make in
            make.height.equalToSuperview()
            make.width.equalTo(dropboxToggleButton.snp.height)
            make.top.trailing.equalToSuperview()
        }
    }

    // MARK: - 사진을 선택했을 때 레이아웃 업데이트
    func changeCollectionViewLayout() {
        if selectedDataSource.count == 0 {
            selectedCollectionView.snp.updateConstraints { make in
                make.height.equalTo(0)
            }
        } else {
            selectedCollectionView.snp.updateConstraints { make in
                make.height.equalTo(80)
            }
        }
    }

    // MARK: - 데이터 로드 및 UI에 반영
    func applyData() {
        loadImages(completion: { [weak self] fetchedDataSourceArr in
            guard let self else { return }
            galleryDataSources = updateSelectedSource(fetchedDataSourceArr)
            selectedDataSource = galleryDataSources.flatMap { $0 }.compactMap { $0 }.filter { $0.order > 0 }.sorted(by: { $0.order < $1.order })
            galleryDataSource = galleryDataSources[albumIndex]
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                dropboxToggleButton.setTitle("\(albums[albumIndex].name) \(albums[albumIndex].assets.count)", for: .normal)
                galleryCollectionView.reloadData()
                selectedCollectionView.reloadData()
                albumCategoryTableView.reloadData()
            }
        })
        
    }

    // MARK: - 시스템 사진 추가/삭제시 수정사항 반영
    func updateSelectedSource(_ fetchedArr: [[CellModel]]) -> [[CellModel]] {
        let migrationArr = fetchedArr
        var deletedOrders = [Int]()
        for (categoryIndex,cellModels) in galleryDataSources.enumerated() {
            let checkedCellModels = cellModels.filter { $0.order > 0 }
            let currentMigrationArr = migrationArr[categoryIndex].map { $0.asset }
            for checkedCellModel in checkedCellModels{
                //변경된 데이터 모델의 order,isVisible 정보 업데이트
                guard let correspondIndex = currentMigrationArr.firstIndex(of: checkedCellModel.asset) else {
                    //변경된 시스템 앨범에서 해당 애셋이 삭제(기존 선택 값들의 order 변경 필요)
                    deletedOrders.append(checkedCellModel.order)
                    continue
                }
                migrationArr[categoryIndex][correspondIndex].order = checkedCellModel.order
                migrationArr[categoryIndex][correspondIndex].isVisible = checkedCellModel.isVisible
                migrationArr[categoryIndex][correspondIndex].image = checkedCellModel.image
            }
        }
        // 삭제된 애셋으로 인한 order, selectedIndex 값 보정
        if deletedOrders.count > 0 {
            var currentOrders = [Int]()
            for categoryIndex in 0..<migrationArr.count {
                if migrationArr[categoryIndex].filter ({ $0.order > 0 }).count == 0 { continue }
                for assetIndex in 0..<migrationArr[categoryIndex].count {
                    if migrationArr[categoryIndex][assetIndex].order == 0 { continue }
                    migrationArr[categoryIndex][assetIndex].order -= deletedOrders.filter { migrationArr[categoryIndex][assetIndex].order > $0 }.count
                    currentOrders.append(migrationArr[categoryIndex][assetIndex].order)
                }
            }
            if let maxIndex = currentOrders.max() {
                selectedIndex = maxIndex
            }
        }
        return migrationArr
    }

    // MARK: - 카메라 접근 권한 요청 및 열기
    func openCamera() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] isAuthorized in
            guard isAuthorized else {
                return
            }
            DispatchQueue.main.async { [weak self] in
                let pickerController = UIImagePickerController()
                pickerController.sourceType = .camera
                pickerController.allowsEditing = false
                pickerController.mediaTypes = ["public.image"]
                pickerController.delegate = self
                self?.present(pickerController, animated: true)
            }
        }
    }

    // MARK: - 사진 선택 시 데이터 변경 및 UI 업데이트
    func reconfigureAfterSelection(_ indexPath: IndexPath, _ targetAlbumIndex: Int) {
        let selectedOrder = galleryDataSources[targetAlbumIndex][indexPath.item - 1].order
        let currentCellModel = galleryDataSources[targetAlbumIndex][indexPath.item - 1]
        var reloadIndexPaths = [IndexPath]()
        reloadIndexPaths.append(indexPath)
        guard let visibility =  currentCellModel.isVisible else { return }
        if visibility { // 선택 해제시
            // 전체 사진 컬렉션뷰에서 해당 사진 order 0으로 초기화
            galleryDataSources[targetAlbumIndex][indexPath.item - 1] = CellModel(asset: currentCellModel.asset,albumIndex: currentCellModel.albumIndex, order: .zero, image: currentCellModel.image,indexPath: nil, isVisible: false)
            // 전체 사진 컬렉션뷰 배열에서 해당 order보다 높은 경우 1씩 감소
            for currentAlbumIndex in 0..<galleryDataSources.count {
                for currentdataSourceIndex in 0..<galleryDataSources[currentAlbumIndex].count {
                    if galleryDataSources[currentAlbumIndex][currentdataSourceIndex].order > selectedOrder {
                        if currentAlbumIndex == albumIndex {
                            reloadIndexPaths.append(IndexPath(item: currentdataSourceIndex + 1, section: 0))
                        }
                        galleryDataSources[currentAlbumIndex][currentdataSourceIndex].order -= 1
                    }
                }
            }
            selectedIndex -= 1
        } else { // 선택시 모델의 order 업데이트
            galleryDataSources[targetAlbumIndex][indexPath.item - 1] = CellModel(asset: currentCellModel.asset,albumIndex: targetAlbumIndex, order: selectedIndex, image: currentCellModel.image,indexPath: indexPath,isVisible: true)
            selectedIndex += 1
        }
        selectedDataSource = galleryDataSources.flatMap { $0 }.compactMap { $0 }.filter { $0.order > 0 }.sorted(by: { $0.order < $1.order })
        galleryDataSource = galleryDataSources[albumIndex]
        //변경사항 UI반영
        galleryCollectionView.performBatchUpdates {
            galleryCollectionView.reconfigureItems(at: reloadIndexPaths)
        } completion: { [weak self] executionResult in
            if executionResult {
                self?.changeCollectionViewLayout()
                self?.selectedCollectionView.reloadData()
            }
        }
    }

    // MARK: - dropboxToggleButton 선택 시 테이블 뷰 표시/숨기기
    @objc func toggleDropbox() {
        if albumCategoryTableView.isHidden {
            view.bringSubviewToFront(albumCategoryTableView)
            albumCategoryTableView.snp.updateConstraints { make in
                make.height.equalTo(Int(albumCategoryTableView.rowHeight) * albums.count)
            }
        } else {
            view.sendSubviewToBack(albumCategoryTableView)
            albumCategoryTableView.snp.updateConstraints { make in
                make.height.equalTo(0)
            }
        }
        albumCategoryTableView.isHidden.toggle()
        albumCategoryTableView.reloadData()
    }

    // MARK: - 취소 버튼 선택 시 이전 화면으로 돌아가기
    @objc func endSelection(_ sender: UIButton) {
        dismiss(animated: true)
    }
}

    // MARK: - UICollectionViewDataSource
extension GalleryViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let columnCount = collectionView == selectedCollectionView ? selectedDataSource.count : galleryDataSource.count + 1
        return columnCount
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        if collectionView == selectedCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SelectedCell.cellIdentifier, for: indexPath) as? SelectedCell else { return UICollectionViewCell() }

            let imageInfo = selectedDataSource[indexPath.item]

            cell.selectedImageView.image = imageInfo.image
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GalleryCell.cellIdentifier, for: indexPath) as? GalleryCell else { return UICollectionViewCell() }

            // 갤러리 컬렉션 뷰의 첫 아이템은 카메라 접근 cell 넣기
            guard indexPath.item != 0 else {
                let cameraAccessImage = UIImage(systemName: "camera.fill")
                cell.galleryImageView.tintColor = .white
                cell.galleryImageView.backgroundColor = .systemGray
                cell.galleryImageView.contentMode = .center
                cell.galleryImageView.image = cameraAccessImage
                return cell
            }

            let imageInfo = galleryDataSources[albumIndex][indexPath.item - 1]
            let imageSize = CGSize(width: (UIScreen.main.bounds.size.width - 2) / 3 * UIScreen.main.scale, height: (UIScreen.main.bounds.size.width - 2) / 3 * UIScreen.main.scale)
            cell.orderLabel.text = "\(galleryDataSources[albumIndex][indexPath.item - 1].order)"
            //이미지 로드
            if let currentAsset = imageInfo.asset{
                photoService.fetchImage(asset: currentAsset, size: imageSize, contentMode: .aspectFit) { [weak self] fetchedImage in
                    guard let self else { return }
                    galleryDataSources[albumIndex][indexPath.item - 1].image = fetchedImage
                    cell.prepareCell(galleryDataSources[albumIndex][indexPath.item - 1])
                }
                // 카메라 접근 cell이 재사용되는 것 방지
            }else {
                cell.prepareCell(galleryDataSources[albumIndex][indexPath.item - 1])
            }
            return cell
        }
    }
}
    // MARK: - UICollectionViewDelegate
extension GalleryViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // selectedCollectionView의 사진 선택 시 양쪽 컬렉션 뷰의 선택 모두 해제
        if collectionView == selectedCollectionView {
            let targetItem = selectedDataSource[indexPath.item]
            guard let targetIndexPath = targetItem.indexPath else { return }
            reconfigureAfterSelection(targetIndexPath,targetItem.albumIndex)
        } else { // galleryCollectionView 사진 선택시
            //첫 셀은 카메라 앱 열기
            guard indexPath.item != 0 else {
                openCamera()
                return
            }
            // 첫 셀이 아닌 경우 양쪽 컬렉션 뷰 데이터모델의 isVisible 속성에 따라 선택/해제
            reconfigureAfterSelection(indexPath,albumIndex)
        }
    }
}
    // MARK: - UITableViewDataSource
extension GalleryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albums.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: AlbumCategoryTableViewCell.cellIdentifier, for: indexPath) as? AlbumCategoryTableViewCell else {return UITableViewCell()}
        cell.categoryLabel.text = albums[indexPath.row].name
        cell.countLabel.text = "\(albums[indexPath.row].assets.count)"
        return cell
    }
}
    // MARK: - UITableViewDelegate
extension GalleryViewController: UITableViewDelegate {

    // MARK: - 앨범 카테고리 선택 시 갤러리 컬렉션 뷰 전환 및 테이블 뷰 숨기기
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        albumIndex = indexPath.row
        toggleDropbox()
        galleryDataSource = galleryDataSources[albumIndex]
        dropboxToggleButton.setTitle("\(albums[albumIndex].name) \(albums[albumIndex].assets.count)", for: .normal)
        galleryCollectionView.reloadData()
    }
}
    // MARK: - UINavigationControllerDelegate, UIImagePickerControllerDelegate
extension GalleryViewController: UINavigationControllerDelegate,UIImagePickerControllerDelegate {

    // MARK: - 사진 촬영 후 완료 시 카메라 앱 나가기 및 시스템 앨범에 새 사진 반영
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            picker.dismiss(animated: true)
            return
        }
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        picker.dismiss(animated: true, completion: nil)
    }
}
    // MARK: - PhotoServiceDelegate
extension GalleryViewController: PhotoServiceDelegate {
    func applyDatas() {
        loadAlbums(completion: { [weak self] in
            self?.applyData()
        })
    }
}
