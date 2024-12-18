
import UIKit

class InventoryListVC: BaseVC,UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var products: [RequestModel] = []
    var isSearching = false
    var filteredProducts: [RequestModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchBar()

        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        FireStoreManager.shared.getAllWarehouseProducts { [weak self] productsArray in
                guard let self = self else { return }
                if let productsArray = productsArray {
                    self.products = productsArray.sorted { $0.added_time > $1.added_time }
                    self.tableView.reloadData()
                }
            }
    }
    
    private func setupSearchBar() {
           searchBar.delegate = self
           searchBar.placeholder = "Search by product name, quantity, UPC no. or warehouse id"
           navigationItem.titleView = searchBar
       }


}


extension InventoryListVC {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearching ? filteredProducts.count : products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:  String(describing: TableViewCell.self), for: indexPath) as! TableViewCell
        let data = isSearching ? filteredProducts[indexPath.row] : products[indexPath.row]
        
        cell.productName.text = "Product Name: \(data.productname ?? "")"
        cell.quantity.text = "Quantity: \(data.quantity ?? "")"
        cell.userid.text = "Warehouse Id: \(data.warehouseID ?? "")"
        
        cell.acceptBtn.layer.borderColor = UIColor(hex: "183F62").cgColor
        cell.acceptBtn.layer.borderWidth = 1.0
        cell.acceptBtn.layer.cornerRadius = 10.0
        
        cell.acceptBtn.setTitle("UPC number: \(data.upcNumber ?? "")", for: .normal)
        cell.acceptBtn.tag = indexPath.row
        cell.acceptBtn.addTarget(self, action: #selector(openRaiseRequest(_:)), for: .touchUpInside)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 155
    }
    
    @objc func openRaiseRequest(_ sender: UIButton) {
        let data = isSearching ? filteredProducts[sender.tag] : products[sender.tag]

        let vc = self.storyboard?.instantiateViewController(withIdentifier:  "RequestVC" ) as! RequestVC
        vc.productData = data
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
   
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
           if searchText.isEmpty {
               isSearching = false
               filteredProducts = []
           } else {
               isSearching = true
               filteredProducts = products.filter { product in
                   return product.productname!.lowercased().contains(searchText.lowercased()) || product.quantity!.contains(searchText) || product.upcNumber!.contains(searchText) || product.warehouseID!.contains(searchText)
                   
               }
           }
           tableView.reloadData()
       }

       func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
           searchBar.text = ""
           isSearching = false
           filteredProducts = []
           tableView.reloadData()
           searchBar.resignFirstResponder()
       }

}



