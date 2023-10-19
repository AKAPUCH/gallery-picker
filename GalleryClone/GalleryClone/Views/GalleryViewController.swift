
import UIKit
import Photos
import SnapKit

final class GalleryViewController: UIViewController {
    
    private enum Const {
        static let numberOfColumns = 3.0
        static let cellSpace = 1.0
        static let length = (UIScreen.main.bounds.size.width - cellSpace * (numberOfColumns - 1)) / numberOfColumns
        static let cellSize = CGSize(width: length, height: length)
        static let scale = UIScreen.main.scale
    }
    
    private let albumService: AlbumService = GalleryAlbumService()
    private let photoService: PhotoService = GalleryPhotoService()
    private var albums = [Album]()
    private var albumAssets = [PHFetchResult<PHAsset>]()
    private var albumIndex = 0
    private var selectedIndex = 1
    private var dataSourceArr = [[CellModel]]()
    private var dataSource = [CellModel]()
    private var selectedSource = [CellModel]() {
        didSet {
            submitButton.isEnabled = selectedSource.count > 0
            submitButton.backgroundColor = submitButton.isEnabled ? .black : .gray
        }
    }
    
    private let galleryCollectionViewFlowLayout = UICollectionViewFlowLayout()
    private lazy var galleryCollectionView = UICollectionView(frame: .zero, collectionViewLayout: galleryCollectionViewFlowLayout)
    
    private let selectedCollectionViewFlowLayout = UICollectionViewFlowLayout()
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
    
    private let albumCategoryTableView = UITableView()
    
    private lazy var submitButton = {
        let button = UIButton()
        button.isEnabled = false
        button.setTitle("OK", for: .disabled)
        button.setTitle("OK", for: .normal)
        button.backgroundColor = .systemGray
        button.addTarget(self, action: #selector(endSelection), for: .touchUpInside)
        return button
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.view.layer.masksToBounds = true
        setGalleryCollectionView()
        setSelectedCollectionView()
        setAlbumCategoryTableView()
        setUI()
        loadAlbums(completion: { [weak self] in
            self?.loadImages(completion: { [weak self] in
                guard let self else {return}
                dropboxToggleButton.setTitle("\(albums[albumIndex].name) \(albums[albumIndex].assets.count)", for: .normal)
                dataSource = dataSourceArr[albumIndex]
                galleryCollectionView.reloadData()
            })
        })
    }
    
    func loadAlbums(completion: @escaping () -> Void) {
        albumService.getAlbums { [weak self] fetchedAlbums in
            guard let self else {return}
            albums = fetchedAlbums
            albumAssets = albums.map{$0.assets}
            completion()
        }
    }
    
    func loadImages(completion: @escaping () -> Void) {
        defer{completion()}
        for currentAlbumIndex in 0..<albums.count {
            photoService.convertAlbumToAssets(album: albumAssets[currentAlbumIndex]) { [weak self] fetchedAssets in
                guard let self else {return}
                let currentDataSource = fetchedAssets.map{CellModel(asset: $0, albumIndex: self.albumIndex, order: .zero,isVisible: false)}
                dataSourceArr.append(currentDataSource)
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
        selectedCollectionView.tag = 1
        selectedCollectionView.backgroundColor = .white
    }
    
    func setGalleryCollectionView() {
        galleryCollectionViewFlowLayout.scrollDirection = .vertical
        galleryCollectionViewFlowLayout.minimumLineSpacing = 1
        galleryCollectionViewFlowLayout.minimumInteritemSpacing = 0
        galleryCollectionViewFlowLayout.itemSize = Const.cellSize
        galleryCollectionView.isSpringLoaded = true
        galleryCollectionView.showsHorizontalScrollIndicator = false
        galleryCollectionView.showsVerticalScrollIndicator = true
        galleryCollectionView.contentInset = .zero
        galleryCollectionView.dataSource = self
        galleryCollectionView.delegate = self
        galleryCollectionView.register(GalleryCell.self, forCellWithReuseIdentifier: GalleryCell.cellIdentifier)
        galleryCollectionView.tag = 2
    }
    
    func setAlbumCategoryTableView() {
        albumCategoryTableView.isHidden = true
        albumCategoryTableView.delegate = self
        albumCategoryTableView.dataSource = self
        albumCategoryTableView.rowHeight = 20
        albumCategoryTableView.backgroundColor = .white
        albumCategoryTableView.register(AlbumCategoryTableViewCell.self, forCellReuseIdentifier: AlbumCategoryTableViewCell.cellIdentifier)
    }
    
    func setUI() {
        [dropboxToggleButton,selectedCollectionView,galleryCollectionView,submitButton,albumCategoryTableView].forEach{self.view.addSubview($0)}
        dropboxToggleButton.addSubview(undoButton)
        dropboxToggleButton.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(40)
        }
        selectedCollectionView.snp.makeConstraints { make in
            make.top.equalTo(dropboxToggleButton.snp.bottom).offset(20)
            make.left.right.equalToSuperview()
            make.height.equalTo(0)
        }
        galleryCollectionView.snp.makeConstraints { make in
            make.top.equalTo(selectedCollectionView.snp.bottom).offset(20)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(self.view.safeAreaLayoutGuide).offset(-40)
        }
        submitButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(galleryCollectionView.snp.bottom)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
        }
        albumCategoryTableView.snp.makeConstraints { make in
            make.top.equalTo(dropboxToggleButton.snp.bottom)
            make.height.equalTo(100)
            make.width.equalTo(self.view.bounds.size.width / 1.5)
            make.centerX.equalToSuperview()
        }
        undoButton.snp.makeConstraints { make in
            make.height.equalToSuperview()
            make.width.equalTo(dropboxToggleButton.snp.height)
            make.top.trailing.equalToSuperview()
        }
    }
    
    func changeCollectionViewLayout() {
        if selectedSource.count == 0 {
            selectedCollectionView.snp.updateConstraints { make in
                make.height.equalTo(0)
            }
        } else {
            selectedCollectionView.snp.updateConstraints { make in
                make.height.equalTo(80)
            }
        }
    }
    
    func openCamera() {
        // Privacy - Camera Usage Description
        AVCaptureDevice.requestAccess(for: .video) { [weak self] isAuthorized in
            guard isAuthorized else {
                return
            }
            DispatchQueue.main.async {
                let pickerController = UIImagePickerController()
                pickerController.sourceType = .camera
                pickerController.allowsEditing = false
                pickerController.mediaTypes = ["public.image"]
                pickerController.delegate = self
                self?.present(pickerController, animated: true)
            }
        }
    }
    
    func reconfigureAfterSelection(_ indexPath: IndexPath, _ targetAlbumIndex: Int) {
        
        
        let selectedOrder = dataSourceArr[targetAlbumIndex][indexPath.item-1].order
        let currentCellModel = dataSourceArr[targetAlbumIndex][indexPath.item-1]
        var reloadIndexPaths = [IndexPath]()
        reloadIndexPaths.append(indexPath)
        guard let visibility =  currentCellModel.isVisible else {return}
        if visibility { // 선택 해제시
            // 전체 사진 컬렉션뷰에서 해당 사진 order 0으로 초기화
            dataSourceArr[targetAlbumIndex][indexPath.item-1] = CellModel(asset: currentCellModel.asset,albumIndex: currentCellModel.albumIndex, order: .zero, image: currentCellModel.image,indexPath: nil, isVisible: false)
            // 전체 사진 컬렉션뷰 배열에서 해당 order보다 높은 경우 1씩 감소
            for currentAlbumIndex in 0..<dataSourceArr.count {
                for currentdataSourceIndex in 0..<dataSourceArr[currentAlbumIndex].count{
                    if dataSourceArr[currentAlbumIndex][currentdataSourceIndex].order > selectedOrder {
                        if currentAlbumIndex == albumIndex {
                            reloadIndexPaths.append(IndexPath(item: currentdataSourceIndex+1, section: 0))
                        }
                        dataSourceArr[currentAlbumIndex][currentdataSourceIndex].order -= 1
                    }
                }
            }
            selectedIndex-=1
        } else { // 선택
            dataSourceArr[targetAlbumIndex][indexPath.item-1] = CellModel(asset: currentCellModel.asset,albumIndex: targetAlbumIndex, order: selectedIndex, image: currentCellModel.image,indexPath: indexPath,isVisible: true)
            selectedIndex+=1
        }
        
        selectedSource = dataSourceArr.flatMap{$0}.compactMap{$0}.filter{$0.order > 0}.sorted(by: {$0.order<$1.order})
        dataSource = dataSourceArr[albumIndex]
        galleryCollectionView.performBatchUpdates {
            galleryCollectionView.reconfigureItems(at: reloadIndexPaths)
            
        } completion: { executionResult in
            if executionResult {
                self.changeCollectionViewLayout()
                self.selectedCollectionView.reloadData()
            }
        }
    }
    
    @objc func toggleDropbox() {
        if albumCategoryTableView.isHidden {
            self.view.bringSubviewToFront(self.albumCategoryTableView)
            albumCategoryTableView.snp.updateConstraints { make in
                make.height.equalTo(Int(albumCategoryTableView.rowHeight) * albums.count)
            }
            
        } else {
            self.view.sendSubviewToBack(self.albumCategoryTableView)
            albumCategoryTableView.snp.updateConstraints { make in
                make.height.equalTo(0)
            }
        }
        albumCategoryTableView.isHidden.toggle()
        
    }
    
    @objc func endSelection(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    
}

extension GalleryViewController : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let columnCount = collectionView.tag == 1 ? selectedSource.count : dataSource.count + 1
        return columnCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView.tag == 1 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SelectedCell.cellIdentifier, for: indexPath) as? SelectedCell else {return UICollectionViewCell()}
            
            let imageInfo = selectedSource[indexPath.item]
            
            cell.selectedImageView.image = imageInfo.image
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GalleryCell.cellIdentifier, for: indexPath) as? GalleryCell else {return UICollectionViewCell()}
            guard indexPath.item != 0 else {
                let cameraAccessImage = UIImage(systemName: "camera.fill")
                cell.galleryImageView.tintColor = .white
                cell.galleryImageView.backgroundColor = .systemGray
                cell.galleryImageView.contentMode = .center
                cell.galleryImageView.image = cameraAccessImage
                return cell
            }
            
            let imageInfo = dataSourceArr[albumIndex][indexPath.item-1]
            let imageSize = CGSize(width: Const.cellSize.width * Const.scale, height: Const.cellSize.height * Const.scale)
            cell.orderLabel.text = "\(dataSourceArr[albumIndex][indexPath.item-1].order)"
            if let currentAsset = imageInfo.asset{
                photoService.fetchImage(asset: currentAsset, size: imageSize, contentMode: .aspectFit) { [weak self] fetchedImage in
                    guard let self else {return}
                    dataSourceArr[albumIndex][indexPath.item-1].image = fetchedImage
                    cell.prepareCell(dataSourceArr[albumIndex][indexPath.item-1])
                }
            }else {
                cell.prepareCell(dataSourceArr[albumIndex][indexPath.item-1])
            }
            return cell
        }
    }
}

extension GalleryViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView.tag == 1 {
            let targetItem = selectedSource[indexPath.item]
            guard let targetIndexPath = targetItem.indexPath else {return}
            reconfigureAfterSelection(targetIndexPath,targetItem.albumIndex)
        } else {
            guard indexPath.item != 0 else {
                openCamera()
                return
            }
            reconfigureAfterSelection(indexPath,albumIndex)
        }
    }
}

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

extension GalleryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        albumIndex = indexPath.row
        toggleDropbox()
        dataSource = dataSourceArr[albumIndex]
        galleryCollectionView.reloadData()

//        loadAlbums(completion: { [weak self] in
//            self?.loadImages(completion: <#() -> Void#>)
//        })
    }
}

extension GalleryViewController: UINavigationControllerDelegate,UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            picker.dismiss(animated: true)
            return
        }
        
        dataSourceArr[0].append(CellModel(albumIndex: albumIndex,order:.zero,image: image,indexPath: IndexPath(item: dataSourceArr[0].count, section: 0),isVisible: false))
        galleryCollectionView.reloadData()
        
        
        picker.dismiss(animated: true, completion: nil)
    }
}

