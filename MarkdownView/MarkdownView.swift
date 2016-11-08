//
//  MarkdownView.swift
//  MarkdownView
//
//  Created by Albert Bori on 9/7/16.
//  Copyright © 2016 Albert Bori. All rights reserved.
//

import Foundation
import MMMarkdown
import SDWebImage

class MarkdownView: UIView, UITextViewDelegate {
    
    var markdown: String {
        didSet {
            buildSubViews()
        }
    }
    var formatting: MarkdownFormatting
    var didFinishLoadingImage: ((UIImageView)->())?
    var didFinishLoadingImages: (()->())?
    var didTapHyperlink: ((NSURL)->())?
    
    private var _images: [LoadableImage] = []
    
    init(markdown: String) {
        self.markdown = markdown
        self.formatting = MarkdownView.getDefaultFormatting()
        super.init(frame: CGRectZero)
        
        buildSubViews()
    }
    
    init(markdown: String, formatting: MarkdownFormatting) {
        self.markdown = markdown
        self.formatting = formatting
        super.init(frame: CGRectZero)
        
        buildSubViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        markdown = ""
        self.formatting = MarkdownView.getDefaultFormatting()
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        markdown = ""
        self.formatting = MarkdownView.getDefaultFormatting()
        super.init(frame: frame)
    }
    
    func buildSubViews() {
        self.subviews.forEach({ $0.removeFromSuperview() })
        
        var start = NSDate()
        let parser = MMParser.init(extensions: MMMarkdownExtensions.GitHubFlavored)
        let document = try! parser.parseMarkdown(markdown)
        var end = NSDate()
        var timeInterval: Double = end.timeIntervalSinceDate(start)
        print("Parsed in \(timeInterval) seconds")
        
        start = NSDate()
        var views = [UIView]()
        let currentText = NSMutableAttributedString()
        
        for element in document.elements {
            if element.type == MMElementTypeHTML {
                print("HTML")
                currentText.appendAttributedString(NSAttributedString(string: (markdown as NSString).substringWithRange(element.range), attributes: nil))
            } else if let view = getViewForElement(element as! MMElement, document: document, currentText: currentText) {
                tryAddTextView(currentText, to: &views)
                views.append(view)
            }
        }
        
        tryAddTextView(currentText, to: &views)
        
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = UILayoutConstraintAxis.Vertical
        stackView.alignment = UIStackViewAlignment.Leading
        stackView.distribution = UIStackViewDistribution.EqualSpacing
        stackView.spacing = 8
        
        views.forEach({ stackView.addArrangedSubview($0) })
        
        self.addSubview(stackView)
        self.topAnchor.constraintEqualToAnchor(stackView.topAnchor).active = true
        self.leftAnchor.constraintEqualToAnchor(stackView.leftAnchor).active = true
        stackView.bottomAnchor.constraintEqualToAnchor(self.bottomAnchor).active = true
        stackView.rightAnchor.constraintEqualToAnchor(self.rightAnchor).active = true
        
        end = NSDate()
        timeInterval = end.timeIntervalSinceDate(start)
        print("UIView tree built in \(timeInterval) seconds")
        
        
        //load images
        for loadableImage in _images {
            loadableImage.imageView.sd_setImageWithURL(
                loadableImage.url,
                completed: { [weak self] (image, error, cacheType, url) in
                    loadableImage.loaded = true
                    self?.didFinishLoadingImage?(loadableImage.imageView)
                    if self != nil && self!._images.indexOf({ !$0.loaded }) == nil {
                        self!.didFinishLoadingImages?()
                    }
                }
            )
        }
    }
    
    func getViewForElement(element: MMElement, document: MMDocument, currentText: NSMutableAttributedString, level: Int = 0) -> UIView? {
        
        var elementSubviews: [UIView] = []
        
        var textFormatting: BaseTextFormatting?
        var viewFormatting: BaseViewFormatting?
        var isBlockElement = false
        var href: String?
        var isStrikethrough = false
        switch element.type
        {
        case MMElementTypeHeader:
            //print("\(String(count: level, repeatedValue: "\t" as Character))Header")
            isBlockElement = true
            switch element.level {
            case 1:
                textFormatting = formatting.header1.text
                viewFormatting = formatting.header1.view
                break;
            case 2:
                textFormatting = formatting.header2.text
                viewFormatting = formatting.header2.view
                break;
            case 3:
                textFormatting = formatting.header3.text
                viewFormatting = formatting.header3.view
                break;
            case 4:
                textFormatting = formatting.header4.text
                viewFormatting = formatting.header4.view
                break;
            case 5:
                textFormatting = formatting.header5.text
                viewFormatting = formatting.header5.view
                break;
            case 6:
                textFormatting = formatting.header6.text
                viewFormatting = formatting.header6.view
                break;
            default:
                textFormatting = formatting.header1.text
                viewFormatting = formatting.header1.view
                break;
            }
            break;
        case MMElementTypeParagraph:
            //print("\(String(count: level, repeatedValue: "\t" as Character))Paragraph")
            isBlockElement = true
            textFormatting = formatting.paragraphText
            break;
        case MMElementTypeBulletedList:
            //print("\(String(count: level, repeatedValue: "\t" as Character))Unordered List")
            textFormatting = formatting.list.text
            viewFormatting = formatting.list.view
            break;
        case MMElementTypeNumberedList:
            //print("\(String(count: level, repeatedValue: "\t" as Character))Ordered List")
            textFormatting = formatting.list.text
            viewFormatting = formatting.list.view
            break;
        case MMElementTypeListItem:
            //print("\(String(count: level, repeatedValue: "\t" as Character))List Item")
            isBlockElement = true
            textFormatting = formatting.listItem.text
            viewFormatting = formatting.listItem.view
            break;
        case MMElementTypeBlockquote:
            //print("\(String(count: level, repeatedValue: "\t" as Character))BlockQuote")
            isBlockElement = true
            textFormatting = formatting.quote.text
            viewFormatting = formatting.quote.view
            break;
        case MMElementTypeCodeBlock:
            //print("\(String(count: level, repeatedValue: "\t" as Character))Code Block")
            isBlockElement = true
            textFormatting = formatting.codeBlock.text
            viewFormatting = formatting.codeBlock.view
            break;
        case MMElementTypeLineBreak:
            //print("\(String(count: level, repeatedValue: "\t" as Character))Line Break")
            break;
        case MMElementTypeHorizontalRule:
            //print("\(String(count: level, repeatedValue: "\t" as Character))Horizontal Rule")
            tryAddTextView(currentText, to: &elementSubviews, level: level + 1)
            let horizontalRuleView = UIView()
            horizontalRuleView.backgroundColor = UIColor.lightGrayColor()
            horizontalRuleView.heightAnchor.constraintEqualToConstant(1)
            horizontalRuleView.widthAnchor.constraintEqualToConstant(275)
            elementSubviews.append(horizontalRuleView)
            break;
        case MMElementTypeStrikethrough:
            textFormatting = formatting.strikethroughText
            isStrikethrough = true
            break;
        case MMElementTypeStrong:
            textFormatting = formatting.boldText
            break;
        case MMElementTypeEm:
            textFormatting = formatting.italicText
            break;
        case MMElementTypeCodeSpan:
            textFormatting = formatting.codeText
            break;
        case MMElementTypeImage:
            //print("\(String(count: level, repeatedValue: "\t" as Character))Image")
            if let imageURL = NSURL(string: element.href) {
                let imageView = UIImageView()
                imageView.contentMode = UIViewContentMode.ScaleAspectFit
                _images.append(LoadableImage(imageView: imageView, url: imageURL))
                tryAddTextView(currentText, to: &elementSubviews, level: level + 1)
                elementSubviews.append(imageView)
                viewFormatting = formatting.image
            }
            break;
        case MMElementTypeLink:
            textFormatting = formatting.hyperlinkText
            href = element.href
            break;
        case MMElementTypeMailTo:
            textFormatting = formatting.hyperlinkText
            href = element.href
            break;
        case MMElementTypeEntity:
            break;
        case MMElementTypeTable:
            break;
        case MMElementTypeTableHeader:
            break;
        case MMElementTypeTableHeaderCell:
            break;
        case MMElementTypeTableRow:
            break;
        case MMElementTypeTableRowCell:
            break;
        default:
            //print("\(String(count: level, repeatedValue: "\t" as Character))Unkown (\(element.type.dynamicType))")
            break;
        }
        
        var formattingAttributes: [String: AnyObject]?
        if let textFormatting = textFormatting {
            formattingAttributes = [NSFontAttributeName: textFormatting.font]
            if let color = textFormatting.color {
                formattingAttributes![NSForegroundColorAttributeName] = color
            }
            if let bgColor = textFormatting.backgroundColor {
                formattingAttributes![NSBackgroundColorAttributeName] = bgColor
            }
        }
        
        if let href = href {
            formattingAttributes?[NSLinkAttributeName] = href
        }
        
        if isStrikethrough {
            formattingAttributes?[NSStrikethroughStyleAttributeName] = 1
        }
        
        if element.children.count > 0 {
            for child in element.children {
                if child.type == MMElementTypeNone || child.type == MMElementTypeHTML || child.type == MMElementTypeLineBreak {
                    if child.range.length == 0 {
                        currentText.appendAttributedString(NSAttributedString(string: "\n", attributes: nil))
                    } else {
                        currentText.appendAttributedString(NSAttributedString(string: (document.markdown as NSString).substringWithRange(child.range), attributes: formattingAttributes))
                    }
                } else if let view = getViewForElement(child as! MMElement, document: document, currentText: currentText, level: level + 1) {
                    tryAddTextView(currentText, to: &elementSubviews, level: level + 1)
                    elementSubviews.append(view)
                }
            }
        }
        
        if isBlockElement {
            //strip trailing newlines (they add extra, unnecessary spacing)
            if currentText.string.hasSuffix("\n") {
                currentText.deleteCharactersInRange(NSRange(location: currentText.string.characters.count - 1, length: 1))
            }
            tryAddTextView(currentText, to: &elementSubviews, level: level + 1)
        }
        
        var elementView: UIView
        
        if elementSubviews.count == 0 {
            return nil
        } else if elementSubviews.count == 1 {
            elementView = elementSubviews.first!
        } else {
            let elementStackView = UIStackView()
            elementStackView.axis = UILayoutConstraintAxis.Vertical
            elementStackView.alignment = UIStackViewAlignment.Leading
//            elementStackView.distribution = UIStackViewDistribution.EqualSpacing
            
            elementSubviews.forEach({ elementStackView.addArrangedSubview($0) })
            
            elementView = elementStackView
        }
        
        //handle list item layout
        if element.type == MMElementTypeListItem {
            let listItemStackView = UIStackView()
            listItemStackView.axis = UILayoutConstraintAxis.Horizontal
            listItemStackView.spacing = formatting.itemSpacing
            listItemStackView.alignment = UIStackViewAlignment.Top
            let delimiterLabel = UILabel()
            delimiterLabel.setContentHuggingPriority(999, forAxis: UILayoutConstraintAxis.Horizontal)
            delimiterLabel.font = textFormatting?.font
            delimiterLabel.textColor = textFormatting?.color
            if element.parent?.type == MMElementTypeNumberedList {
                delimiterLabel.text = "\((element.parent.children.indexOf({ $0 === element }) ?? 0) + 1)."
            } else {
                delimiterLabel.text = "•"
            }
            
            listItemStackView.addArrangedSubview(delimiterLabel)
            listItemStackView.addArrangedSubview(elementView)
            elementView = listItemStackView
        }
        
        //conditionally add surrounding edge views
        if viewFormatting?.topEdgeView != nil || viewFormatting?.rightEdgeView != nil || viewFormatting?.bottomEdgeView != nil || viewFormatting?.leftEdgeView != nil {
            let innerVerticalStackView = UIStackView()
            innerVerticalStackView.axis = UILayoutConstraintAxis.Vertical
            if let topEdgeView = viewFormatting?.topEdgeView {
                innerVerticalStackView.addArrangedSubview(topEdgeView)
            }
            if viewFormatting?.leftEdgeView != nil || viewFormatting?.rightEdgeView != nil {
                let innerHorizontalStackView = UIStackView()
                innerHorizontalStackView.axis = UILayoutConstraintAxis.Horizontal
                if let leftEdgeView = viewFormatting?.leftEdgeView {
                    innerHorizontalStackView.addArrangedSubview(leftEdgeView)
                }
                innerHorizontalStackView.addArrangedSubview(elementView)
                if let rightEdgeView = viewFormatting?.rightEdgeView {
                    innerHorizontalStackView.addArrangedSubview(rightEdgeView)
                }
                innerVerticalStackView.addArrangedSubview(innerHorizontalStackView)
            } else {
                innerVerticalStackView.addArrangedSubview(elementView)
            }
            if let bottomEdgeView = viewFormatting?.bottomEdgeView {
                innerVerticalStackView.addArrangedSubview(bottomEdgeView)
            }
            elementView = innerVerticalStackView
        }
        
        //Add formatting view enclosure if necessary. Caution is taken here because adding constraints is expensive in this context for some reason.
        if viewFormatting?.padding != nil ||
            (elementView is UIStackView && (viewFormatting?.backgroundColor != nil || viewFormatting?.cornerRadius != nil || viewFormatting?.borderWidth != nil || viewFormatting?.borderColor != nil)) {
            let backgroundView = UIView()
            elementView.translatesAutoresizingMaskIntoConstraints = false
            backgroundView.addSubview(elementView)
            elementView.topAnchor.constraintEqualToAnchor(backgroundView.topAnchor, constant: viewFormatting?.padding?.top ?? 0).active = true
            elementView.leftAnchor.constraintEqualToAnchor(backgroundView.leftAnchor, constant: viewFormatting?.padding?.left ?? 0).active = true
            backgroundView.bottomAnchor.constraintEqualToAnchor(elementView.bottomAnchor, constant: viewFormatting?.padding?.bottom ?? 0).active = true
            backgroundView.rightAnchor.constraintEqualToAnchor(elementView.rightAnchor, constant: viewFormatting?.padding?.right ?? 0).active = true
            
            elementView = backgroundView
        }
        
        if let backgroundColor = viewFormatting?.backgroundColor {
            elementView.backgroundColor = backgroundColor
        }
        if let cornerRadius = viewFormatting?.cornerRadius {
            elementView.layer.cornerRadius = cornerRadius
        }
        if let borderWidth = viewFormatting?.borderWidth, let borderColor = viewFormatting?.borderColor?.CGColor {
            elementView.layer.borderWidth = borderWidth
            elementView.layer.borderColor = borderColor
        }
        
        //set margins
        if let margins = viewFormatting?.margins {
            let containerView = UIView()
            containerView.addSubview(elementView)
            elementView.translatesAutoresizingMaskIntoConstraints = false
            elementView.topAnchor.constraintEqualToAnchor(containerView.topAnchor, constant: margins.top).active = true
            elementView.leftAnchor.constraintEqualToAnchor(containerView.leftAnchor, constant: margins.left).active = true
            containerView.bottomAnchor.constraintEqualToAnchor(elementView.bottomAnchor, constant: margins.bottom).active = true
            containerView.rightAnchor.constraintEqualToAnchor(elementView.rightAnchor, constant: margins.right).active = true
            
            elementView = containerView
        }
        
        return elementView
    }
    
    func tryAddTextView(currentText: NSMutableAttributedString, inout to views: [UIView], level: Int = 0) {
        if currentText.length > 0 {
            //print("\(String(count: level, repeatedValue: "\t" as Character))(Text Flushed: \(currentText.string.stringByReplacingOccurrencesOfString("\n", withString: "\\n")))")
            let textView = UITextView()
            textView.scrollEnabled = false
            textView.editable = false
            textView.delegate = self
            textView.textContainerInset = UIEdgeInsetsZero
            textView.textContainer.lineFragmentPadding = 0
            textView.setContentCompressionResistancePriority(999, forAxis: UILayoutConstraintAxis.Horizontal)
            textView.backgroundColor = UIColor.clearColor()
            textView.attributedText = currentText
            currentText.setAttributedString(NSAttributedString(string: ""))
            views.append(textView)
        }
    }
    
    //MARK: - Events and handlers
    
    private class LoadableImage {
        var imageView: UIImageView
        var url: NSURL
        var loaded: Bool = false
        
        init(imageView: UIImageView, url: NSURL) {
            self.imageView = imageView
            self.url = url
        }
    }
    
    //MARK: UITextViewDelegate
    
    func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool {
        didTapHyperlink?(URL)
        return false
    }
    
    //MARK: - Formatting
    
    struct MarkdownFormatting {
        var itemSpacing: CGFloat
        var header1: BlockFormatting
        var header2: BlockFormatting
        var header3: BlockFormatting
        var header4: BlockFormatting
        var header5: BlockFormatting
        var header6: BlockFormatting
        var paragraphText: TextFormatting
        var boldText: TextFormatting
        var italicText: TextFormatting
        var hyperlinkText: TextFormatting
        var strikethroughText: TextFormatting
        var codeText: TextFormatting
        var codeBlock: BlockFormatting
        var quote: BlockFormatting
        var image: ViewFormatting
        var list: BlockFormatting
        var listItem: BlockFormatting
    }
    
    struct TextFormatting: BaseTextFormatting {
        var color: UIColor?
        var backgroundColor: UIColor?
        var font: UIFont
    }
    
    struct BlockFormatting {
        var text: TextFormatting
        var view: ViewFormatting
    }
    
    struct ViewFormatting: BaseViewFormatting {
        var backgroundColor: UIColor?
        var cornerRadius: CGFloat?
        var borderColor: UIColor?
        var borderWidth: CGFloat?
        var margins: UIEdgeInsets?
        var padding: UIEdgeInsets?
        var topEdgeView: UIView?
        var rightEdgeView: UIView?
        var bottomEdgeView: UIView?
        var leftEdgeView: UIView?
    }
    
    static func getDefaultFormatting() -> MarkdownFormatting {
        let itemSpacing: CGFloat = 8
        let header1 = BlockFormatting(text: TextFormatting(color: nil, backgroundColor: nil, font: UIFont(name: "HelveticaNeue-Medium", size: 36)!), view: ViewFormatting(backgroundColor: nil, cornerRadius: nil, borderColor: nil, borderWidth: nil, margins: nil, padding: nil, topEdgeView: nil, rightEdgeView: nil, bottomEdgeView: nil, leftEdgeView: nil))
        let header2 = BlockFormatting(text: TextFormatting(color: nil, backgroundColor: nil, font: UIFont(name: "HelveticaNeue-Medium", size: 30)!), view: ViewFormatting(backgroundColor: nil, cornerRadius: nil, borderColor: nil, borderWidth: nil, margins: nil, padding: nil, topEdgeView: nil, rightEdgeView: nil, bottomEdgeView: nil, leftEdgeView: nil))
        let header3 = BlockFormatting(text: TextFormatting(color: nil, backgroundColor: nil, font: UIFont(name: "HelveticaNeue-Medium", size: 24)!), view: ViewFormatting(backgroundColor: nil, cornerRadius: nil, borderColor: nil, borderWidth: nil, margins: nil, padding: nil, topEdgeView: nil, rightEdgeView: nil, bottomEdgeView: nil, leftEdgeView: nil))
        let header4 = BlockFormatting(text: TextFormatting(color: nil, backgroundColor: nil, font: UIFont(name: "HelveticaNeue-Medium", size: 18)!), view: ViewFormatting(backgroundColor: nil, cornerRadius: nil, borderColor: nil, borderWidth: nil, margins: nil, padding: nil, topEdgeView: nil, rightEdgeView: nil, bottomEdgeView: nil, leftEdgeView: nil))
        let header5 = BlockFormatting(text: TextFormatting(color: nil, backgroundColor: nil, font: UIFont(name: "HelveticaNeue-Medium", size: 14)!), view: ViewFormatting(backgroundColor: nil, cornerRadius: nil, borderColor: nil, borderWidth: nil, margins: nil, padding: nil, topEdgeView: nil, rightEdgeView: nil, bottomEdgeView: nil, leftEdgeView: nil))
        let header6 = BlockFormatting(text: TextFormatting(color: nil, backgroundColor: nil, font: UIFont(name: "HelveticaNeue-Medium", size: 13)!), view: ViewFormatting(backgroundColor: nil, cornerRadius: nil, borderColor: nil, borderWidth: nil, margins: nil, padding: nil, topEdgeView: nil, rightEdgeView: nil, bottomEdgeView: nil, leftEdgeView: nil))
        let paragraphText = TextFormatting(color: nil, backgroundColor: nil, font: UIFont(name: "HelveticaNeue", size: 13)!)
        let boldText = TextFormatting(color: nil, backgroundColor: nil, font: UIFont(name: "HelveticaNeue-Bold", size: 13)!)
        let italicText = TextFormatting(color: nil, backgroundColor: nil, font: UIFont(name: "HelveticaNeue-Italic", size: 13)!)
        let hyperlinkText = TextFormatting(color:  UIColor.blueColor(), backgroundColor: nil, font: UIFont(name: "HelveticaNeue", size: 13)!)
        let strikethroughText = TextFormatting(color:  UIColor.blueColor(), backgroundColor: nil, font: UIFont(name: "HelveticaNeue", size: 13)!)
        let codeText = TextFormatting(color: nil, backgroundColor: UIColor.blackColor().colorWithAlphaComponent(0.1), font: UIFont(name: "Menlo", size: 11)!)
        let codeBlock = BlockFormatting(text: TextFormatting(color: nil, backgroundColor: nil, font: UIFont(name: "Menlo", size: 11)!), view: ViewFormatting(backgroundColor: UIColor.blackColor().colorWithAlphaComponent(0.1), cornerRadius: 4, borderColor: UIColor.lightGrayColor(), borderWidth: 1, margins: nil, padding: UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8), topEdgeView: nil, rightEdgeView: nil, bottomEdgeView: nil, leftEdgeView: nil))
        var quote = BlockFormatting(text: TextFormatting(color: nil, backgroundColor: nil, font: UIFont(name: "HelveticaNeue", size: 13)!), view: ViewFormatting(backgroundColor: nil, cornerRadius: nil, borderColor: nil, borderWidth: nil, margins: nil, padding: nil, topEdgeView: nil, rightEdgeView: nil, bottomEdgeView: nil, leftEdgeView: nil))
        let image = ViewFormatting(backgroundColor: nil, cornerRadius: nil, borderColor: nil, borderWidth: nil, margins: nil, padding: nil, topEdgeView: nil, rightEdgeView: nil, bottomEdgeView: nil, leftEdgeView: nil)
        let list = BlockFormatting(text: TextFormatting(color: nil, backgroundColor: nil, font: UIFont(name: "HelveticaNeue", size: 13)!), view: ViewFormatting(backgroundColor: nil, cornerRadius: nil, borderColor: nil, borderWidth: nil, margins: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0), padding: nil, topEdgeView: nil, rightEdgeView: nil, bottomEdgeView: nil, leftEdgeView: nil))
        let listItem = BlockFormatting(text: TextFormatting(color: nil, backgroundColor: nil, font: UIFont(name: "HelveticaNeue", size: 13)!), view: ViewFormatting(backgroundColor: nil, cornerRadius: nil, borderColor: nil, borderWidth: nil, margins: nil, padding: nil, topEdgeView: nil, rightEdgeView: nil, bottomEdgeView: nil, leftEdgeView: nil))
        
        //Add gray bar to left of quote
        let quoteIndentView = UIView()
        let quoteBarView = UIView()
        quoteIndentView.addSubview(quoteBarView)
        quoteBarView.translatesAutoresizingMaskIntoConstraints = false
        quoteBarView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.1)
        quoteBarView.widthAnchor.constraintEqualToConstant(itemSpacing).active = true
        quoteBarView.topAnchor.constraintEqualToAnchor(quoteIndentView.topAnchor).active = true
        quoteBarView.leftAnchor.constraintEqualToAnchor(quoteIndentView.leftAnchor).active = true
        quoteIndentView.rightAnchor.constraintEqualToAnchor(quoteBarView.rightAnchor, constant: itemSpacing).active = true
        quoteIndentView.bottomAnchor.constraintEqualToAnchor(quoteBarView.bottomAnchor).active = true
        quote.view.leftEdgeView = quoteIndentView
        
        return MarkdownFormatting(itemSpacing: itemSpacing, header1: header1, header2: header2, header3: header3, header4: header4, header5: header5, header6: header6, paragraphText: paragraphText, boldText: boldText, italicText: italicText, hyperlinkText: hyperlinkText, strikethroughText: strikethroughText, codeText: codeText, codeBlock: codeBlock, quote: quote, image: image, list: list, listItem: listItem)
    }
}

private protocol BaseTextFormatting {
    var color: UIColor? { get set }
    var backgroundColor: UIColor? { get set }
    var font: UIFont { get set }
}

private protocol BaseViewFormatting {
    var backgroundColor: UIColor? { get set }
    var cornerRadius: CGFloat? { get set }
    var borderColor: UIColor? { get set }
    var borderWidth: CGFloat? { get set }
    var margins: UIEdgeInsets? { get set }
    var padding: UIEdgeInsets? { get set }
    var topEdgeView: UIView? { get set }
    var rightEdgeView: UIView? { get set }
    var bottomEdgeView: UIView? { get set }
    var leftEdgeView: UIView? { get set }
}
