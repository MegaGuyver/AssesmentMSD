//
//  PhotoEditorViewController.swift
//  MetalFilters
//
//  Created by Fahad on 27/02/2023
//

import UIKit
import Photos
import MetalPetal

class PhotoEditorViewController: UIViewController {

    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var filtersView: UIView!
    
    fileprivate var filterCollectionView: UICollectionView!
    fileprivate var filterControlView: FilterControlView?
    fileprivate var imageView: MTIImageView!
    
    public var croppedImage: UIImage!
    
    fileprivate var originInputImage: MTIImage?
    
    fileprivate var allFilters: [MTFilter.Type] = []
    fileprivate var thumbnails: [String: UIImage] = [:]
    fileprivate var cachedFilters: [Int: MTFilter] = [:]
    fileprivate var currentSelectFilterIndex: Int = 0
    fileprivate var showUnEditedGesture: UILongPressGestureRecognizer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        imageView = MTIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height - 150))
        imageView.resizingMode = .aspectFill
        imageView.backgroundColor = .clear
        self.view.addSubview(imageView)
        allFilters = MTFilterManager.shared.allFilters
        
        setupFilterCollectionView()
    
        let ciImage = CIImage(cgImage: croppedImage.cgImage!)
        let originImage = MTIImage(ciImage: ciImage, isOpaque: true)
        originInputImage = originImage
        imageView.image = originImage
        
        generateFilterThumbnails()
        setupNavigationButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if showUnEditedGesture == nil {
            let gesture = UILongPressGestureRecognizer(target: self, action: #selector(showUnEditPhotoGesture(_:)))
            gesture.minimumPressDuration = 0.02
            imageView.addGestureRecognizer(gesture)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func setupNavigationButton() {
        let leftBarButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelBarButtonTapped(_:)))
        let rightBarButton = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveBarButtonTapped(_:)))
        self.navigationItem.leftBarButtonItem = leftBarButton
        self.navigationItem.rightBarButtonItem = rightBarButton
    }
    
    private func clearNavigationButton() {
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.hidesBackButton = true
        self.navigationItem.rightBarButtonItem = nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    fileprivate func getFilterAtIndex(_ index: Int) -> MTFilter {
        if let filter = cachedFilters[index] {
            return filter
        }
        let filter = allFilters[index].init()
        cachedFilters[index] = filter
        return filter
    }
    
    @objc func showUnEditPhotoGesture(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .cancelled, .ended:
            let filter = getFilterAtIndex(currentSelectFilterIndex)
            filter.inputImage = originInputImage
            imageView.image = filter.outputImage
            break
        default:
            let filter = getFilterAtIndex(0)
            filter.inputImage = originInputImage
            imageView.image = filter.outputImage
             break
        }
    }
    
    @objc func cancelBarButtonTapped(_ sender: Any) {
        navigationController?.popViewController(animated: false)
    }
    
    @objc func saveBarButtonTapped(_ sender: Any) {
        guard let image = self.imageView.image,
            let uiImage = MTFilterManager.shared.generate(image: image) else {
            return
        }
        PHPhotoLibrary.shared().performChanges({
            let _ = PHAssetCreationRequest.creationRequestForAsset(from: uiImage)
        }) { (success, error) in
            DispatchQueue.main.async {
                let alert = UIAlertController(title: nil, message: "Picture saved Successfully", preferredStyle: .alert)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    self.dismiss(animated: true, completion: nil)
                })
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    fileprivate func setupFilterCollectionView() {
    
        let frame =   CGRect(x: 0, y:  imageView.frame.size.height, width: self.view.frame.size.width , height: self.view.frame.size.height - imageView.frame.size.height)
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = .zero
        layout.itemSize = CGSize(width: 104, height: frame.height)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        
        filterCollectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        filterCollectionView.backgroundColor = .clear
        filterCollectionView.showsHorizontalScrollIndicator = false
        filterCollectionView.showsVerticalScrollIndicator = false
        self.view.addSubview(filterCollectionView)
        filterCollectionView.dataSource = self
        filterCollectionView.delegate = self
        filterCollectionView.register(FilterPickerCell.self, forCellWithReuseIdentifier: NSStringFromClass(FilterPickerCell.self))
        filterCollectionView.reloadData()
    }
    
    
    fileprivate func generateFilterThumbnails() {
        DispatchQueue.global().async {
            
            let size = CGSize(width: 200, height: 200)
            UIGraphicsBeginImageContextWithOptions(size, false, 0)
            self.croppedImage.draw(in: CGRect(origin: .zero, size: size))
            let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            if let image = scaledImage {
                for filter in self.allFilters {
                    let image = MTFilterManager.shared.generateThumbnailsForImage(image, with: filter)
                    self.thumbnails[filter.name] = image
                    DispatchQueue.main.async {
                        self.filterCollectionView.reloadData()
                    }
                }
            }
        }
    }
}


extension PhotoEditorViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return allFilters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(FilterPickerCell.self), for: indexPath) as! FilterPickerCell
            let filter = allFilters[indexPath.item]
            cell.update(filter)
            cell.thumbnailImageView.image = thumbnails[filter.name]
            return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
                let filter = allFilters[indexPath.item].init()
                filter.inputImage = originInputImage
                imageView.image = filter.outputImage
                currentSelectFilterIndex = indexPath.item
    }
    
}
