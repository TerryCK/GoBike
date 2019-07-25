//
//  MKUserTrackingMode+Extension.swift
//  SupplyMap
//
//  Created by Terry Chen on 2019/7/17.
//  Copyright © 2019 Yi Shiung Liu. All rights reserved.
//

import MapKit

extension MKUserTrackingMode: CustomStringConvertible {
    public var description: String {
        switch self {
        case .none              : return "none"
        case .follow            : return "follow"
        case .followWithHeading : return "followWithHeading"
        @unknown default        : return ""
        }
    }
    
    var arrowImage: UIImage {
        return UIImage(named: String(describing: self) + "Arrow")!
    }
    
    var nextMode: MKUserTrackingMode {
        return MKUserTrackingMode(rawValue: (rawValue + 1) % 3)!
    }
}

extension MKMapPoint {
    var centerOfScreen: MKMapPoint {
        let factorOfPixelToMapPoint = 12000.0 / 320
        let offsetCenterX  = Double(UIScreen.main.bounds.width / 2) * factorOfPixelToMapPoint
        let offsetCenterY  = Double(UIScreen.main.bounds.height / 2) * factorOfPixelToMapPoint
        return MKMapPoint(x: x - offsetCenterX, y: y - offsetCenterY)
    }
}

extension MKMapView {
    func annotationView<T: MKAnnotationView>(of type: T.Type, annotation: MKAnnotation?, reuseIdentifier: String) -> T {
        guard let annotationView = dequeueReusableAnnotationView(withIdentifier: reuseIdentifier) as? T else {
            return type.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        }
        annotationView.annotation = annotation
        return annotationView
    }
}

extension UINib {
    static func instantiate<T: UIView>(view: T.Type, bundle: Bundle = .main) -> T {
        let nib = UINib(nibName: String(describing: view.self), bundle: bundle)
        return nib.instantiate(withOwner: view.init(), options: nil).first as! T
    }
}
