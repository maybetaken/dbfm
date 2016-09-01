//
//  ChannelController.swift
//  DBFM
//
//  Created by jiang on 16/5/16.
//  Copyright © 2016年 Jiang. All rights reserved.
//

import UIKit

protocol ChannelProtocol {
    func onChangeChannel(channel_id: String)
}

class ChannelController: UIViewController{
    
    @IBOutlet weak var tv: UITableView!
    var channelData:NSArray = NSArray()
    var delegate:ChannelProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int{
        return channelData.count
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell!{
        
        let cell = UITableViewCell(style : UITableViewCellStyle.Subtitle, reuseIdentifier:"channel")
        let rowData:NSDictionary = self.channelData[indexPath.row] as! NSDictionary
        
        cell.textLabel!.text = rowData["name"] as?String
      //  cell.textLabel!.text = "name:\(indexPath.row)"
      // cell.detailTextLabel?.text = "detail:\(indexPath.row)"
        return cell
    }
    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath :NSIndexPath!){
       // print("选择了第\(indexPath.row)行")
        let rowData:NSDictionary = self.channelData[indexPath.row] as! NSDictionary
        let channel_id:AnyObject? = rowData["channel_id"]
        let channel:String = "channel=\(channel_id!)"
        delegate?.onChangeChannel(channel)
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    
    func tableView(tableView:UITableView!, willDisplayCell cell: UITableView!, forRowAAtIndexPath indexPath: NSIndexPath){
        cell.layer.transform = CATransform3DMakeScale(0.1, 0.1, 1)
        UIView.animateWithDuration(0.25, animations: {cell.layer.transform = CATransform3DMakeScale(1, 1, 1)})
    }
    
}
