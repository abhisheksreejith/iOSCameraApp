//
//  ViewController.swift
//  CameraApp
//
//  Created by Abhishek-Sreejith on 21/09/23.
//

import UIKit
import AVFoundation
import CoreLocation
import Photos

class CameraViewController: UIViewController, AVCapturePhotoCaptureDelegate, CLLocationManagerDelegate{
    
    
   
    @IBOutlet weak var flashhButtonView: UIButton!
    @IBOutlet weak var captureButtonImage: UIImageView!
    
    @IBOutlet weak var photocaptureButtonImage: UIImageView!
    
    
    var previewLayer: AVCaptureVideoPreviewLayer!
    var locationManager: CLLocationManager!
    var currentLocation: CLLocation?
    
    var captureSession = AVCaptureSession()
    var currentCameraPosition: AVCaptureDevice.Position = .back
    var photoOutput: AVCapturePhotoOutput!
    
    
    @IBOutlet weak var CameraView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
       // navigationController?.setNavigationBarHidden(true, animated: false)
       
        
        
       
        setupLocationmanager()
        setupCamera()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    //MARK: - Setup Camera

    func setupCamera(){
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo

        guard let backCamera = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: backCamera)
        else{
            fatalError("Unable to access the camera.")
        }

        if captureSession.canAddInput(input){
            captureSession.addInput(input)
        }

        photoOutput = AVCapturePhotoOutput()
        if captureSession.canAddOutput(photoOutput){
            captureSession.addOutput(photoOutput)
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = CameraView.layer.bounds
        CameraView.layer.addSublayer(previewLayer)

        captureSession.startRunning()

    }
    
    @IBAction func cameraRotateButtonPressed(_ sender: Any) {
        
        captureSession.stopRunning()
        
        for input in captureSession.inputs {
            captureSession.removeInput(input)
        }
        
        if currentCameraPosition == .back{
            currentCameraPosition = .front
        } else {
            currentCameraPosition = .back
        }
        
        if let newCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: currentCameraPosition){
            do{
                let newInput = try AVCaptureDeviceInput(device: newCamera)
                if captureSession.canAddInput(newInput){
                    captureSession.addInput(newInput)
                }
            } catch{
                print("Error switching camera")
            }
        }
        
        captureSession.startRunning()
    }
    
    
    //MARK: - setup location manager
    func setupLocationmanager(){
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("got the location")
        if let location = locations.last {
            
            currentLocation = location
        }
        print(currentLocation)
        
    }
    //    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    //        if let location = locations.last {
    //            print(location)
    //            currentLocation = location
    //        }
    //    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    
    
    //MARK: - Photo capture
    
    
    @IBAction func shutterButtonPressed(_ sender: Any) {
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
        
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData)
        else{
            return
        }
        if let location = currentLocation {
            savePhotoWithLocationInfo(image: image, location: location)
        }else{
            savePhoto(image: image)
        }
        
    }
    
    func savePhotoWithLocationInfo(image: UIImage, location: CLLocation){
        
        PHPhotoLibrary.shared().performChanges {
            let request = PHAssetChangeRequest.creationRequestForAsset(from: image)
            request.location = location
        } completionHandler: { success, error in
            if success{
                print("Photo saved to gallery with location info ")
            }
            else{
                print("Error saving photo")
            }
        }
    }
    
    func savePhoto(image: UIImage){
        PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        } completionHandler: { success, error in
            if success{
                print("Photo saved to gallery  ")
            }
            else{
                print("Error saving photo")
            }
        }
        
    }
    

    
  
    @IBAction func flashButtonPressed(_ sender: Any) {
        if currentCameraPosition != .back{
            return
        }
        guard let device = AVCaptureDevice.default(for: AVMediaType.video) else { return }
            guard device.hasTorch else { return }

            do {
                try device.lockForConfiguration()

                if (device.torchMode == AVCaptureDevice.TorchMode.on) {
                    device.torchMode = AVCaptureDevice.TorchMode.off
                    
                } else {
                    do {
                        try device.setTorchModeOn(level: 1.0)
                    } catch {
                        print(error)
                    }
                }

                device.unlockForConfiguration()
            } catch {
                print(error)
            }
    }
    
}

