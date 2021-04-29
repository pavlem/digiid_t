//
//  CatalogDetailsVC.swift
//  DigiIdentity_test
//
//  Created by Pavle Mijatovic on 5.5.21..
//

import UIKit

class CatalogDetailsVC: UIViewController, Storyboarded {
    
    // MARK: - API
    var vm: CatalogDetailVM? {
        didSet {
            updateUI()
        }
    }
    
    private func updateUI() {
        guard let vm = vm else { return }
        vm.isLoadingScreenShown ? BlockingScreen.start(vc: self) : BlockingScreen.stop()
    }
    
    weak var coordinator: MainCoordinator?

    // MARK: - Properties
    @IBOutlet weak var catalogConfidenceLbl: UILabel!
    @IBOutlet weak var catalogIdLbl: UILabel!
    @IBOutlet weak var catalogImgView: CatalogCellImgView!
    @IBOutlet weak var deleteBtn: UIButton!
    
    // MARK: - Actions
    @IBAction func deleteCatalogItem(_ sender: UIButton) {
                
        guard var newVM = vm else { return }
        newVM.isLoadingScreenShown = true
        vm = newVM

        vm?.deleteCatalog(id: newVM.id) { [weak self] result in
            guard let `self` = self else { return }

            switch result {
            case .failure(let err):
                AlertHelper.simpleAlert(message: err.errorDescription, vc: self) {
                    guard var newVM = self.vm else { return }
                    newVM.isLoadingScreenShown = false
                    self.vm = newVM
                }
            case .success(_):
                DispatchQueue.main.async {
                    self.coordinator?.closeCatalog()
                }
            }
        }
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setUI()
    }
    
    // MARK: - Helper
    private func setUI() {
        guard let vm = vm else { return }
        title = vm.name
        catalogConfidenceLbl.text = vm.confidence
        catalogIdLbl.text = vm.descriptionOfID
        catalogImgView.image = vm.image
        
        view.backgroundColor = vm.backgroundColor
        
        catalogConfidenceLbl.font = vm.confidenceLblFont
        catalogIdLbl.font = vm.idLblFont

        catalogConfidenceLbl.textColor = vm.confidenceLblColor
        catalogIdLbl.textColor = vm.idLblColor
        
        deleteBtn.setTitleColor(vm.btnTextColor, for: .normal)
        deleteBtn.backgroundColor = UIColor.white
        deleteBtn.layer.cornerRadius = deleteBtn.frame.size.height / 2
        
        deleteBtn.setTitle(vm.deleteBtnTitle, for: .normal)
        deleteBtn.titleLabel?.font = vm.deleteBtnFont
    }
}
