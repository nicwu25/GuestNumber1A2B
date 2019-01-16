//
//  GuestNumberViewController.swift
//  GuestNumber1A2B
//
//  Created by nicwu on 2018/9/24.
//  Copyright © 2018年 nicwu. All rights reserved.
//

import UIKit
import GameplayKit

class GuestNumberViewController: UIViewController {
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet var numbersButton: [UIButton]!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet var guestLabel: [UILabel]!
    @IBOutlet weak var guestTextView: UITextView!
    
    
    var timer = Timer()
    var timeCount = 0
    var guestCount = 0
    var randomNumber = [0, 0, 0, 0]
    var guestNumber = [Int]()
    var count = 0
    
    var records = [record]()
    //var records: record?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //設置計時器
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateTimer), userInfo: nil, repeats: true)
        //timeInterval->每間隔幾秒執行一次，self->執行的對象(通常設定為自己)，selector->執行哪一個func，userInfo->傳入nil即可，repeats->是否重複執行。
        
        //產生亂數題目
        let shuffledDistribution = GKShuffledDistribution(lowestValue: 0, highestValue: 9)
        for i in 0...3 {
            let index  = shuffledDistribution.nextInt()
            randomNumber[i] = index
            print(randomNumber[i], terminator: "")
        }
        print("")
        
        guestTextView.layer.cornerRadius = 8.0 //TextView圓角
        guestTextView.isEditable = false
    }
    
    @IBAction func pressGuestNumber(_ sender: UIButton) {
        guestCount += 1
        if guestCount == 4 {
            for i in 0...9 {
                numbersButton[i].alpha = 0.5
                numbersButton[i].isEnabled = false
            }
        }
        sender.alpha = 0.5
        sender.isEnabled = false
        
        guestLabel[guestCount-1].text = sender.currentTitle
        //guestLabel[guestCount-1].text = sender.titleLabel?.text
        guestNumber.append(Int(sender.currentTitle!)!)
        for i in 0..<guestNumber.count {
            print(guestNumber[i], terminator: "")
        }
        print("")
    }
    
    @IBAction func backButton(_ sender: Any) {
        if guestCount > 0 {
            guestNumber.removeLast()
            guestLabel[guestCount-1].text = "x"
            guestCount -= 1
            for i in 0...9 {
                numbersButton[i].alpha = 1
                numbersButton[i].isEnabled = true
            }
            for i in 0..<guestNumber.count {
                let index = guestNumber[i]
                numbersButton[index].alpha = 0.5
                numbersButton[index].isEnabled = false
            }
        }
        for i in 0..<guestNumber.count {
            print(guestNumber[i], terminator: "")
        }
        print("")
    }
    
    @IBAction func okButton(_ sender: Any) {
        count = count + 1
        var a = 0 //A表示有這個數字，且數字是在正確的位置
        var b = 0 //B表示有這個數字，但位置不對
        if guestCount != 4 {
            //建立提示框
            let alertController = UIAlertController(title: "輸入錯誤", message: "請輸入四個數字", preferredStyle: .alert)
            //建立確認按鈕
            let okAction = UIAlertAction(
                title: "確認",
                style: .default,
                handler: {
                (action: UIAlertAction!) -> Void in
            })
            alertController.addAction(okAction)
            //顯示提示框
            self.present(alertController, animated: true, completion: nil)
        }
        else {
            for i in 0...3 {
                if randomNumber.contains(guestNumber[i]) {
                    b = b + 1
                }
                if randomNumber[i] == guestNumber[i] {
                    a = a + 1
                }
            }
            b = b - a
            print("\(a)a\(b)b")
            
            guestTextView.text! += "第\(count)次\t\t\(guestNumber[0])\(guestNumber[1])\(guestNumber[2])\(guestNumber[3])\t\t\(a)a\(b)b\n"
        }
        if a == 4 {
            let userDefaults = UserDefaults.standard
            
            let alertController = UIAlertController(title: "恭喜答對！", message: "答案是:\(randomNumber[0])\(randomNumber[1])\(randomNumber[2])\(randomNumber[3])\t過關時間:\(timeCount/60)分\(timeCount%60)秒", preferredStyle: .alert)
            
            alertController.addTextField {
                (textField: UITextField!) -> Void in
                textField.placeholder = "輸入你的大名"
            }
            let saveAction = UIAlertAction(
                title: "儲存",
                style: .default,
                handler: {
                (action: UIAlertAction!) -> Void in
                    if let records = userDefaults.array(forKey: "data") as? [[String:Any]]{
                        self.records = records.compactMap({ recordsDic -> record? in
                            if let name = recordsDic["name"] as? String, let time = recordsDic["time"] as? String{
                                return record(name: name, time: time)
                            }else{
                                return nil
                            }
                        })
                    }
                    let playerName = (alertController.textFields?.first)!as UITextField
                    self.records.append(record(name: playerName.text!, time: self.timeLabel.text!))
                    print(self.records)
                    //print(NSHomeDirectory())
                    let array = self.records.map({ (record) -> [String: String] in
                        return ["name":record.name, "time": record.time]
                    })
                    userDefaults.set(array, forKey: "data")
                    userDefaults.synchronize()
                    /*
                    let playerName = (alertController.textFields?.first)!as UITextField
                    userDefaults.set(self.timeLabel.text, forKey: playerName.text!)
                    userDefaults.synchronize()
                    if let record = userDefaults.value(forKey: playerName.text!) as? String{
                        print(playerName.text!+record)
                    }
                    */
                    //回到開始頁
                    self.navigationController?.popViewController(animated: true)
            })
            alertController.addAction(saveAction)
            
            self.present(alertController, animated: true, completion: nil)
            
            timer.invalidate()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func updateTimer() {
        timeCount = timeCount + 1
        timeLabel.text = String(format: "%d:%02d", timeCount/60, timeCount%60)
        //timer.invalidate()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
