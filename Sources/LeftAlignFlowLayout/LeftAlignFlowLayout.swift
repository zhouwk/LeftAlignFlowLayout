import UIKit

public protocol LeftAlignFlowLayoutDelegate: NSObjectProtocol {
    func layout(_ layout: LeftAlignFlowLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
}

/// 根据当前需求，先只考虑单组、不需要sectionInset、无header\footer的情况
public class LeftAlignFlowLayout: UICollectionViewLayout {
    
    // 元素上下左右间距
    public var itemSpacing = CGPoint(x: 5, y: 5)
    public weak var delegate: LeftAlignFlowLayoutDelegate?

    private lazy var attributesForElements = [UICollectionViewLayoutAttributes]()
    private var itemMaxWidth = CGFloat(0)
    
    
    public override func prepare() {
        super.prepare()
        attributesForElements.removeAll()
        guard let collectionView = collectionView, collectionView.numberOfSections == 1 else {
            return
        }
        itemMaxWidth = collectionView.frame.width - collectionView.contentInset.left - collectionView.contentInset.right
        let numberOfItems = collectionView.numberOfItems(inSection: 0)
        for row in 0 ..< numberOfItems {
            attributesForElements.append(layoutAttributesForItem(at: IndexPath(row: row, section: 0))!)
        }
    }
    
    
    public override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let delegate = delegate else {
            return nil
        }
        var size = delegate.layout(self, sizeForItemAt: indexPath)
        let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        var origin = CGPoint.zero
        var toNewRow = true
        if indexPath.row != 0 {
            let attributesForLastElement = attributesForElements[indexPath.row - 1]
            origin.x = attributesForLastElement.frame.maxX + itemSpacing.x
            origin.y = attributesForLastElement.frame.origin.y
            if origin.x + size.width <= contentAreaWidth {
                toNewRow = false
            } else {
                origin.x = 0
                origin.y = attributesForLastElement.frame.maxY + itemSpacing.y
            }
        }
        if toNewRow {
            size.width = min(size.width, itemMaxWidth)
        }
        attributes.frame = CGRect(origin: origin, size: size)
        return attributes
    }
    
    
    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return attributesForElements
    }
    
    public override var collectionViewContentSize: CGSize {
        return CGSize(width: contentAreaWidth, height: attributesForElements.last?.frame.maxY ?? 0)
    }
    
    var contentAreaWidth: CGFloat {
        guard let collectionView = collectionView else {
            return 0
        }
        return collectionView.frame.width - collectionView.contentInset.left - collectionView.contentInset.right
    }
}
