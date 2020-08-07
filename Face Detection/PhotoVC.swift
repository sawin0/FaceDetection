//
//  LiveFeedViewController.swift
//  Face Detection
//
//  Created by Sabin RanaBhat on 8/3/20.
//  Copyright © 2020 Sabin Ranabhat. All rights reserved.
//



import AVFoundation
import UIKit
import Vision


class PhotoVC: UIViewController, AVCapturePhotoCaptureDelegate {
    
    private let captureSession = AVCaptureSession()
    private lazy var previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
    private let videoDataOutput = AVCaptureVideoDataOutput()
    private var faceLayers: [CAShapeLayer] = []
    private let photoOutput = AVCapturePhotoOutput()
    
    
    var circleCGPath: CGPath? = nil
    var processingImage = false
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
        captureSession.startRunning()
        
        // fixes Error: Thread 1: Exception: "*** -[AVCapturePhotoOutput capturePhotoWithSettings:delegate:] No active and enabled video connection"
        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
        }
        
        
        // custom circle
        let midX = self.view.bounds.midX
        let midY = self.view.bounds.midY

        let circlePath = UIBezierPath(arcCenter: CGPoint(x: midX,y: midY), radius: CGFloat(self.view.bounds.width / 2 ), startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true)
        
        circleCGPath = circlePath.cgPath
        
        print("circle path below")
        print(circlePath)
        print("end")

        let shapeLayerPath = CAShapeLayer()
        
        shapeLayerPath.path = circlePath.cgPath
        //change the fill color
        shapeLayerPath.fillColor = UIColor.clear.cgColor
        //you can change the stroke color
        shapeLayerPath.strokeColor = UIColor.white.cgColor
        //you can change the line width
        shapeLayerPath.lineWidth = 3

        // add the blue-circle layer to the shapeLayer ImageView
        view.layer.addSublayer(shapeLayerPath)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.previewLayer.frame = self.view.frame
    }
    
    private func setupCamera() {
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .front)
        if let device = deviceDiscoverySession.devices.first {
            if let deviceInput = try? AVCaptureDeviceInput(device: device) {
                if captureSession.canAddInput(deviceInput) {
                    captureSession.addInput(deviceInput)
                    
                    setupPreview()
                }
            }
        }
    }
    
    private func setupPreview() {
        
        self.previewLayer.videoGravity = .resizeAspectFill
        self.view.layer.addSublayer(self.previewLayer)
        self.previewLayer.frame = self.view.frame
        
        self.videoDataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString) : NSNumber(value: kCVPixelFormatType_32BGRA)] as [String : Any]

        self.videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "camera queue"))
        self.captureSession.addOutput(self.videoDataOutput)
        
        let videoConnection = self.videoDataOutput.connection(with: .video)
        videoConnection?.videoOrientation = .portrait
    }
}

extension PhotoVC: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
          return
        }

        let faceDetectionRequest = VNDetectFaceLandmarksRequest(completionHandler: { (request: VNRequest, error: Error?) in
            DispatchQueue.main.async {
                self.faceLayers.forEach({ drawing in drawing.removeFromSuperlayer() })

                if let observations = request.results as? [VNFaceObservation] {
                    self.handleFaceDetectionObservations(observations: observations)
                }
            }
        })

        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: imageBuffer, orientation: .leftMirrored, options: [:])

        do {
            try imageRequestHandler.perform([faceDetectionRequest])
        } catch {
          print(error.localizedDescription)
        }
    }
    
    private func handleFaceDetectionObservations(observations: [VNFaceObservation]) {
        if !processingImage {
            for observation in observations {
                let faceRectConverted = self.previewLayer.layerRectConverted(fromMetadataOutputRect: observation.boundingBox)
                let faceRectanglePath = CGPath(rect: faceRectConverted, transform: nil)
                
                let circleBox = circleCGPath!.boundingBox
                let faceBox = faceRectanglePath.boundingBox
                
                let faceArea = faceBox.size.width * faceBox.size.height
                if(circleBox.contains(faceBox) && faceArea > 50000){
                    print("face is inside the circle")
                    self.processingImage = true
                    if captureSession.isRunning {
                        let settings = AVCapturePhotoSettings()
                        self.photoOutput.capturePhoto(with: settings, delegate: self)
                    }
                    
                }else{
                    print("face is outside the circle")
                }
                
                
                let faceLayer = CAShapeLayer()
                faceLayer.path = faceRectanglePath
                faceLayer.fillColor = UIColor.clear.cgColor
                faceLayer.strokeColor = UIColor.red.cgColor
                
                self.faceLayers.append(faceLayer)
                self.view.layer.addSublayer(faceLayer)
            }
        }
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation() else { return }
        let previewImage = UIImage(data: imageData)
        self.processingImage = true
        
        print("start")
        print(previewImage!.toBase64UrlSafe() ?? "default")
        print("end")
        
    }
}
