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
        let markdown: String = "# Markdown Test\n\n---\n\nHeader 1\n==\nHeader 2\n-\n\n### General Typography\n*Lorem* **ipsum** _dolor_ __sit__ amet, [consectetur](google.com) [adipiscing] [elit][1]. Vivamus consequat, eros non hendrerit semper, nunc leo aliquet erat, quis mattis velit elit at tellus. Sed justo nunc, scelerisque nec neque quis, molestie egestas est. Nunc id facilisis neque. \n\nNunc maximus sem vel tellus rhoncus, ac commodo nulla eleifend. Curabitur vel augue massa. Phasellus imperdiet non sapien ut varius. Donec eu ipsum a ante mollis interdum feugiat vulputate purus. Etiam est sapien, cursus vel justo sit amet, facilisis rhoncus odio. In tincidunt est ipsum, sit amet malesuada felis maximus non. \n\n##### Literals\n\nIn a + paragraph --- , all-markdown *formatting_ [means nothing] if not # properly > (formatted)! 1.\n\n[adipiscing]: http://google.com \"Google\"\n [1]: http://google.com\n\n### Typography\n\n - `**Bold**` becomes **bold text**\n - `__bold text__` becomes __bold text__\n - `*italic text*` becomes *italic text*\n - `_italic text_` becomes _italic text_\n - \\`code\\` becomes `code`\n - `**_[Styled Link](http://google.com)_**` becomes **_[Styled Link](http://google.com)_**\n\n### Links\n\n * `[Inline Link](http://google.com \"Google\")` becomes [Inline Link](http://google.com \"Google\")\n * `[Reference Link][1]` becomes [Reference Link][1]\n * `[Named Reference Link]` becomes [Named Reference Link]\n * `[*Italic* Link](http://google.com \"Google\")` becomes [*Italic* Link](http://google.com \"Google\")\n * `[**Bold** Link](http://google.com \"Google\")` becomes [**Bold** Link](http://google.com \"Google\")\n\n[1]: http://google.com \"Google\"\n[Named Reference Link]: <http://google.com> \"Google\"\n\n### Images\n\n##### Inline\n\n+ `![Flip Table](http://i2.kym-cdn.com/photos/images/original/000/170/508/flip_over_desk.jpg)` becomes ![Flip Table](http://i2.kym-cdn.com/photos/images/original/000/170/508/flip_over_desk.jpg)\n+ `![Flip Table](http://i2.kym-cdn.com/photos/images/original/000/170/508/flip_over_desk.jpg \"Flip\")` becomes ![Flip Table](http://i2.kym-cdn.com/photos/images/original/000/170/508/flip_over_desk.jpg \"Flip\")\n\n##### Reference\n\n+ `![Flip][1]` becomes ![Flip][1]\n+ `![Flip]` becomes ![Flip]\n[1]: http://i2.kym-cdn.com/photos/images/original/000/170/508/flip_over_desk.jpg \"Title\"\n[Flip]: http://i2.kym-cdn.com/photos/images/original/000/170/508/flip_over_desk.jpg\n\n### Quotes\n\n```\n> The overriding design goal for Markdown's\n> formatting syntax is to make it as readable\n> as possible. The idea is that a\n> Markdown-formatted document should be\n> publishable as-is, as plain text, without\n> looking like it's been marked up with tags\n> or formatting instructions.\n```\n\nbecomes\n\n> The overriding design goal for Markdown's\n> formatting syntax is to make it as readable\n> as possible. The idea is that a\n> Markdown-formatted document should be\n> publishable as-is, as plain text, without\n> looking like it's been marked up with tags\n> or formatting instructions.\n\n### Code\n\n- \\`\\`\\`code\\`\\`\\` becomes ```code```\n- 4 spaces wrapped in newlines becomes:\n    \n    code\n\n### Lists\n\n#### Hyphens, Asterisks and Pluses\n\n--- \n\n```\n - Item 1\n - Item 2\n```\n\nbecomes\n\n - Item 1\n - Item 2\n\n```\n* Item 1\n* Item 2\n```\n\nbecomes\n\n* Item 1\n* Item 2\n\n```\n+ Item 1\n+ Item 2\n```\n\nbecomes\n\n+ Item 1\n+ Item 2\n\n#### Nested\n\n---\n\n```\n- Item 1\n    - Sub Item 1\n    - Sub Item 2\n- Item 2\n    - Sub Item 1\n    - Sub Item 2\n```\n\nbecomes\n\n- Item 1\n    - Sub Item 1\n    - Sub Item 2\n- Item 2\n    - Sub Item 1\n    - Sub Item 2\n\n#### Numerical (Ordered)\n\n--- \n\n```\n1. Item 1\n1. Item 2\n```\n\nbecomes\n\n1. Item 1\n2. Item 1\n\n"
        
        
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

