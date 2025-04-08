//
//  UIHelper.swift
//  InvioCekirge25
//
//  Created by Mertcan Kırcı on 4.04.2025.
//

import UIKit

enum UIHelper {
    static func successHapticFeedback() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    static func calculateDistanceLabelText(distance: Double) -> String {
        var labelText = String()
        let isMeter = distance < 1000
        let kilometer = distance / 1000
        let formattedDistance = isMeter ? distance : kilometer ///turn distance to kilometers if it's larger than 1000
        let type = isMeter ? " metre" : " kilometre"
        labelText = String(format: "%.1f", formattedDistance) + type
        
        return labelText + " uzaklıkta"
    }
}
