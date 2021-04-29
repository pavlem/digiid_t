//
//  CatalogCellImgView.swift
//  DigiIdentity_test
//
//  Created by Pavle Mijatovic on 1.5.21..
//

import UIKit

class CatalogCellImgView: UIImageView {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.cornerRadius = self.frame.size.width / 2
    }
}
