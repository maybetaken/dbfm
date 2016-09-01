//
//  HttpController.swift
//  DBFM
//
//  Created by jiang on 16/5/16.
//  Copyright © 2016年 Jiang. All rights reserved.
//

import UIKit

protocol HttpProtocol {
    func didRecieveResults(results:NSDictionary)
}

class HttpController: NSObject {
    
    var delegate : HttpProtocol?


    func onSearch(url:String){
        let nsUrl : NSURL = NSURL (string: url)!
    
        let request : NSURLRequest = NSURLRequest(URL: nsUrl)
        
        NSURLConnection.sendAsynchronousRequest(request, queue:NSOperationQueue.mainQueue(), completionHandler: {(response : NSURLResponse?, data: NSData?, error: NSError?) -> Void in
            let jsonResult :NSDictionary = (try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers )) as! NSDictionary
                self.delegate?.didRecieveResults(jsonResult)
    })
    
    
    }

}