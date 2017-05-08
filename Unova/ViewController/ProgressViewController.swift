//
//  ProgressViewController.swift
//  Unova
//
//  Created by iosdev on 04/05/17.
//  Copyright © 2017 Unova. All rights reserved.
//

import UIKit

class ProgressViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource {

    //MARK: Properties
    @IBOutlet weak var coursePickerView: UIPickerView!
    @IBOutlet weak var percentageLabelView: UILabel!
    
    @IBOutlet weak var progressCollectionView: UICollectionView!
    
    var coursesOfStudent = [Course]()
    var selectedCourse: Course?
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    //MARK: View Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Progress"

        coursePickerView.delegate = self
        coursePickerView.dataSource = self
        
        //set up Progress collection View
        progressCollectionView.delegate = self
        progressCollectionView.dataSource = self
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        let width = UIScreen.main.bounds.width - 10
        layout.minimumInteritemSpacing = 0.5
        layout.scrollDirection = UICollectionViewScrollDirection.horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        layout.itemSize = CGSize(width: width / 6, height: CGFloat(80.0))
        
        progressCollectionView.collectionViewLayout = layout
        
        //Transform set of Course to Array
        guard let courseSet = appDelegate.user?.course as? Set<Course> else {
            fatalError("Downcast to Set of courses failed")
        }
        coursesOfStudent = Array(courseSet)
        
        if selectedCourse == nil {
            selectedCourse = coursesOfStudent[0]
        }
        updatePercentage(of: selectedCourse!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Picker View Data source and Delegate
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return coursesOfStudent.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return coursesOfStudent[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectedCourse = coursesOfStudent[row]
        
        updatePercentage(of: selectedCourse!)
        
        //update collection view
        progressCollectionView.reloadData()
    }
    
    //MARK: Collection View Data source and Delegate
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(selectedCourse!.lecture!.count)
        return selectedCourse!.lecture!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var lectures = [Lecture]()
        let cellIdentifier = "ProgressCollectionViewCell"
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier,
                                                            for: indexPath) as? ProgressCollectionViewCell else {
                                                                fatalError("Donwcast to Progress Collection Cell failed")
        }
        
        cell.backgroundColor = UIColor.init(red: 234.0/255.0, green: 234.0/255.0, blue: 234.0/255.0, alpha: 1.0)
        
        let lectureSet = selectedCourse?.lecture as! Set<Lecture>
        lectures += lectureSet
        
        //Sort the lecture by Date
        lectures.sort(by: {$0.date?.compare($1.date as! Date) == .orderedDescending})
        
        //fetch appropriate lecture in the list
        let lecture = lectures[indexPath.row]
        
        cell.dateLabelView.text = cropDateString(date: (lecture.date as! Date))
        if isPresent(of: lecture) {
            cell.markImageView.image = UIImage(named: "Present Mark")
        } else {
            cell.markImageView.image = UIImage(named: "Absent Mark")
        }
        
        return cell
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    //MARK: Private methods
    
    // Check if student is present during a lecture
    private func isPresent(of lecture: Lecture) -> Bool {
        
        guard let checkinTime = lecture.checkinTime as? [String: Any] else {
            fatalError("Fetch checkinTime failed")
        }
        
        if checkinTime[(appDelegate.user?.id)!] != nil {
            return true
        }
        return false
    }
    
    // Get attendance value
    private func numberOfPresence(of course: Course) -> Int {
        
        var numberOfPresence: Int = 0
        
        //Get set of Lectures
        let lecturesSet = course.lecture as! Set<Lecture>
        
        for lecture in lecturesSet {
            if isPresent(of: lecture) {
                numberOfPresence += 1
            }
        }
        return numberOfPresence
    }
    
    // Calculate attendance percentage
    private func updatePercentage(of course: Course) {
        
        let numberOfDecimalPlace: Double = 1
        
        let percentage = (Double(numberOfPresence(of: course)) / Double((course.lecture?.count)!)) * 100
        
        //Round to one Decimal place
        let roundedPercentage = Double(round(numberOfDecimalPlace * 10 * percentage) / (numberOfDecimalPlace * 10))
        
        //Set up the font size of text View
        percentageLabelView.font = percentageLabelView.font.withSize(50.0)
        percentageLabelView.text = String(roundedPercentage) + "%"
    }
    
    // Modify date string
    private func cropDateString(date: Date) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MMM/yyyy"
        
        let dateString = dateFormatter.string(from: date)
        
        //only date and month
        let index = dateString.index(dateString.startIndex, offsetBy: 6)
        
        return dateString.substring(to: index)
    }
}
