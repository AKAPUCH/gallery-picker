
import Photos
import UIKit

import SnapKit
import Then

final class GalleryViewController: UIViewController {

    private let albumService: AlbumService = GalleryAlbumService()
    private var photoService: PhotoService = GalleryPhotoService()
    private var albums = [Album]()
    private var albumIndex = 0
    private var selectedIndex = 1
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

    private var selectedDataSource = [CellModel]() {
        didSet{
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
    
    // MARK: - 앱 내 카메라 촬영을 통해 사진 추가를 위해 delegate 지정
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }

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
            self?.loadImages {
                self?.galleryCollectionView.reloadData()
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
        for currentAlbumIndex in 0..<albums.count {
            photoService.convertAlbumToAssets(album: albums[currentAlbumIndex].assets) { [weak self] fetchedAssets in

                var currentDataSource = [CellModel(albumIndex: currentAlbumIndex, order: .zero,image: UIImage(systemName: "camera.fill"),indexPath: IndexPath(item: 0, section: 0),isVisible: false)]
                currentDataSource += fetchedAssets.enumerated().map {
                    CellModel(asset: $1, albumIndex: currentAlbumIndex, order: .zero,indexPath: IndexPath(item: $0 + 1, section: 0),isVisible: false)
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


    // MARK: - 카메라 접근 권한 요청 및 열기
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
    }

    // MARK: - 취소 버튼 선택 시 이전 화면으로 돌아가기
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
        
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SelectedCell.cellIdentifier, for: indexPath) as? SelectedCell else { return UICollectionViewCell() }


            return cell
        
    }
}
    // MARK: - UICollectionViewDelegate
extension GalleryViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

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
    }

}
