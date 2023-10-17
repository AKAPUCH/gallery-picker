
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
    private var albums = [PHFetchResult<PHAsset>]()
    private var albumIndex = 0
    private var selectedIndex = 1
    private var dataSource = [CellModel]()
    private var selectedSource = [CellModel]() {
        didSet {
            selectedCollectionView.reloadData()
        }
    }
    
    private let galleryCollectionViewFlowLayout = UICollectionViewFlowLayout()
    private lazy var galleryCollectionView = UICollectionView(frame: .zero, collectionViewLayout: galleryCollectionViewFlowLayout)
    
    private let selectedCollectionViewFlowLayout = UICollectionViewFlowLayout()
    private lazy var selectedCollectionView = UICollectionView(frame: .zero, collectionViewLayout: selectedCollectionViewFlowLayout)
    
    private let galleryDropbox = {
       let button = UIButton()
        button.backgroundColor = .white
        return button
    }()
    
    private let submitButton = {
        let button = UIButton()
        button.isEnabled = false
        button.setTitle("OK", for: .disabled)
        button.setTitle("OK", for: .normal)
        button.backgroundColor = .systemGray
        return button
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        setGalleryCollectionView()
        setSelectedCollectionView()
        setUI()
        loadAlbums(completion: { [weak self] in
            self?.loadImages()
        })
    }
    
    func loadAlbums(completion: @escaping () -> Void) {
        albumService.getAlbums { [weak self] fetchedAlbums in
            guard let self else {return}
            galleryDropbox.setTitle(fetchedAlbums.first?.name,for: .normal)
            albums = fetchedAlbums.map{$0.assets}
            completion()
        }
    }
    
    func loadImages() {
        guard albumIndex < albums.count else {return}
        photoService.convertAlbumToAssets(album: albums[albumIndex]) { [weak self] fetchedAssets in
            guard let self else {return}
            dataSource = fetchedAssets.map{CellModel(asset: $0, order: .zero)}
            galleryCollectionView.reloadData()
        }
    }
    
    func setSelectedCollectionView() {

        selectedCollectionViewFlowLayout.scrollDirection = .horizontal
        selectedCollectionViewFlowLayout.minimumLineSpacing = 20
//        selectedCollectionViewFlowLayout.minimumInteritemSpacing = 2
        selectedCollectionViewFlowLayout.itemSize = CGSize(width: 50, height: 50)
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
    
    func setUI() {
        [galleryDropbox,selectedCollectionView,galleryCollectionView,submitButton].forEach{self.view.addSubview($0)}
        galleryDropbox.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(20)
        }
        selectedCollectionView.snp.makeConstraints { make in
            make.top.equalTo(galleryDropbox.snp.bottom).offset(20)
            make.left.right.equalToSuperview()
            make.height.equalTo(50)
        }
        galleryCollectionView.snp.makeConstraints { make in
            make.top.equalTo(selectedCollectionView.snp.bottom).offset(20)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(self.view.safeAreaLayoutGuide).offset(-20)
        }
        submitButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(galleryCollectionView.snp.bottom)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
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
          self?.present(pickerController, animated: true)
        }
      }
    }


}

extension GalleryViewController : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let columnCount = collectionView.tag == 1 ? selectedSource.count : dataSource.count + 1
        return columnCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView.tag == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SelectedCell.cellIdentifier, for: indexPath) as! SelectedCell
            
            let imageInfo = selectedSource[indexPath.item]
            let currentAsset = imageInfo.asset
            let imageSize = CGSize(width: 50 * Const.scale, height: 50 * Const.scale)
            
            cell.selectedImageView.image = imageInfo.image
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GalleryCell.cellIdentifier, for: indexPath) as! GalleryCell
            guard indexPath.item != 0 else {
                let cameraAccessImage = UIImage(systemName: "camera.fill")
                cell.galleryImageView.tintColor = .white
                cell.galleryImageView.backgroundColor = .systemGray
                cell.galleryImageView.contentMode = .scaleAspectFit
                cell.galleryImageView.image = cameraAccessImage
                return cell
            }
            
            var imageInfo = dataSource[indexPath.item-1]
            let currentAsset = imageInfo.asset
            let imageSize = CGSize(width: Const.cellSize.width * Const.scale, height: Const.cellSize.height * Const.scale)
            
            photoService.fetchImage(asset: currentAsset, size: imageSize, contentMode: .aspectFit) { fetchedImage in
                self.dataSource[indexPath.item-1].image = fetchedImage
                cell.galleryImageView.image = fetchedImage
            }
            return cell
        }
        
    }
    
    
}

extension GalleryViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView.tag == 1 {
            
            collectionView.performBatchUpdates {
                selectedSource.remove(at: indexPath.item)
                collectionView.deleteItems(at: [indexPath])
            }
        } else {
            guard indexPath.item != 0 else {
                openCamera()
                return
            }
            let cell = collectionView.cellForItem(at: indexPath) as! GalleryCell
            cell.selectedEffectView.isHidden.toggle()
            cell.orderLabel.isHidden.toggle()
            cell.orderLabel.text = "\(selectedIndex)"
            let dif = cell.orderLabel.isHidden ? -1 : 1
            
            if !cell.orderLabel.isHidden {
                dataSource[indexPath.item-1].order = selectedIndex
                selectedSource.append(dataSource[indexPath.item-1])
            } else {
                dataSource[indexPath.item-1].order = selectedIndex - 1
                selectedSource.remove(at: dataSource[indexPath.item-1].order-1)
            }
            selectedIndex += dif
        }
        
    }
}

