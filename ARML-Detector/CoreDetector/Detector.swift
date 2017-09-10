//
//  Detector.swift
//  ARML-Detector
//
//  Created by Rafael on 08/09/17.
//  Copyright © 2017 Rafael Colatusso. All rights reserved.
//

import UIKit
import CoreML
import Vision

class Detector {
    var model: VNCoreMLModel?
    
    func setupModel() {
        guard let m = try? VNCoreMLModel(for: MobileNet().model) else {
            fatalError("error")
        }
        
        model = m
    }
    
    func detect(viewImage: UIView, result:@escaping (_ label: String) -> ()) {
        let image = UIImage(view: viewImage)
        let ciImage = CIImage(image: image)
        let imageHandler = VNImageRequestHandler(ciImage: ciImage!)
        
        let request = VNCoreMLRequest(model: model!) { request, error in
            guard let results = request.results as? [VNClassificationObservation],
                let firstResult = results.first else {
                    fatalError("error")
            }
            
            let confidence = String(format: "%.2f", firstResult.confidence * 100)            
            result("\(firstResult.identifier.split(separator: ",")[0]) - \(confidence)%")
        }
        
        DispatchQueue.global(qos: .userInteractive).async {
            do {
                try imageHandler.perform([request])
            } catch {
                print(error)
            }
        }
        
    }
}

extension UIImage{
    convenience init(view: UIView) {
        
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.isOpaque, 0.0)
        view.drawHierarchy(in: view.bounds, afterScreenUpdates: false)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(cgImage: (image?.cgImage)!)
        
    }
}
