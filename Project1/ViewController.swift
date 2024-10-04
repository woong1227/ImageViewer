//
//  ViewController.swift
//  Project1
//
//  Created by Andy Park on 1/3/24.
//

import UIKit

class ViewController: UITableViewController {
    
    struct ImageData: Codable {
        let name: String
        var clickCount: Int
    }
    
    var pictures = [ImageData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "WOONG GALLERY"
        
        let fm = FileManager.default
        let path = Bundle.main.resourcePath!
        let items = try! fm.contentsOfDirectory(atPath: path)
        
        DispatchQueue.global().async {
            self.loadPictures(picturePaths: items)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func loadPictures(picturePaths: [String]) {
        for picturePath in picturePaths {
            if picturePath.hasPrefix("pic") {
                // this is a picture to load!
                let image = ImageData(name: picturePath, clickCount: 0)
                pictures.append(image)
            }
        }
        
        pictures.sort { $0.name < $1.name }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pictures.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Picture", for: indexPath)
        let imageData = pictures[indexPath.row]
        
        cell.textLabel?.text = imageData.name
        cell.detailTextLabel?.text = "Clicks: \(imageData.clickCount)"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var image = pictures[indexPath.row]
        image.clickCount += 1
        pictures[indexPath.row] = image
        
        saveData()
        
        let cell = tableView.cellForRow(at: indexPath)
        cell?.detailTextLabel?.text = "Clicks: \(image.clickCount)"
        
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
//        if let vc = storyboard?.instantiateViewController(withIdentifier: "Bad") as? DetailViewController {
            vc.selectedImage = image.name
            vc.title = "Picture \(indexPath.row + 1) of \(pictures.count)"
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func saveData() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(pictures)
            UserDefaults.standard.set(data, forKey: "ImageData")
        } catch {
            print("Error saving data: \(error.localizedDescription)")
        }
    }
}
