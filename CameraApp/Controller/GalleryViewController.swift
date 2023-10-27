//
//  GalleryViewController.swift
//  CameraApp
//
//  Created by Abhishek-Sreejith on 21/09/23.
//

import UIKit
import Photos

class GalleryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    
    
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    var imageAssets: [PHAsset] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(UINib(nibName: "ImageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ImageCell")
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadImages()
    }
    
    func loadImages(){
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        imageAssets.removeAll()
        
        fetchResult.enumerateObjects { asset, _, _ in
            self.imageAssets.append(asset)
        }
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageAssets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCollectionViewCell
        let asset = imageAssets[indexPath.item]
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isSynchronous = true
        PHImageManager.default().requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFill , options: nil) { image, _ in
            cell.imageView.image = image
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        guard let photoVC = storyBoard.instantiateViewController(withIdentifier: "PhotoViewController") as? PhotoViewController
        else {
            return
        }
        photoVC.imageAsset = imageAssets[indexPath.row]
        self.navigationController?.pushViewController(photoVC, animated: true)
    }
}


