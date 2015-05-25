//
//  ImageGetter.swift
//  
//
//  Created by Wang Yu on 5/25/15.
//
//

import Foundation
import Alamofire
import SwiftyJSON

@objc protocol ImageGetterDelegate: class {
    optional func gotFlickrInterestingnessPhotoUrls(urlList: [String])
}

class ImageGetter: NSObject {
   
    struct apiInfo {
        let key = "1fcf2cd093b0b761335437cc367cf051"
        let secret = "596f14d5648dc4ad"
    }
    
    weak var delegate: ImageGetterDelegate?
    
    /*
    https://farm{farm-id}.staticflickr.com/{server-id}/{id}_{secret}.jpg
    https://farm{farm-id}.staticflickr.com/{server-id}/{id}_{secret}_[mstzb].jpg
    https://farm{farm-id}.staticflickr.com/{server-id}/{id}_{o-secret}_o.(jpg|gif|png)
    */
    func getFlickrInterestingnessPhotos() {
        let pageNum: Int = 50
        let url = "https://api.flickr.com/services/rest/?method=flickr.interestingness.getList&api_key=\(apiInfo().key)&per_page=\(pageNum)&format=json&nojsoncallback=1"
        var req = Alamofire.request(.GET, url).responseJSON { (_, response, JSON, error) in
            if error == nil && JSON != nil {
                let data = SwiftyJSON.JSON(JSON!)
                var urlList = [String]()
                for var i = 0; i < pageNum; i++ {
                    let secret = data["photos"]["photo"][i]["secret"]
                    let farmId = data["photos"]["photo"][i]["farm"]
                    let id = data["photos"]["photo"][i]["id"]
                    let serverId = data["photos"]["photo"][i]["server"]
                    let url = "https://farm\(farmId).staticflickr.com/\(serverId)/\(id)_\(secret).jpg"
                    urlList.append(url)
                }
                self.delegate?.gotFlickrInterestingnessPhotoUrls!(urlList)
            }
        }
    }
}
