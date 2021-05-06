//
//  DigiIdentity_testTests.swift
//  DigiIdentity_testTests
//
//  Created by Pavle Mijatovic on 29.4.21..
//

import XCTest
@testable import DigiIdentity_test

class DigiIdentity_testTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testFetchCatalogVMFromJSONResponse() {
        let asyncExpectation = expectation(description: "Async block executed")

        DigiIdentity_testTests.fetchMOCCatalogs { (catalogs) in
            XCTAssert(catalogs.count == 10)
            asyncExpectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }
    
    //  CatalogCellVM
    func testInitCatalogCellVMWithCatalogResponse() {
        let catalogResponse1 = CatalogResponse(text: "23. jsnbq", confidence: 0.01, img: "", id: "5e4eb3b0e2793")
        let catalogCellVM1 = CatalogCellVM(catalogResponse: catalogResponse1)
        XCTAssert(catalogCellVM1.name == "23. jsnbq")
        XCTAssert(catalogCellVM1.confidence == "Confidence: 0.01")
        XCTAssert(catalogCellVM1.id == "5e4eb3b0e2793")
        XCTAssert(catalogCellVM1.detailedName == "Name: 23. jsnbq")
        
        let catalogResponse2 = CatalogResponse(text: "Donald duck", confidence: 0.4, img: "", id: "5e4eb3b0e2794")
        let catalogCellVM2 = CatalogCellVM(catalogResponse: catalogResponse2)
        XCTAssert(catalogCellVM2.name == "Donald duck")
        XCTAssert(catalogCellVM2.confidence == "Confidence: 0.4")
        XCTAssert(catalogCellVM2.id == "5e4eb3b0e2794")
        XCTAssert(catalogCellVM2.detailedName == "Name: Donald duck")
    }
    
    func testInitCatalogCellVMWithCatalog() {
        let catalog1 = Catalog(name: "Donald duck", confidence: "Confidence: 0.4", id: "5e4eb3b0e2794", imageBase64: sampleBase64Img)
        let catalogCellVM1 = CatalogCellVM(catalog: catalog1)
        
        XCTAssert(catalogCellVM1.name == "Donald duck")
        XCTAssert(catalogCellVM1.confidence == "Confidence: 0.4")
        XCTAssert(catalogCellVM1.id == "5e4eb3b0e2794")
        XCTAssert(catalogCellVM1.detailedName == "Name: Donald duck")
        XCTAssert(catalogCellVM1.image.size.width > 0)
        XCTAssert(catalogCellVM1.image.size.height > 0)
        
        let catalog2 = Catalog(name: "Mickey mouse", confidence: "Confidence: 0.7", id: "5e4eb3b0e2795", imageBase64: "1234")
        let catalogCellVM2 = CatalogCellVM(catalog: catalog2)

        XCTAssert(catalogCellVM2.name == "Mickey mouse")
        XCTAssert(catalogCellVM2.confidence == "Confidence: 0.7")
        XCTAssert(catalogCellVM2.id == "5e4eb3b0e2795")
        XCTAssert(catalogCellVM2.detailedName == "Name: Mickey mouse")
        XCTAssert(catalogCellVM2.image.size.width == 0)
        XCTAssert(catalogCellVM2.image.size.height == 0)
    }
    
    // CatalogDetailVM
    func testInitCatalogDetailVMWithCatalogCellVM() {
        let catalogCellVM1 = CatalogCellVM(name: "Mickey mouse", confidence: "Confidence: 0.7", id: "5e4eb3b0e2795", image: UIImage())
        let catalogDetailVM1 = CatalogDetailVM(catalogCellVM: catalogCellVM1)

        XCTAssert(catalogDetailVM1.name == "MICKEY MOUSE")
        XCTAssert(catalogDetailVM1.confidence == "Confidence: 0.7")
        XCTAssert(catalogDetailVM1.id == "5e4eb3b0e2795")
        XCTAssert(catalogDetailVM1.descriptionOfID == "ID: 5e4eb3b0e2795")
        XCTAssert(catalogDetailVM1.image.size.width == 0)
        XCTAssert(catalogDetailVM1.image.size.height == 0)
        
        let catalogCellVM2 = CatalogCellVM(name: "Donald duck", confidence: "Confidence: 0.9", id: "2e4eb3b0e2795", image: sampleImg)
        let catalogDetailVM2 = CatalogDetailVM(catalogCellVM: catalogCellVM2)
        
        XCTAssert(catalogDetailVM2.name == "DONALD DUCK")
        XCTAssert(catalogDetailVM2.confidence == "Confidence: 0.9")
        XCTAssert(catalogDetailVM2.id == "2e4eb3b0e2795")
        XCTAssert(catalogDetailVM2.descriptionOfID == "ID: 2e4eb3b0e2795")
        XCTAssert(catalogDetailVM2.image.size.width >= 0)
        XCTAssert(catalogDetailVM2.image.size.height >= 0)
    }
    
    // MARK: - Helper
    static func fetchMOCCatalogs(delay: Int = 0, completion: @escaping ([CatalogCellVM]) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(delay)) {
            let filePath = "catalogsMOC"
            loadJsonDataFromFile(filePath, completion: { data in
                if let json = data {
                    do {
                        let catalogsResponse = try JSONDecoder().decode([CatalogResponse].self, from: json)
                        let catalogs = catalogsResponse.map { CatalogCellVM(catalogResponse: $0) }
                        completion(catalogs)
                    } catch _ as NSError {
                        fatalError("Couldn't load data from \(filePath)")
                    }
                }
            })
        }
    }

    static func loadJsonDataFromFile(_ path: String, completion: (Data?) -> Void) {
        if let fileUrl = Bundle.main.url(forResource: path, withExtension: "json") {
            do {
                let data = try Data(contentsOf: fileUrl, options: [])
                completion(data as Data)
            } catch {
                completion(nil)
            }
        }
    }
    
    private let sampleBase64Img = "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Q7CAGIIFxBAsIIZgATEEC4ghWEAMwQJiCBYQQ7CAGIIFxBAsIIZgATEEC4ghWEAMwQJiCBYQQ7CAGIIFxBAsIIZgATEEC4ghWEAMwQJiCBYQQ7CAGIIFxBAsIIZgATEEC4ghWEAMwQJiCBYQQ7CAGIIFxBAsIIZgATEEC4ghWEAMwQJiCBYQQ7CAGIIFxBAsIIZgATEEC4ghWEAMwQJiCBYQQ7CAGIIFxBAsIIZgATEEC4ghWEAMwQJiCBYQQ7CAGIIFxBAsIIZgATEEC4ghWEAMwQJiCBYQQ7CAGIIFxBAsIIZgATEEC4ghWEAMwQJiCBYQQ7CAGIIFxBAsIIZgATEEC4ghWEAMwQJiCBYQQ7CAGIIFxBAsIIZgATEEC4ghWEAMwQJiCBYQQ7CAGIIFxBAsIIZgATEEC4ghWEAMwQJiCBYQQ7CAGIIFxBAsIIZgATEEC4ghWEAMwQJiCBYQQ7CAGIIFxBAsIIZgATEEC4ghWEAMwQJiCBYQQ7CAGIIFxBAsIIZgATEEC4ghWEAMwQJiCBYQQ7CAGIIFxBAsIIZgATEEC4ghWEAMwQJiCBYQQ7CAGIIFxBAsIIZgATEEC4ghWEAMwQJiCBYQQ7CAGIIFxBAsIIZgATEEC4ghWEAMwQJiCBYQQ7CAGIIFxBAsIIZgATEEC4ghWEAMwQJiCBYQQ7CAGIIFxBAsIIZgATEEC4ghWEAMwQJiCBYQQ7CAGIIFxBAsIIZgATEEC4ghWECMfwDQlW1BNJcVMAAAAABJRU5ErkJggg=="
    
    private var sampleImg: UIImage {
        let dataDecoded = Data(base64Encoded: sampleBase64Img, options: .ignoreUnknownCharacters)!
        let decodedimage = UIImage(data: dataDecoded)!
        return decodedimage
    }
}
