
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
    
    private let cellIdentifier = "reused"
    private let albumService: AlbumService = GalleryAlbumService()
    private let photoService: PhotoService = GalleryPhotoService()
    private var albums = [PHFetchResult<PHAsset>]()
    private var dataSource = [UIImage]()
    
    private let collectionViewFlowLayout = UICollectionViewFlowLayout()
    private lazy var galleryCollectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewFlowLayout)
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
        self.view.backgroundColor = .red
        setCollectionView()
        setUI()
        loadAlbums(completion: { [weak self] in
            guard let instantImage = UIImage(systemName: "photo.fill"), let albumCount =  self?.albums.count else {return}
            self?.dataSource = Array(repeating: instantImage, count: albumCount+1)
            self?.galleryCollectionView.reloadData()
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
    
    func setCollectionView() {
        collectionViewFlowLayout.scrollDirection = .vertical
        collectionViewFlowLayout.minimumLineSpacing = 1
        collectionViewFlowLayout.minimumInteritemSpacing = 0
        collectionViewFlowLayout.itemSize = Const.cellSize
        galleryCollectionView.isSpringLoaded = true
        galleryCollectionView.showsHorizontalScrollIndicator = false
        galleryCollectionView.showsVerticalScrollIndicator = true
        galleryCollectionView.contentInset = .zero
        galleryCollectionView.backgroundColor = .yellow
        galleryCollectionView.register(GalleryCell.self, forCellWithReuseIdentifier: cellIdentifier)
    }
    
    func setUI() {
        [galleryDropbox,galleryCollectionView,submitButton].forEach{self.view.addSubview($0)}
        galleryDropbox.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(self.view.safeAreaLayoutGuide).offset(20)
        }
        galleryCollectionView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
        }
        submitButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(galleryCollectionView)
            make.bottom.equalToSuperview().offset(-20)
        }
    }


}

extension GalleryViewController : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! GalleryCell
        
        return cell
    }
    
    
}

extension GalleryViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(1)
    }
}
