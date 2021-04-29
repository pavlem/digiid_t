//
//  CatalogCell.swift
//  DigiIdentity_test
//
//  Created by Pavle Mijatovic on 1.5.21..
//

import UIKit

class CatalogCell: UICollectionViewCell {
    
    // MARK: - API
    
    var vm: CatalogCellVM? {
        willSet {
            updateUI(vm: newValue)
        }
    }
    
    static let id = "CatalogCellID"

    // MARK: - Properties
    @IBOutlet weak var catalogNameLbl: UILabel!
    @IBOutlet weak var catalogConfidenceLbl: UILabel!
    @IBOutlet weak var catalogIdLbl: UILabel!
    @IBOutlet weak var catalogImgView: CatalogCellImgView!
    
    // MARK: - Private
    private func updateUI(vm: CatalogCellVM?) {
        guard let vm = vm else { return }
        
        catalogNameLbl.text = vm.detailedName
        catalogConfidenceLbl.text = vm.confidence
        catalogIdLbl.text = vm.id
        catalogImgView.image = vm.image
        
        contentView.backgroundColor = vm.backgroundColor
        
        catalogNameLbl.font = vm.nameLblFont
        catalogConfidenceLbl.font = vm.confidenceLblFont
        catalogIdLbl.font = vm.idLblFont

        catalogNameLbl.textColor = vm.nameLblColor
        catalogConfidenceLbl.textColor = vm.confidenceLblColor
        catalogIdLbl.textColor = vm.idLblColor
    }
}
