
import Photos
import UIKit

import SnapKit
import Then

final class GalleryViewController: UIViewController {

    private let albumService: AlbumService = GalleryAlbumService()
    private var photoService: PhotoService = GalleryPhotoService()
    private var albums = [Album]()
    private var albumIndex = 0
    private var galleryDataSources = [[CellModel]]()
    private var galleryDataSource = [CellModel]()

    private let albumCategoryTableView = UITableView().then {
        $0.isHidden = true
        $0.rowHeight = 20
        $0.backgroundColor = .white
        $0.register(AlbumCategoryTableViewCell.self, forCellReuseIdentifier: AlbumCategoryTableViewCell.cellIdentifier)
    }

    private let galleryCollectionViewFlowLayout = UICollectionViewFlowLayout().then {
        $0.scrollDirection = .vertical
        $0.minimumLineSpacing = 1
        $0.minimumInteritemSpacing = 0
        $0.itemSize = CGSize(width: (UIScreen.main.bounds.size.width - 2) / 3, height: (UIScreen.main.bounds.size.width - 2) / 3)
    }

    private let selectedCollectionViewFlowLayout = UICollectionViewFlowLayout().then {
        $0.scrollDirection = .horizontal
        $0.minimumLineSpacing = 20
        $0.itemSize = CGSize(width: 80, height: 80)
    }

    // 선택된 데이터 추가/삭제 시 order와 버튼 속성 지속적으로 변경
    private var selectedDataSource = [CellModel]() {
        didSet{
            for (index,cellModel) in selectedDataSource.enumerated() {
                cellModel.order = index + 1
            }
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                submitButton.isEnabled = selectedDataSource.count > 0
                submitButton.backgroundColor = submitButton.isEnabled ? .black : .gray
            }
        }
    }

    private lazy var galleryCollectionView = UICollectionView(frame: .zero, collectionViewLayout: galleryCollectionViewFlowLayout).then {
        $0.isSpringLoaded = true
        $0.showsHorizontalScrollIndicator = false
        $0.showsVerticalScrollIndicator = true
        $0.contentInset = .zero
        $0.register(GalleryCell.self, forCellWithReuseIdentifier: GalleryCell.cellIdentifier)
        $0.backgroundColor = .white
    }

    private lazy var selectedCollectionView = UICollectionView(frame: .zero, collectionViewLayout: selectedCollectionViewFlowLayout).then {
        $0.isSpringLoaded = true
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = true
        $0.contentInset = .zero
        $0.register(SelectedCell.self, forCellWithReuseIdentifier: SelectedCell.cellIdentifier)
        $0.backgroundColor = .white
    }

    private lazy var dropboxToggleButton = UIButton().then {
        $0.backgroundColor = .white
        $0.setTitleColor(.black, for: .normal)
        $0.addTarget(self, action: #selector(toggleDropbox), for: .touchUpInside)
    }

    private lazy var undoButton = UIButton().then {
        $0.tintColor = .black
        $0.setImage(UIImage(systemName: "xmark"), for: .normal)
        $0.addTarget(self, action: #selector(endSelection), for: .touchUpInside)
    }

    private lazy var submitButton = UIButton().then {
        $0.isEnabled = false
        $0.setTitle("OK", for: .disabled)
        $0.setTitle("OK", for: .normal)
        $0.backgroundColor = .systemGray
        $0.addTarget(self, action: #selector(endSelection), for: .touchUpInside)
    }

    // 화면 로드 시 delegate 설정 및 시스템 사진 라이브러리 데이터 로드
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.layer.masksToBounds = true
        photoService.delegate = self
        albumCategoryTableView.delegate = self
        albumCategoryTableView.dataSource = self
        galleryCollectionView.delegate = self
        galleryCollectionView.dataSource = self
        selectedCollectionView.delegate = self
        selectedCollectionView.dataSource = self
        setLayout()
        loadAlbums(completion: { [weak self] in
            self?.loadImages { [weak self] in
                guard let self else { return }
                galleryDataSource = galleryDataSources[albumIndex]
                dropboxToggleButton.setTitle("\(albums[albumIndex].name) \(albums[albumIndex].assets.count)", for: .normal)
            }
        })
    }

    func loadAlbums(completion: @escaping () -> Void) {
        albumService.getAlbums { [weak self] loadedAlbums in
            self?.albums = loadedAlbums
            completion()
        }
    }

    func loadImages(completion: @escaping () -> Void) {
        defer{
            completion()
        }
        galleryDataSources.removeAll()
        for currentAlbumIndex in 0..<albums.count {
            photoService.convertAlbumToAssets(album: albums[currentAlbumIndex].assets) { [weak self] fetchedAssets in

                var currentDataSource = [CellModel(albumIndex: currentAlbumIndex, order: .zero,image: UIImage(systemName: "camera.fill"),isVisible: false)]
                currentDataSource += fetchedAssets.enumerated().map {
                    CellModel(asset: $1, albumIndex: currentAlbumIndex, order: .zero, isVisible: false)
                }
                self?.galleryDataSources.append(currentDataSource)
            }
        }
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

    // 사진을 선택했을 때 레이아웃 업데이트
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

    // 카메라 접근 권한 요청 및 열기
    func openCamera() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] isAuthorized in
            guard isAuthorized else {
                return
            }
            DispatchQueue.main.async { [weak self] in
                let pickerController = UIImagePickerController().then {
                    $0.sourceType = .camera
                    $0.allowsEditing = false
                    $0.mediaTypes = ["public.image"]
                }
                pickerController.delegate = self
                self?.present(pickerController, animated: true)
            }
        }
    }

    // dropboxToggleButton 선택 시 테이블 뷰 표시/숨기기
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
    }

    // 취소 버튼 선택 시 이전 화면으로 돌아가기
    @objc func endSelection(_ sender: UIButton) {
        dismiss(animated: true)
    }
}

// MARK: - UICollectionViewDataSource
extension GalleryViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let columnCount = collectionView == selectedCollectionView ? selectedDataSource.count : galleryDataSource.count
        return columnCount
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let imageSize = CGSize(width: (UIScreen.main.bounds.size.width - 2) / 3 * UIScreen.main.scale, height: (UIScreen.main.bounds.size.width - 2) / 3 * UIScreen.main.scale)

        // selectedCollectionView case
        if collectionView == selectedCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SelectedCell.cellIdentifier, for: indexPath) as? SelectedCell else { return UICollectionViewCell() }
            let currentCellModel = selectedDataSource[indexPath.item]
            cell.selectedCellModel = currentCellModel
            cell.prepareForReuse()
            return cell
        
        } else { // galleryCollectionView case
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GalleryCell.cellIdentifier, for: indexPath) as? GalleryCell else { return UICollectionViewCell() }
            let currentCellModel = galleryDataSource[indexPath.item]
            cell.galleryCellModel = currentCellModel
            cell.prepareForReuse()
            // 이미지가 없을 경우 로드
            if currentCellModel.image == nil,
               let untransformedAsset = currentCellModel.asset {
                photoService.fetchImage(asset: untransformedAsset, size: imageSize, contentMode: .aspectFit) { loadedImage in
                    currentCellModel.image = loadedImage
                    cell.prepareForReuse()
                }
            }
            return cell
        }
    }
}

// MARK: - UICollectionViewDelegate
extension GalleryViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //selectedCollectionView case
        if collectionView == selectedCollectionView {
            // 선택된 cellModel order, isSelected 초기화 및 배열에서 제거
            let currentData = selectedDataSource[indexPath.item]
            selectedDataSource.remove(at: indexPath.item)
            currentData.order = .zero
            currentData.isSelected.toggle()
        } else { //galleryCollectionView case
            //첫 셀은 카메라 앱 열기
            guard indexPath.item != 0 else {
                openCamera()
                return
            }
            let currentData = galleryDataSource[indexPath.item]
            if currentData.isSelected { // 선택된 cell 재선택시 order, isSelected 초기화 및 배열에서 제거
                guard let index = selectedDataSource.firstIndex(of: currentData) else { return }
                selectedDataSource.remove(at: index)
                currentData.order = .zero
            } else { // 선택 시 배열에 추가
                selectedDataSource.append(currentData)
            }
            currentData.isSelected.toggle()
        }
        changeCollectionViewLayout()
        selectedCollectionView.reloadData()
        galleryCollectionView.reloadData()
    }
}

// MARK: - UITableViewDataSource
extension GalleryViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albums.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: AlbumCategoryTableViewCell.cellIdentifier, for: indexPath) as? AlbumCategoryTableViewCell else {return UITableViewCell()}
        cell.cellAlbum = albums[indexPath.item]
        cell.prepareForReuse()
        return cell
    }
}

// MARK: - UITableViewDelegate
extension GalleryViewController: UITableViewDelegate {

    // 앨범 카테고리 선택 시 갤러리 컬렉션 뷰 전환 및 테이블 뷰 숨기기
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        albumIndex = indexPath.row
        galleryDataSource = galleryDataSources[albumIndex]
        galleryCollectionView.reloadData()
        toggleDropbox()
        dropboxToggleButton.setTitle("\(albums[albumIndex].name) \(albums[albumIndex].assets.count)", for: .normal)
    }
}

// MARK: - UINavigationControllerDelegate, UIImagePickerControllerDelegate
extension GalleryViewController: UINavigationControllerDelegate,UIImagePickerControllerDelegate {

    // 사진 촬영 후 완료 시 카메라 앱 나가기 및 시스템 앨범에 새 사진 반영
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

    // 사진 라이브러리 변화 감지 시 데이터 재 로드 및 UI 다시 그리기
    func applyDatas() {
        loadAlbums(completion: { [weak self] in
            self?.loadImages { [weak self] in
                guard let self else { return }
                for (currentIndex,selectedCellModel) in selectedDataSource.enumerated() {
                    let targetDataSource = galleryDataSources[selectedCellModel.albumIndex]
                    guard let selectedAsset = selectedCellModel.asset else { return }
                    let changedModel = targetDataSource.filter { $0.asset == selectedAsset }
                    if changedModel.count > 0  { // 이전에 선택되었던 cellModel 정보 동기화
                        changedModel[0].image = selectedCellModel.image
                        changedModel[0].isSelected = selectedCellModel.isSelected
                        changedModel[0].order = selectedCellModel.order
                        selectedDataSource[selectedCellModel.order - 1] = changedModel[0]
                    } else { // 삭제된 asset 반영
                        selectedDataSource.remove(at: currentIndex)
                    }
                }
                // UI 업데이트
                galleryDataSource = galleryDataSources[albumIndex]
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    dropboxToggleButton.setTitle("\(albums[albumIndex].name) \(albums[albumIndex].assets.count)", for: .normal)
                    galleryCollectionView.reloadData()
                    selectedCollectionView.reloadData()
                }
            }
        })
    }
}
