//
//  ViewController.swift
//  MarkdownView
//
//  Created by Albert Bori on 9/7/16.
//  Copyright © 2016 Albert Bori. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    
    let start = NSDate()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let markdown: String = "# An exhibit of Markdown\n\nThis note demonstrates some of what [Markdown][1] is capable of doing.\n\n*Note: Feel free to play with this page. Unlike regular notes, this doesn't automatically save itself.*\n\n## Basic formatting\n\nParagraphs can be written like so. A paragraph is the basic block of Markdown. A paragraph is what text will turn into when there is no reason it should become anything else.\n\nParagraphs must be separated by a blank line. Basic formatting of *italics* and **bold** is supported. This *can be **nested** like* so.\n\n## Lists\n\n### Ordered list\n\n1. Item 1\n2. A second item\n3. Number 3\n4. Ⅳ\n\n*Note: the fourth item uses the Unicode character for [Roman numeral four][2].*\n\n### Unordered list\n\n* An item\n* Another item\n* Yet another item\n* And there's more...\n\n## Paragraph modifiers\n\n### Code block\n\n    Code blocks are very useful for developers and other people who look at code or other things that are written in plain text. As you can see, it uses a fixed-width font.\n\nYou can also make `inline code` to add code into other things.\n\n### Quote\n\n> Here is a quote. What this is should be self explanatory. Quotes are automatically indented when they are used.\n\n## Headings\n\nThere are six levels of headings. They correspond with the six levels of HTML headings. You've probably noticed them already in the page. Each level down uses one more hash character.\n\n### Headings *can* also contain **formatting**\n\n### They can even contain `inline code`\n\nOf course, demonstrating what headings look like messes up the structure of the page.\n\nI don't recommend using more than three or four levels of headings here, because, when you're smallest heading isn't too small, and you're largest heading isn't too big, and you want each size up to look noticeably larger and more important, there there are only so many sizes that you can use.\n\n## URLs\n\nURLs can be made in a handful of ways:\n\n* A named link to [MarkItDown][3]. The easiest way to do these is to select what you want to make a link and hit `Ctrl+L`.\n* Another named link to [MarkItDown](http://www.markitdown.net/)\n* Sometimes you just want a URL like <http://www.markitdown.net/>.\n\n## Horizontal rule\n\nA horizontal rule is a line that goes across the middle of the page.\n\n---\n\nIt's sometimes handy for breaking things up.\n\n## Images\n\nMarkdown can also contain images. ![Flip Table](http://i2.kym-cdn.com/photos/images/original/000/170/508/flip_over_desk.jpg)\n\n## Finally\n\nThere's actually a lot more to Markdown than this. See the official [introduction][4] and [syntax][5] for more information. However, be aware that this is not using the official implementation, and this might work subtly differently in some of the little things.\n\n\n  [1]: http://daringfireball.net/projects/markdown/\n  [2]: http://www.fileformat.info/info/unicode/char/2163/index.htm\n  [3]: http://www.markitdown.net/\n  [4]: http://daringfireball.net/projects/markdown/basics\n  [5]: http://daringfireball.net/projects/markdown/syntax\n"
        
        let markdownView = MarkdownView(markdown: markdown)
        markdownView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(markdownView)
        scrollView.topAnchor.constraintEqualToAnchor(markdownView.topAnchor).active = true
        scrollView.leftAnchor.constraintEqualToAnchor(markdownView.leftAnchor).active = true
        markdownView.bottomAnchor.constraintEqualToAnchor(scrollView.bottomAnchor).active = true
        markdownView.rightAnchor.constraintEqualToAnchor(scrollView.rightAnchor).active = true
        markdownView.widthAnchor.constraintEqualToAnchor(scrollView.widthAnchor).active = true
        
        markdownView.didFinishLoadingImage = { imageView in
            print("Loaded: \( imageView.sd_imageURL())")
        }
        markdownView.didFinishLoadingImages = { imageView in
            print("All images loaded!")
        }
        markdownView.didTapHyperlink = { url in
            print("Tapped: \(url)")
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let end = NSDate()
        let timeInterval: Double = end.timeIntervalSinceDate(start)
        print("viewDidLayoutSubviews Completed in \(timeInterval) seconds")
    }

}

