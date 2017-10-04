//
// Copyright 2014-2015 Kirk C. Vogen
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import UIKit

class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController = DetailViewController()
    var listIds: [CInt] = []
    
    let detailService: DetailService

    required init?(coder decoder: NSCoder) {
        detailService = FlatFileDetailService(storageService: LocalStorageService())
        super.init(coder: decoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if UIDevice.current.userInterfaceIdiom == .pad {
            self.clearsSelectionOnViewWillAppear = false
            self.preferredContentSize = CGSize(width: 320.0, height: 600.0)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let view = self.tableView {
            view.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.leftBarButtonItem = self.editButtonItem

        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(MasterViewController.insertNewObject(_:)))
        self.navigationItem.rightBarButtonItem = addButton
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = ((controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController)!
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func insertNewObject(_ sender: AnyObject) {
        
        let list = detailService.create()
        
        let listId = list?.getId()
//        listIds += [listId] THIS SHOULDNT BE DISABLED
        
        _ = IndexPath(row: 0, section: 0)
        //self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let detailController = storyboard.instantiateViewController(withIdentifier: "detailView") as! DetailViewController
        detailController.listId = listId
        self.navigationController?.pushViewController(detailController, animated: false)
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            let indexPath = self.tableView.indexPathForSelectedRow
            let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
            let listId = listIds[indexPath!.row]
            
            controller.listId = listId
            controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
            controller.navigationItem.leftItemsSupplementBackButton = true
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
        
//        listIds.removeAll(keepingCapacity: true)
//        let lists = detailService.findAll()
//        let listSize = Int(lists!.size())
//
//
//        for list in lists {
//
//        }
//
//        for var i = 0; i < listSize; i += 1
//        {
//            let list = lists?.getWithInt(CInt(i)) as! DetailEntry
//            listIds += [list.getId()]
//        }
//
//        return listIds.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) 
        
        let listId = listIds[indexPath.row]
        _ = detailService.find(with: listId)
        
        let viewModel = DetailViewModel(detailService: detailService, with: " ")
        viewModel?.init__(with: listId)
        
        cell.textLabel?.text = viewModel?.getTitle()
        cell.detailTextLabel?.text = viewModel?.getWords()
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let listId = listIds[indexPath.row]
            detailService.delete__(with: listId)
            listIds.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }


}

