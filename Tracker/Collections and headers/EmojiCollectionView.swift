import UIKit

protocol EmojiSelectionDelegate: AnyObject {
    func didSelectEmoji(_ emoji: String)
}

final class EmojiCollectionView: UICollectionView {
    weak var emojiSelectionDelegate: EmojiSelectionDelegate?
    var emojis: [String] = [] // массив эмодзи
    var selectedIndexPath: IndexPath?
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        
        delegate = self
        dataSource = self
        register(EmojiCollectionViewCell.self, forCellWithReuseIdentifier: EmojiCollectionViewCell.reuseIdentifier)
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 52, height: 52)
        layout.sectionInset = UIEdgeInsets(top: 24, left: 18, bottom: 24, right: 18)
        layout.minimumInteritemSpacing = 1
        layout.minimumLineSpacing = 0
        self.collectionViewLayout = layout
        
        self.isScrollEnabled = false
        
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


extension EmojiCollectionView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedEmoji = emojis[indexPath.row]
        emojiSelectionDelegate?.didSelectEmoji(selectedEmoji)
        
        if let selectedIndexPath = selectedIndexPath, let cell = collectionView.cellForItem(at: selectedIndexPath) as? EmojiCollectionViewCell {
            cell.backgroundColor = UIColor.clear
        }
        
        if let cell = collectionView.cellForItem(at: indexPath) as? EmojiCollectionViewCell {
            cell.backgroundColor = UIColor.lightGray
        }
        
        selectedIndexPath = indexPath
    }
}

extension EmojiCollectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return emojis.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmojiCollectionViewCell.reuseIdentifier, for: indexPath) as? EmojiCollectionViewCell else {
            print("Unable to create EmojiCollectionViewCell")
            return UICollectionViewCell()
        }
        
        cell.label.text = emojis[indexPath.row]
        cell.label.font = UIFont.systemFont(ofSize: 32)
        cell.layer.cornerRadius = 16
        return cell
    }
}

extension EmojiCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: 52, height: 52)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
}



