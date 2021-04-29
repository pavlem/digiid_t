//
//  AlertHelper.swift
//  DigiIdentity_test
//
//  Created by Pavle Mijatovic on 29.4.21..
//

import UIKit

struct AlertHelper {
    static func simpleAlert(title: String? = nil, message: String? = nil, vc: UIViewController, success: @escaping () -> Void) {
        
        DispatchQueue.main.async {
            let alertController = UIAlertController(
                title: title,
                message: message,
                preferredStyle: .alert
            )
            let okAction = UIAlertAction(title: "OK", style: .default, handler: { (_) in
                success()
            })
            
            alertController.addAction(okAction)
            vc.present(alertController, animated: true)
        }
    }
}
