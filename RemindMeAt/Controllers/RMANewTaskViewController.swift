//
//  NewTaskViewController.swift
//  addNewAndEditTask
//
//  Created by Ganna Melnyk on 2/8/18.
//  Copyright © 2018 Ganna Melnyk. All rights reserved.
//

import UIKit

class RMANewTaskViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let notificationManager = NotificationManager()
    var imageDoc = RMAFileManager()
    var taskToBeUpdated: RMATask?
    var currentTask: RMATask?
    var taskIdentifier = 0
    var imageURL: String?
    
    let allTagsResults = RMARealmManager.getAllTags()
    var tagList = Array<RMATag>()
    let defaultImage = #imageLiteral(resourceName: "defaultPic")
    
    let namePlaceholder = "put a name for the task here"
    let datePlaceholder = "tap to add the date"
    let locationPlaceholder = "tap to add a location"
    let descriptionPlaceholder = "put a task description here, if you wish :)"
    let tagsPlaceholder = "add tags"
    
    var picker = UIImagePickerController()
    let datePicker = UIDatePicker()
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var tagView: UIView!
    @IBOutlet weak var tagTableView: UITableView!
    @IBOutlet weak var tagViewSelectButton: UIButton!
    
    @IBOutlet weak var tagViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tagTableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomTagViewConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let taskToBeUpdated = taskToBeUpdated {
            for tag in taskToBeUpdated.tags {
                tagList.append(tag)
            }
            currentTask = taskToBeUpdated.clone()
            self.title = taskToBeUpdated.name
        } else {
            currentTask = RMATask()
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        tagTableView.delegate = self
        tagTableView.dataSource = self
        
        picker.delegate = self
        
        self.tabBarController?.tabBar.isHidden = true
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(image: #imageLiteral(resourceName: "back_small"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(testTest))
        self.navigationItem.leftBarButtonItem = newBackButton
        addDatePicker()
        
        tagTableView.layer.cornerRadius = 15
        tagView.layer.cornerRadius = 30
        tagViewSelectButton.layer.cornerRadius = 15
        tableView.rowHeight = UITableViewAutomaticDimension
        
        let rightBarButton = UIBarButtonItem(image: #imageLiteral(resourceName: "save_small"), style: .plain, target: self, action: #selector(self.navigationControllerButton))
        self.tableView.reloadData()
        updateConstraints()
        self.hideKeyboardWhenTappedAround()
        self.navigationItem.rightBarButtonItem = rightBarButton
    }
    
    func addNewTaskOrUpdateTaskInDB() {
        if let taskToBeUpdated = taskToBeUpdated {
            RMARealmManager.updateTask(taskToBeUpdated, withData: currentTask!)
            for tag in tagList {
                currentTask?.tags.append(tag)
            }
        } else {
            for tag in tagList {
                currentTask?.tags.append(tag)
            }
            RMARealmManager.addTask(newTask: currentTask!)
            notificationManager.setNotification(with: currentTask!)
        }
    }
    
    @IBAction func saveTagsButton(_ sender: UIButton) {
        bottomTagViewConstraint.constant = -tagViewHeightConstraint.constant
        UIView.animate(withDuration: 1) {
            self.view.layoutIfNeeded()
        }
        self.tableView.reloadData()
    }
    
    func updateConstraints() {
        tagTableView.rowHeight = 40
        tagTableViewHeightConstraint.constant = tagTableView.rowHeight * CGFloat(allTagsResults.count)
        tagViewHeightConstraint.constant = tagTableViewHeightConstraint.constant + 80
        self.tagTableView.layoutIfNeeded()
        bottomTagViewConstraint.constant = -tagViewHeightConstraint.constant
        self.tagView.layoutIfNeeded()
    }
    
    
    @objc func testTest(){
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    
    @objc func navigationControllerButton(rightBarButton: UIBarButtonItem) {
            rightBarButton.image = #imageLiteral(resourceName: "save_small")
            if taskIdentifier == 0 {
                if currentTask?.name == nil || (currentTask?.name.trimmingCharacters(in: .whitespaces).isEmpty)! || currentTask?.name.count == 0 {
                    let alertController = UIAlertController(title: "Empty name field", message: "give a name to the task", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "ok", style: .destructive, handler: nil)
                    alertController.addAction(okAction)
                    present(alertController, animated: false, completion: nil)
                } else {
                    addNewTaskOrUpdateTaskInDB()
                    self.navigationController?.popToRootViewController(animated: true)
                    self.tabBarController?.selectedIndex = 0
            }
        }
        UIView.transition(with: tableView,
                          duration: 1,
                          options: .transitionCrossDissolve,
                          animations:
            { () -> Void in
                self.tableView.reloadData()
        },
                          completion: nil);
        self.navigationItem.rightBarButtonItem = rightBarButton
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
        UIView.animate(withDuration: 1, animations: {
            self.datePicker.frame.origin.y = self.view.frame.height
            self.datePicker.layoutIfNeeded()
        })
    }
    
    func formatDate(date: NSDate) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy hh:mm a"
        return dateFormatter.string(from: date as Date)
    }
    
    func addDatePicker() {
        datePicker.frame = CGRect(x: 10, y: self.view.frame.height , width: self.view.frame.width - 20, height: 200)
        datePicker.timeZone = NSTimeZone.local
        datePicker.backgroundColor = .clear
        datePicker.addTarget(self, action: #selector(self.datePickerValueChanged(_:)), for: .valueChanged)
        self.view.addSubview(datePicker)
    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker){
        currentTask?.date = sender.date as NSDate
        tableView.reloadData()
    }
    
    func cameraGalery() {
        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let firstAction: UIAlertAction = UIAlertAction(title: "Camera", style: .default) { action -> Void in
            self.openCamera()
        }
        
        let secondAction: UIAlertAction = UIAlertAction(title: "Galery", style: .default) { action -> Void in
            self.openGallery()
        }
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in }
        actionSheetController.addAction(firstAction)
        actionSheetController.addAction(secondAction)
        actionSheetController.addAction(cancelAction)
        present(actionSheetController, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let newImage = info[UIImagePickerControllerOriginalImage] as? UIImage{
            let tempImage = newImage
            let imageDate = Date()
            imageDoc.addToUrl(tempImage, create: imageDate)
            currentTask?.imageURL = String(describing: imageDate)
            self.tableView.reloadData()
            picker.dismiss(animated: true, completion: nil)
        }
    }
    
    func openGallery() {
        picker.allowsEditing = false
        picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        present(picker, animated: true, completion: nil)
    }
    
    
    func openCamera() {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)){
            picker.allowsEditing = false
            picker.sourceType = UIImagePickerControllerSourceType.camera
            picker.cameraCaptureMode = .photo
            present(picker, animated: true, completion: nil)
        }else{
            let alert = UIAlertController(title: "Camera Not Found", message: "This device has no Camera", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style:.default, handler: nil)
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
        }
    }
    
    @objc func imgTapped(sender: UITapGestureRecognizer) {
        cameraGalery()
    }
}

extension RMANewTaskViewController: UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == self.tableView {
            switch indexPath.row {
            case 1:
                UIView.animate(withDuration: 1, animations: {
                    self.currentTask?.date = NSDate()
                    tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
                    self.datePicker.frame.origin.y = self.view.frame.height - 200
                    self.datePicker.layoutIfNeeded()
                })
            case 2:
                guard let mapsVC = storyboard?.instantiateViewController(withIdentifier: String(describing: RMAMapVC.self)) as? RMAMapVC else { return }
                mapsVC.locationDelegate = self
                mapsVC.navigationItem.title = "Add location"
                mapsVC.navigationItem.backBarButtonItem?.title = "Cancel"
                mapsVC.navigationController?.navigationItem.leftBarButtonItem?.title = "Cancel"
                mapsVC.isInAddLocationMode = true
                navigationController?.pushViewController(mapsVC, animated: true)
            case 4:
                bottomTagViewConstraint.constant = 0
                UIView.animate(withDuration: 1) {
                    self.view.layoutIfNeeded()
                }
            default:
               return
            }
        } else {
            let oneTag = allTagsResults[indexPath.row]
            if let index = tagList.index(where: {$0.isTagTheSame(oneTag)}) {
                tagList.remove(at: index)
            } else {
                tagList.append(oneTag)
            }
            tagTableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
        }
    }
}

extension RMANewTaskViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == self.tableView {
            return 5
        }
        if tableView == self.tagTableView {
            return allTagsResults.count
        }
        return 5
    }
    
    func addTags(cell: RMASingleTaskFieldsTVCell) {
        var i: CGFloat = 1
        for tag in tagList {
            cell.addSubview(drawSquare(frameWidth: tableView.frame.width, number: i, color: UIColor.fromHexString(tag.color)))
            i += 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.tableView {
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "nameCell") as! RMASingleTaskFieldsTVCell
                cell.cellParameters(labelName: "name: ", name: currentTask?.name, placeholder: namePlaceholder, isTextField: true)
                cell.putNameHere.delegate = self
                cell.putNameHere.tag = 1
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "nameCell") as! RMASingleTaskFieldsTVCell
                if let date = currentTask?.date {
                    let formattedDate = formatDate(date: date)
                    cell.cellParameters(labelName: "date: ", name: formattedDate, placeholder: datePlaceholder, isTextField: false)
                } else {
                    cell.cellParameters(labelName: "date: ", name: nil, placeholder: datePlaceholder, isTextField: false)
                }
                return cell
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "nameCell") as! RMASingleTaskFieldsTVCell
                cell.cellParameters(labelName: "location: ", name: currentTask?.location?.name, placeholder: locationPlaceholder, isTextField: false)
                return cell
            case 3:
                let cell = tableView.dequeueReusableCell(withIdentifier: "imageAndDescr") as! RMAImageAndDescrTVCell
                var image = defaultImage
                if let imageFromDB = currentTask?.imageURL {
                    image = imageDoc.loadImageFromPath(imageURL: imageFromDB)!
                }
                cell.cellParameters(name: currentTask?.fullDescription, placeholder: descriptionPlaceholder, image: image)
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imgTapped(sender:)))
                cell.pictureView.addGestureRecognizer(tapGesture)
                cell.descrTextView.delegate = self
                cell.descrTextView.tag = 2
                return cell
            case 4:
                let cell = tableView.dequeueReusableCell(withIdentifier: "nameCell") as! RMASingleTaskFieldsTVCell
                if tagList.count > 0 {
                    cell.cellParameters(labelName: "tags:", name: nil, placeholder: "", isTextField: false)
                } else {
                    cell.cellParameters(labelName: "tags:", name: nil, placeholder: tagsPlaceholder, isTextField: false)
                }
                cell.cleanCell()
                addTags(cell: cell)
                return cell
            default:
                fatalError("you missed some cells")
            }
        }  else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "oneTagCell") as! RMATagScreenTVCell
            let tagForCell = allTagsResults[indexPath.row]
            let color = UIColor.fromHexString(tagForCell.color)
            cell.cellParameters(name: tagForCell.name, tagColor: color)
            if tagList.contains(where: { $0.isTagTheSame(tagForCell) }) {
                cell.tagIsChoosePic.image = #imageLiteral(resourceName: "check")
            } else  {
                cell.tagIsChoosePic.image = #imageLiteral(resourceName: "uncheck")
            }
            return cell
        }
    }
    
    func drawSquare(frameWidth: CGFloat, number: CGFloat, color: UIColor) -> UIView {
        let size: CGFloat = 20
        let space: CGFloat = 5
        let square = UIView(frame: CGRect(x: frameWidth - (size * number) - (space * number), y: 12, width: size, height: size))
        square.backgroundColor = color
        square.layer.borderWidth = 1
        square.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        square.layer.cornerRadius = 10
        return square
    }
}

extension RMANewTaskViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        if textView.tag == 1 {
            textView.text = currentTask?.name
        } else if textView.tag == 2 {
            textView.text = currentTask?.fullDescription
            
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.tag == 1 {
            currentTask?.name = textView.text
        } else if textView.tag == 2 {
            currentTask?.fullDescription = textView.text
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if (currentTask?.name == nil || currentTask?.name.count == 0) && textView.tag == 1 {
            textView.text = namePlaceholder
            textView.textColor = UIColor.lightGray
        } else if (currentTask?.fullDescription == nil || currentTask?.fullDescription?.count == 0) && textView.tag == 2 {
            textView.text = descriptionPlaceholder
            textView.textColor = UIColor.lightGray
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        if textView.tag == 1 {
            return numberOfChars <= 25
        } else {
            return numberOfChars <= 200
        }
    }
}

extension RMANewTaskViewController: SetLocationDelegate {
    func setLocation(location: RMALocation) {
        var tempLoc = RMALocation()
        tempLoc = location
        currentTask?.location = tempLoc
        self.tableView.reloadData()
    }
}
