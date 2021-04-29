//
//  CatalogCVC.swift
//  DigiIdentity_test
//
//  Created by Pavle Mijatovic on 1.5.21..
//

import UIKit

class CatalogCVC: UICollectionViewController, Storyboarded {
    
    // MARK: - API
    weak var coordinator: MainCoordinator?
    
    // MARK: - Properties
    private var catalogs = [CatalogCellVM]()
    
    private var catalogVM = CatalogVM() {
        didSet {
            updateUI()
        }
    }
    
    // MARK: Life
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUI()
        
        catalogVM.loadPersistedCatalogs(forFirst: catalogVM.numberOfLoadedPersitedCatalogs) { loadedCatalogs in
            self.catalogs = loadedCatalogs
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        catalogVM = CatalogVM(isLoadingScreenShown: true)

        catalogVM.fetchCatalogs { [weak self] result in
            guard let `self` = self else { return }

            self.catalogVM = CatalogVM(isLoadingScreenShown: false)

            switch result {
            case .failure(let err):
                AlertHelper.simpleAlert(message: err.errorDescription, vc: self) {
                    self.catalogVM = CatalogVM(isLoadingScreenShown: false)
                }
            case .success(let catalogs):
                self.catalogs = catalogs
                self.reloadCollectionView()
                self.catalogVM.persist(catalogs: catalogs)
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        catalogVM.cancelCatalogsFetch()
    }
    
    // MARK: - Helper
    private func setUI() {
        title = catalogVM.catalogList
    }
    
    private func updateUI() {
        catalogVM.isLoadingScreenShown ? BlockingScreen.start(vc: self) : BlockingScreen.stop()
    }
    
    private func reloadCollectionView(catalogCount: (existing: Int, new: Int)? = nil) {
        guard let catalogCount = catalogCount else {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
            return
        }
        
        var indexPathsNew = [IndexPath]()
        for index in 0..<catalogCount.new {
            let indexPaths = IndexPath(item: catalogCount.existing + index, section: 0)
            indexPathsNew.append(indexPaths)
        }
        
        DispatchQueue.main.async {
            self.collectionView.insertItems(at: indexPathsNew)
        }
    }
}

// MARK: UICollectionViewDataSource
extension CatalogCVC {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return catalogs.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CatalogCell.id, for: indexPath) as? CatalogCell else { return UICollectionViewCell() }
        cell.vm = catalogs[indexPath.row]
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if isLastCell(collectionView, indexPath) {
            
            catalogVM = CatalogVM(isLoadingScreenShown: true)
            
            catalogVM.fetchCatalogs(maxId: catalogs[indexPath.row].id) { [weak self] result in
                guard let `self` = self else { return }
                
                switch result {
                
                case .failure(let err):
                    AlertHelper.simpleAlert(message: err.errorDescription, vc: self) {
                        self.catalogVM = CatalogVM(isLoadingScreenShown: false)
                    }
                case .success(let catalogs):
                    guard catalogs.count != 0 else {
                        AlertHelper.simpleAlert(message: self.catalogVM.noMoreCatalogsMessage, vc: self) {
                            self.catalogVM = CatalogVM(isLoadingScreenShown: false)
                        }
                        return
                    }
                    
                    self.catalogVM = CatalogVM(isLoadingScreenShown: false)
                    
                    let oldCount = self.catalogs.count
                    self.catalogs += catalogs
                    self.reloadCollectionView(catalogCount: (oldCount, catalogs.count))
                    self.catalogVM.persist(catalogs: self.catalogs)
                }
            }
        }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if isTopCell(scrollView) {
            
            catalogVM = CatalogVM(isLoadingScreenShown: true)
            
            guard let vmId = self.catalogs.first?.id else { return }
            catalogVM.fetchCatalogs(sinceId: vmId) { [weak self] result in
                guard let `self` = self else { return }
                
                switch result {
                
                case .failure(let err):
                    AlertHelper.simpleAlert(message: err.errorDescription, vc: self) {
                        self.catalogVM = CatalogVM(isLoadingScreenShown: false)
                    }
                    
                case .success(let mostRecentCatalogs):
                    guard mostRecentCatalogs.count != 0 else {
                        AlertHelper.simpleAlert(message: self.catalogVM.noNewCatalogsMessage, vc: self) {
                            self.catalogVM = CatalogVM(isLoadingScreenShown: false)
                        }
                        return
                    }
                    
                    self.catalogVM = CatalogVM(isLoadingScreenShown: false)
                    self.catalogs = mostRecentCatalogs + self.catalogs
                    self.reloadCollectionView(catalogCount: (0, mostRecentCatalogs.count))
                    self.catalogVM.persist(catalogs: self.catalogs)
                }
            }
        }
    }
    
    // MARK: - UICollectionViewDataSource Helper
    private func isLastCell(_ collectionView: UICollectionView, _ indexPath: IndexPath) -> Bool {
        return indexPath.row == collectionView.numberOfItems(inSection: indexPath.section) - 1
    }
    
    private func isTopCell(_ scrollView: UIScrollView) -> Bool {
        return scrollView.contentSize.height > 0 &&
            ((scrollView.contentOffset.y + scrollView.safeAreaInsets.top) == 0)
    }
}

// MARK: UICollectionViewDelegateFlowLayout
extension CatalogCVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let vm = catalogs[indexPath.row]
        return CGSize(width: collectionView.frame.width, height: vm.cellHeight)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        coordinator?.openCatalog(vm: CatalogDetailVM(catalogCellVM:catalogs[indexPath.row]))
    }
}
