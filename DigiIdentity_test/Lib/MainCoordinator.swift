//
//  MainCoordinator.swift
//  DigiIdentity_test
//
//  Created by Pavle Mijatovic on 29.4.21..
//

import UIKit

class MainCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let vc = CatalogCVC.instantiate()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: false)
    }
    
    func openCatalog(vm: CatalogDetailVM) {
        let vc = CatalogDetailsVC.instantiate()
        vc.coordinator = self
        vc.vm = vm
        navigationController.pushViewController(vc, animated: true)
    }
    
    func closeCatalog() {
        navigationController.popViewController(animated: true)
    }
}

