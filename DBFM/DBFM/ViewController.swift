//
//  ViewController.swift
//  DBFM
//
//  Created by jiang on 16/5/16.
//  Copyright © 2016年 Jiang. All rights reserved.
//

import UIKit
import MediaPlayer

class ViewController: UIViewController, HttpProtocol,ChannelProtocol {
    
    
    @IBOutlet weak var iv: UIImageView!
    
    @IBOutlet weak var tv: UITableView!
    
    @IBOutlet weak var progressView: UIProgressView!
    
    @IBOutlet weak var playTime: UILabel!
    
    @IBOutlet var tap: UITapGestureRecognizer!
    @IBOutlet weak var btnPlay: UIImageView!
    
    var eHttp: HttpController = HttpController()
    var tableData: NSArray = NSArray()
    var channelData: NSArray = NSArray()
    var imageCache = Dictionary<String, UIImage>()
    var audioPlayer:MPMoviePlayerController = MPMoviePlayerController()
//,    var avPlayer: AVPlayer!
    var timer : NSTimer?
    
    @IBAction func onTap(sender: UITapGestureRecognizer) {
        if sender.view == btnPlay{
            btnPlay!.hidden = true
            audioPlayer.play()
            btnPlay!.removeGestureRecognizer(tap!)
            iv.addGestureRecognizer(tap!)
        }
        else if sender.view == iv {
            btnPlay!.hidden = false
            audioPlayer.pause()
            btnPlay.addGestureRecognizer(tap!)
            iv!.removeGestureRecognizer(tap!)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        iv!.addGestureRecognizer(tap!)
        eHttp.delegate = self
        eHttp.onSearch("https://douban.fm/j/mine/playlist?type=n&channel=10&from=mainsite")
        eHttp.onSearch("https://www.douban.com/j/app/radio/channels")
    }

    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) ->Int{
        print(tableData.count)
        return tableData.count
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!)-> UITableViewCell{
        let cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "douban")
        
        let rowData: NSDictionary = self.tableData[indexPath.row] as! NSDictionary
        
        cell.textLabel?.text = rowData["title"] as? String
        cell.detailTextLabel?.text = rowData["artist"] as? String
        
        let  url = rowData["picture"] as! String
        cell.imageView!.image = UIImage(named: "detail.jpg")
        let image = self.imageCache[url] as UIImage?
        
        if image == nil{
        let  imgURL: NSURL = NSURL(string: url)!
        let  request:NSURLRequest = NSURLRequest(URL: imgURL)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse?, data: NSData?, error: NSError?) -> Void in
            let img = UIImage(data: data!)
            cell.imageView?.image = img
            self.imageCache[url] = img
        })
        }else{
            cell.imageView?.image = image!
        }
        
        
        return cell
    }
    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        print("选择了第\(indexPath.row)行")

        let rowData: NSDictionary = self.tableData[indexPath.row] as! NSDictionary
        let imgUrl:String=rowData["picture"] as! String
        onSetImage(imgUrl)
        let audioUrl:String = rowData["url"] as! String
        onSetAudio(audioUrl)
    }


    
    func tableView(tableView:UITableView!, willDisplayCell cell: UITableView!, forRowAAtIndexPath indexPath: NSIndexPath){
        cell.layer.transform = CATransform3DMakeScale(0.1, 0.1, 1)
        UIView.animateWithDuration(0.25, animations: {cell.layer.transform = CATransform3DMakeScale(1, 1, 1)})
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        //跳转的目标对象为ChannelController类型
        let channelC:ChannelController=segue.destinationViewController as! ChannelController
        //设置跳转对象的代理
        channelC.delegate=self
        //为跳转对象填充频道列表数据
        channelC.channelData=self.channelData
    }
    
    func didRecieveResults(results: NSDictionary) {
        if(results["song"] != nil){
            self.tableData = results["song"] as! NSArray
            
            self.tv!.reloadData()
            
            let firDict: NSDictionary = self.tableData[0] as! NSDictionary
            var audioUrl:NSString = firDict["url"] as! NSString
          //  let length = audioUrl.characters.count
            
            
//            let audilURL = audioUrl.substringFromIndex(4)
//            audioUrl = "https"+audilURL
            
            onSetAudio(audioUrl as String)
            
            print("音乐地址:\(audioUrl)")
            
            let imgUrl:String = firDict["picture"] as! String
            print("图片地址:\(imgUrl)")
            
           onSetImage(imgUrl)
            
        }else if(results["channels"] != nil){
            self.channelData = results["channels"] as! NSArray
        }
    }
    
    
    func onSetImage(url: String){
        let image = self.imageCache[url] as UIImage?
        if image == nil{
        let imgURL: NSURL = NSURL(string: url)!
        let request: NSURLRequest = NSURLRequest(URL: imgURL)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: { (response: NSURLResponse?, data: NSData?, error: NSError?) in
            let img = UIImage(data: data!)
            self.iv!.image = img
            self.imageCache[url] = img
            
        })
        }else{
            self.iv!.image = image
        }
    }
    
    func onSetAudio(url: String){
        self.audioPlayer.pause()
        self.audioPlayer.contentURL = NSURL(string: url)
        self.audioPlayer.play()
        
        timer?.invalidate()
        playTime!.text = "00:00"
        timer = NSTimer.scheduledTimerWithTimeInterval(0.4, target: self,selector:#selector(ViewController.onUpdate), userInfo: nil ,repeats: true)
        btnPlay!.removeGestureRecognizer(tap!)
        iv!.addGestureRecognizer(tap!)
        btnPlay!.hidden = true
    }
    
    func onChangeChannel(channel: String) {
        let url: String = "https://douban.fm/j/mine/playlist?type=n&\(channel)&from=mainsite"
        eHttp.onSearch(url)
    }
    
    func onUpdate(){
        let c = audioPlayer.currentPlaybackTime
            if c>0.0{
                let t = audioPlayer.duration
                let p:CFloat = CFloat(c/t)
                progressView!.setProgress(p, animated: true)
                
                let all:Int = Int(c)
                let m:Int = all%60
                let f:Int = Int(all/60)
                
                var time:String = ""
                if f<10{
                    time = "0\(f)"
                }else{
                    time = "\(f)"
                }
                time += ":"
                if m<10{
                    time += "0\(m)"
                }else{
                    time += "\(m)"
                }
                playTime!.text = time
        }
    }
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

