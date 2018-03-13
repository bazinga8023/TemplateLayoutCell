//
//  UITableView+TemplateLayoutCell.swift
//  TemplateLayoutCell
//
//  Created by 张俊安 on 2018/3/12.
//  Copyright © 2018年 John.Zhang. All rights reserved.
//

import UIKit


extension UITableView {

    func heightForCell(with identifier: String, cacheBy key: String, configuration: @escaping (_ cell: UITableViewCell) -> ()) -> Float {
        if identifier.isEmpty {
            return 0
        }

        if keyedHeightCache.existsHeight(for: key) {
            let cachedHeight = keyedHeightCache.height(for: key)
            return cachedHeight
        }

        let height = heightForCell(with: identifier, configuration: configuration)
        keyedHeightCache.cache(height, for: key)

        return height
    }


    static let systemAccessoryWidths: [UITableViewCellAccessoryType: Float] = [
        UITableViewCellAccessoryType.none : 0,
        UITableViewCellAccessoryType.disclosureIndicator : 34,
        UITableViewCellAccessoryType.detailDisclosureButton : 68,
        UITableViewCellAccessoryType.checkmark : 40,
        UITableViewCellAccessoryType.detailButton : 48
    ]

     private func systemFittingHeight(for configuratedCell: UITableViewCell) -> Float {

        var contentViewWidth: Float = Float(frame.width)

        var cellBounds = configuratedCell.bounds
        cellBounds.size.width = CGFloat(contentViewWidth)
        configuratedCell.bounds = cellBounds

        var rightSystemViewsWidth: Float = 0.0
        for view in subviews {
            if view.isKind(of: NSClassFromString("UITableViewIndex")!) {
                rightSystemViewsWidth = Float(view.frame.width)
                break
            }
        }

        if configuratedCell.accessoryView != nil {
            rightSystemViewsWidth += 16 + Float(configuratedCell.accessoryView?.frame.width ?? 0)
        } else {
            rightSystemViewsWidth += UITableView.systemAccessoryWidths[configuratedCell.accessoryType] ?? 0
        }

        if UIScreen.main.scale >= 3 && UIScreen.main.bounds.size.width >= 414 {
            rightSystemViewsWidth += 4
        }

        contentViewWidth -= rightSystemViewsWidth

        var fittingHeight: Float = 0

        if !configuratedCell.enForceFrameLayout && contentViewWidth > 0 {

            let widthFenceConstraint = NSLayoutConstraint.init(item: configuratedCell.contentView, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1.0, constant: CGFloat(contentViewWidth))

            var edgeConstraints = [NSLayoutConstraint]()
            if #available(iOS 10.2, *) {
                widthFenceConstraint.priority = UILayoutPriority(rawValue: UILayoutPriority.RawValue(Int(UILayoutPriority.required.rawValue) - 1));

                let leftCst = NSLayoutConstraint.init(item: configuratedCell.contentView, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: configuratedCell, attribute: NSLayoutAttribute.left, multiplier: 1.0, constant: 0)
                let rightCst = NSLayoutConstraint.init(item: configuratedCell.contentView, attribute: NSLayoutAttribute.right, relatedBy: NSLayoutRelation.equal, toItem: configuratedCell, attribute: NSLayoutAttribute.right, multiplier: 1.0, constant: CGFloat(-rightSystemViewsWidth))
                let topCst = NSLayoutConstraint.init(item: configuratedCell.contentView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: configuratedCell, attribute: NSLayoutAttribute.top, multiplier: 1.0, constant: 0)
                let bottomCst = NSLayoutConstraint.init(item: configuratedCell.contentView, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: configuratedCell, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: 0)
                edgeConstraints = [leftCst, rightCst, topCst, bottomCst]
                configuratedCell.addConstraints(edgeConstraints)
            }

            configuratedCell.contentView.addConstraint(widthFenceConstraint)

            fittingHeight = Float(configuratedCell.contentView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height)

            configuratedCell.contentView.removeConstraint(widthFenceConstraint)
            if #available(iOS 10.2, *) {
                configuratedCell.removeConstraints(edgeConstraints)
            }

        }

        if fittingHeight == 0 {
            if configuratedCell.contentView.constraints.count > 0 {
                let bool = objc_getAssociatedObject(self, &AssociatedKey.autoLayoutGetZeroKey) as? Bool ?? false
                if bool == false {
                    print("[TemplateLayoutCell] Warning once only: Cannot get a proper cell height (now 0) from '- systemFittingSize:'(AutoLayout). You should check how constraints are built in cell, making it into 'self-sizing' cell.")
                    objc_setAssociatedObject(self, &AssociatedKey.autoLayoutGetZeroKey, true, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                }
            }
            fittingHeight = Float(configuratedCell.sizeThatFits(CGSize.init(width: Double(Float(contentViewWidth)), height: 0.0)).height)
        }

        if fittingHeight == 0 {
            fittingHeight = 44
        }

        if separatorStyle != UITableViewCellSeparatorStyle.none {
            fittingHeight += Float(1.0 / UIScreen.main.scale)
        }

        return fittingHeight

    }


    func templateCell(for reuseIdentifier: String) -> UITableViewCell {
        assert(restorationIdentifier?.isEmpty ?? true, "Expect a valid identifier - \(reuseIdentifier)")

        var templateCell = templateCellsByIdentifiers[reuseIdentifier]

        if templateCell == nil {
            templateCell = dequeueReusableCell(withIdentifier: reuseIdentifier)
            assert(templateCell != nil, "Cell must be registered to table view for identifier - \(reuseIdentifier)")
            templateCell?.isTemplateLayoutCell = true
            templateCell?.contentView.translatesAutoresizingMaskIntoConstraints = false
            templateCellsByIdentifiers[reuseIdentifier] = templateCell!
        }

        return templateCell!
    }


    private func heightForCell(with identifier: String, configuration: ((_ cell: UITableViewCell) -> ())?) -> Float{
        if identifier.isEmpty {
            return 0
        }

        let templateLayoutCell = templateCell(for: identifier)

        templateLayoutCell.prepareForReuse()

        if let configuration = configuration {
            configuration(templateLayoutCell)
        }

        return systemFittingHeight(for: templateLayoutCell)

    }




}

extension UITableView {

    private struct AssociatedKey {
        static var keyedHeightCacheKey = "keyedHeightCacheKey"
        static var autoLayoutGetZeroKey = "autoLayoutGetZeroKey"
        static var templateCellsByIdentifiersKey = "templateCellsByIdentifiersKey"
    }

    private var keyedHeightCache: KeyedHeightCache {
        get {
            var cache = objc_getAssociatedObject(self, &AssociatedKey.keyedHeightCacheKey) as? KeyedHeightCache
            if cache == nil {
                cache = KeyedHeightCache()
                objc_setAssociatedObject(self, &AssociatedKey.keyedHeightCacheKey, cache!, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
            return cache!
        }
    }


    private var templateCellsByIdentifiers: [String: UITableViewCell] {
        set {
            objc_setAssociatedObject(self, &AssociatedKey.templateCellsByIdentifiersKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }

        get {
            guard let templateCellsByIdentifiers = objc_getAssociatedObject(self, &AssociatedKey.templateCellsByIdentifiersKey) as? [String: UITableViewCell] else {
                let rawRemplateCellsByIdentifiers = [String: UITableViewCell]()
                objc_setAssociatedObject(self, &AssociatedKey.templateCellsByIdentifiersKey, rawRemplateCellsByIdentifiers, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return rawRemplateCellsByIdentifiers
            }
            return templateCellsByIdentifiers
        }
    }


}


extension UITableViewCell {

    private struct AssociatedKey {
        static var isTemplateLayoutCellKey = "isTemplateLayoutCellKey"
        static var enforceFrameLayoutKey = "enforceFrameLayoutKey"
    }

    var isTemplateLayoutCell: Bool {
        set {
            objc_setAssociatedObject(self, &AssociatedKey.isTemplateLayoutCellKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
        }
        get {
            guard let bool = objc_getAssociatedObject(self, &AssociatedKey.isTemplateLayoutCellKey) as? Bool else { return false }
            return bool
        }
    }

    var enForceFrameLayout: Bool {
        set {
            objc_setAssociatedObject(self, &AssociatedKey.enforceFrameLayoutKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
        }
        get {
            guard let bool = objc_getAssociatedObject(self, &AssociatedKey.enforceFrameLayoutKey) as? Bool else { return false }
            return bool
        }
    }
}











