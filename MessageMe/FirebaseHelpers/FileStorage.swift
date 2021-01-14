//
//  FileStorage.swift
//  MessageMe
//
//  Created by PuNeet on 24/12/20.
//  Copyright © 2020 dreamsteps. All rights reserved.
//

import Foundation
import FirebaseStorage
import ProgressHUD

let storage = Storage.storage()
public let kFILEREFERENCE = "gs://messageme-94c7a.appspot.com"
class FileStorage{
    
    //MARK: Images
    class func uploadImage(_ image: UIImage, directory: String, completion: @escaping(_ docLink: String?) -> Void){
        
        let storageRef = storage.reference(forURL: kFILEREFERENCE).child(directory)
        let imageData = image.jpegData(compressionQuality: 0.6)
        
        var task: StorageUploadTask!
        task = storageRef.putData(imageData!, metadata: nil, completion: { (metaData, error) in
            task.removeAllObservers()
            ProgressHUD.dismiss()
            
            if error != nil{
                print("Error uploading image \(error!.localizedDescription)")
                return
            }
            storageRef.downloadURL { (url, error) in
                guard let  downloadUrl = url else{
                    completion(nil)
                    return
                }
                completion(downloadUrl.absoluteString)
            }
        })
        
        task.observe(StorageTaskStatus.progress) { (snapshot) in
            let progress = snapshot.progress!.completedUnitCount / snapshot.progress!.totalUnitCount
            ProgressHUD.showProgress(CGFloat(progress))
        }
    }
    
    
    //MARK: Video
    
    
    class func uploadVideo(_ video: NSData, directory: String, completion: @escaping(_ videoLink: String?) -> Void){
        
        let storageRef = storage.reference(forURL: kFILEREFERENCE).child(directory)
        
        var task: StorageUploadTask!
        task = storageRef.putData(video as Data, metadata: nil, completion: { (metaData, error) in
            task.removeAllObservers()
            ProgressHUD.dismiss()
            
            if error != nil{
                print("Error uploading video \(error!.localizedDescription)")
                return
            }
            storageRef.downloadURL { (url, error) in
                guard let  downloadUrl = url else{
                    completion(nil)
                    return
                }
                completion(downloadUrl.absoluteString)
            }
        })
        
        task.observe(StorageTaskStatus.progress) { (snapshot) in
            let progress = snapshot.progress!.completedUnitCount / snapshot.progress!.totalUnitCount
            ProgressHUD.showProgress(CGFloat(progress))
        }
    }
    
    
    
    class func downloadVideo(_ videoLink: String, completion: @escaping (_  isReadyToPlay: Bool,_ videoFileName: String)-> Void){
        //     print("URL is \(imageUrl)")
        //        print(fileNameFrom(fileUrl: imageUrl))
        
        let videoUrl = URL(string: videoLink)
        
        let videoFileName = fileNameFrom(fileUrl: videoLink) + ".mov"
        
        if fileExistingAtPath(path: videoFileName){
            completion(true, videoFileName)
        }else{
            // Download from firebse
            
            let downloadQueue = DispatchQueue(label: "VideoDownloadQueue")
            downloadQueue.async {
                let data = NSData(contentsOf: videoUrl!)
                
                if data != nil{
                    //Save locally
                    
                    FileStorage.saveFileLocally(fileData: data!, fileName: videoFileName)
                    DispatchQueue.main.async {
                        completion(true, videoFileName)
                    }
                }else{
                    print("No document in tha database")
                }
            }
        }
    }
    
    
    //MARK: Save locally
    class func saveFileLocally(fileData: NSData, fileName: String){
        
        let docUrl = getDocumentsUrl().appendingPathComponent(fileName, isDirectory: false)
        fileData.write(to: docUrl, atomically: true )
    }
    
    class func downloadImage(_ imageUrl: String, completion: @escaping (_  image: UIImage?)-> Void){
        //     print("URL is \(imageUrl)")
        //        print(fileNameFrom(fileUrl: imageUrl))
        let imageFileName = fileNameFrom(fileUrl: imageUrl)
        if fileExistingAtPath(path: imageFileName){
            print("Have local image")
            if let contentsOfFile = UIImage(contentsOfFile: fileInDocumentDirectory(fileName: imageFileName)){
                completion(contentsOfFile)
            }else{
                print("Coulf not conver local image")
                completion(UIImage(named: "avatar"))
            }
        }else{
            // Download from firebse
            print("lets get from FB")
            
            if imageUrl != "" {
                let documentUrl = URL(string: imageUrl)
                
                let downloadQueue = DispatchQueue(label: "imageDownloadQueue")
                downloadQueue.async {
                    let data = NSData(contentsOf: documentUrl!)
                    
                    if data != nil{
                        //Save locally
                        
                        FileStorage.saveFileLocally(fileData: data!, fileName: imageFileName)
                        DispatchQueue.main.async {
                            completion(UIImage(data: data! as Data))
                        }
                    }else{
                        print("No document in tha database")
                        DispatchQueue.main.async {
                            completion(nil)
                        }
                    }
                }
            }
        }
    }
}


//MARK: Heplers

func fileInDocumentDirectory(fileName: String) -> String{
    return getDocumentsUrl().appendingPathComponent(fileName).path
}
func getDocumentsUrl() ->URL{
    return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
}
func fileExistingAtPath(path: String) -> Bool{
    return FileManager.default.fileExists(atPath: fileInDocumentDirectory(fileName: path))
}
