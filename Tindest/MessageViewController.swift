//
//  MessageViewController.swift
//  Tindest
//
//  Created by TakuSemba on 2016/12/07.
//  Copyright © 2016年 TakuSemba. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import XLPagerTabStrip
import SDWebImage
import Bond

class MessageViewController: UIViewController {
    
    class func instantiateFromStoryboard() -> MessageViewController {
        let storyboard = UIStoryboard(name: "Message", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: String(describing: self)) as! MessageViewController
    }
    
    internal let disposeBag = DisposeBag()
    
    internal let viewModel = MessageViewModel()
    
    @IBOutlet weak var tableView: UITableView!
    
    var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UINib(nibName: "MessageCollectionView", bundle: nil), forCellReuseIdentifier: "MessageCollectionView")
        self.tableView.register(UINib(nibName: "MessageTableViewCell", bundle: nil), forCellReuseIdentifier: "MessageTableViewCell")
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, -20, 0);
        
        self.tableView.rx.itemSelected
            .bindTo(self.viewModel.itemDidSelect)
            .addDisposableTo(self.disposeBag)
        
        let _ = viewModel.messageUsers.observeNext { [weak self] e in
            switch e.change {
            case .endBatchEditing:
                self?.tableView.reloadData()
                break
            default:
                break
            }
        }
        
        let _ = viewModel.newMatchedUsers.observeNext { [weak self] e in
            switch e.change {
                case .endBatchEditing:
                    self?.collectionView.reloadData()
                    break
                default:
                    break
            }
        }
    
    }

}

extension MessageViewController: IndicatorInfoProvider{
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "message", image: UIImage(named: "message"))
    }
}

extension MessageViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.newMatchedUsers.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MatchCollectionViewCell", for: indexPath as IndexPath) as! MatchCollectionViewCell
            cell.name.text = viewModel.newMatchedUsers[indexPath.item].name
            if let thumbnail = viewModel.newMatchedUsers[indexPath.item].avatarUrl {
                cell.thumbnail.sd_setImage(with: URL(string: thumbnail)!)
            } else {
                cell.thumbnail.image = UIImage(named: "profile_picture.png")
            }
        return cell
    }
}

extension MessageViewController : UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView:UITableView, numberOfRowsInSection section:Int) -> Int{
        var sectionNum: Int = 0
        
        if section == 0 {
            sectionNum = 1
        } else if section == 1{
            sectionNum = self.viewModel.messageUsers.count
        }
        
        return sectionNum
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        if indexPath.section == 0 {
            self.tableView.rowHeight = 120
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "MessageCollectionView", for: indexPath) as! MessageCollectionView

            cell.collectionView.dataSource = self
            collectionView = cell.collectionView
            
            let nib = UINib(nibName: "MatchCollectionViewCell", bundle: nil)
            cell.collectionView.register(nib, forCellWithReuseIdentifier: "MatchCollectionViewCell")
            return cell
            
        } else{
            self.tableView.rowHeight = 100
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "MessageTableViewCell", for: indexPath) as! MessageTableViewCell
            cell.name.text = self.viewModel.messageUsers[indexPath.item].name
            cell.message.text = self.viewModel.messageUsers[indexPath.item].location
            if let thumbnail = self.viewModel.messageUsers[indexPath.item].avatarUrl {
                cell.thumbnail.sd_setImage(with: URL(string: thumbnail)!)
            } else {
                cell.thumbnail.image = UIImage(named: "profile_picture.png")
            }
            return cell
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = Bundle.main.loadNibNamed("MessageSectionHeaderView", owner: self, options: nil)?.first as! MessageSectionHeaderView
        
        if section == 0 {
            view.title.text = "New Matches"
        } else if section == 1 {
         view.title.text = "Messages"
        }
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
}
