//
//  SARuleTableViewController.swift
//  sendadv
//
//  Created by 영준 이 on 2017. 1. 28..
//  Copyright © 2017년 leesam. All rights reserved.
//

import UIKit

class SARuleTableViewController: UITableViewController {

    var rule : SARecipientsRule?;
    lazy var dataController = SAModelController.Default;
    class TransactionNames{
        static let Rule = "Rule";
        static let Filter = "Filter";
    }
    
    class TargetNames{
        static let Job = "job";
        static let Department = "dept";
        static let Organization = "org";
    }
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var jobListLabel: UILabel!
    @IBOutlet weak var deptListLabel: UILabel!
    @IBOutlet weak var orgListLabel: UILabel!
    
    var editingTarget = "";
    
    override func viewWillAppear(_ animated: Bool) {
        //        SAModelController.Default.refresh(rule: self.rule!);
        if self.originalTitle != nil{
            self.navigationItem.title = self.originalTitle;
        }
        
        self.title = self.navigationItem.title;
        
        self.updateLabel(target: self.editingTarget);
        
        self.dataController.beginTransaction(transactionName: TransactionNames.Rule);
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.titleTextField.text = self.rule?.title;
        
        if self.rule == nil{
            self.rule = self.dataController.createRecipientsRule(title: "");
        }
        
        self.updateLabel(target: TargetNames.Job);
        self.updateLabel(target: TargetNames.Department);
        self.updateLabel(target: TargetNames.Organization);

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    var originalTitle : String?;

    
    override func viewWillDisappear(_ animated: Bool) {
        self.dataController.endTransaction();
        
        guard self.isMovingFromParentViewController else{
            return;
        }
        
        if needToSave{
            self.dataController.saveChanges();
        }else{
            self.dataController.rollback();
        }
    }
    
    func updateLabel(target : String){
        guard !target.isEmpty else{
            return;
        }
        
        let filter = (self.rule?.filters?.allObjects as? [SAFilterRule])?.first(where: { (f) -> Bool in
            return f.target == target;
        });
        var list = filter?.includes?.components(separatedBy: ",").filter({ (f) -> Bool in
            return !f.isEmpty;
        }) ?? [];
        var text = "";
        if list.count > 0{
            text = list[0];
        }
        
        if list.count > 1{
            text = text + "".appendingFormat(" and %@ others".localized(), "\(list.count - 1)");
        }
        
        if filter == nil || filter?.all == true{
            text = "All".localized();
        }
        
        switch target {
            case TargetNames.Job:
                self.jobListLabel.text = text;
                break;
            case TargetNames.Department:
                self.deptListLabel.text = text;
                break;
            case TargetNames.Organization:
                self.orgListLabel.text = text;
                break;
            default:
                break;
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onCancel(_ button: UIBarButtonItem) {
        self.titleTextField.resignFirstResponder();
        self.navigationController?.popViewController(animated: true);
    }
    
    var needToSave = false;
    @IBAction func onSave(_ button: UIBarButtonItem) {
        self.applyChange();
        self.needToSave = true;
        self.titleTextField.resignFirstResponder();
        self.navigationController?.popViewController(animated: true);
    }
    
    func applyChange(){
        if self.rule?.title != self.titleTextField.text{
            self.rule?.title = self.titleTextField.text;
        }
    }
    

    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }

//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        return 0
//    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let view = segue.destination as? SAFilterTableViewController{
//            self.dataController.beginTransaction(transactionName: TransactionNames.Filter);
//            self.dataController.endTransaction();

            switch segue.identifier ?? ""{
                case TargetNames.Job:
                    view.list = SAContactController.Default.loadJobTitles();
                    view.navigationItem.title = "\("Job".localized()) \("Rule Setting".localized())";
                    break;
                case TargetNames.Department:
                    view.list = SAContactController.Default.loadDepartments();
                    view.navigationItem.title = "\("Department".localized()) \("Rule Setting".localized())";
                    break;
                case TargetNames.Organization:
                    view.list = SAContactController.Default.loadOrganizations();
                    view.navigationItem.title = "\("Orgization".localized()) \("Rule Setting".localized())";
                    break;
                default:
                    break;
            }
            
            editingTarget = segue.identifier ?? "";
            
            view.rule = self.rule;
            view.target = segue.identifier ?? "";
            
            self.originalTitle = self.navigationItem.title;
            self.navigationItem.title = nil;
            
            self.titleTextField.resignFirstResponder();
        }
    }
}
