//
//  PhotoViewController.swift
//  CameraApp
//
//  Created by Abhishek-Sreejith on 22/09/23.
//

import UIKit
import Photos
import CoreLocation


class PhotoViewController: UIViewController {

    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    @IBOutlet weak var imageView: UIImageView!
    var imageAsset: PHAsset!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        PHImageManager.default().requestImage(for: imageAsset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit , options: nil) { image, _ in
            self.imageView.image = image
        }
        
        
        if let location = imageAsset.location{
            
            
            latitudeLabel.text = "Latitude: \(String(format: "%.4f", location.coordinate.latitude))"
            longitudeLabel.text = "Longitude: \(String(format: "%.4f", location.coordinate.longitude))"
            displayLocationInfo(location: location)
        }
        else{
            latitudeLabel.text = "No Information Available"
            longitudeLabel.text = ""
            addressLabel.text = ""
        }
       
    }
    
    func displayLocationInfo(location: CLLocation)
    {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            
            print(placemarks!)
            if let e = error{
                print("Geocoding error: \(e.localizedDescription)")
                return
            }
            
            if let placemark = placemarks?.first{
                let address = "Address: \n\(placemark.subLocality!), \n\(placemark.locality ?? ""), \n\(placemark.subAdministrativeArea!),\n\(placemark.administrativeArea ?? " ")"
                print(address)
                self.addressLabel.text = "\(address)"
            }
        }
        
    }
    


}
