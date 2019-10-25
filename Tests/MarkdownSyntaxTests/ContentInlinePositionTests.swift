import XCTest
@testable import MarkdownSyntax

final class ContentInlinePositionTests: XCTestCase {

    func testLinkRange() throws {
        // given
        let input = #"[alpha](https://example.com "bravo")"#

        // when
        let tree = try Parser().parse(text: input)
        let paragraph = tree.children.first as? Paragraph
        let link = paragraph?.children.first as? Link
        let range = input.range(0...35)

        // then
        XCTAssertEqual(link?.position.range, range)
        XCTAssertEqual(input[range], #"[alpha](https://example.com "bravo")"#)
    }

    func testAutoLinkRange() throws {
        // given
        let input = "https://example.com"

        // when
        let tree = try Parser().parse(text: input)
        let paragraph = tree.children.first as? Paragraph
        let link = paragraph?.children[1] as? Link
        let range = input.range(0...18)

        // then
        XCTAssertEqual(link?.position.range, range)
        XCTAssertEqual(input[range], "https://example.com")
    }

    func testLinkWithEmptyChildRange() throws {
        // given
        let input = "[](https://example.com)"

        // when
        let tree = try Parser().parse(text: input)
        let paragraph = tree.children.first as? Paragraph
        let link = paragraph?.children.first as? Link
        let range = input.range(0...22)

        // then
        XCTAssertEqual(link?.position.range, range)
        XCTAssertEqual(input[range], "[](https://example.com)")
    }

    func testInternalLinkRange() throws {
        // given
        let input = "[Page 52](#some-topic)"

        // when
        let tree = try Parser().parse(text: input)
        let paragraph = tree.children.first as? Paragraph
        let link = paragraph?.children.first as? Link
        let range = input.range(0...21)

        // then
        XCTAssertEqual(link?.position.range, range)
        XCTAssertEqual(input[range], "[Page 52](#some-topic)")
    }

    func testImageRange() throws {
        // given
        let input = #"![alpha](https://example.com/favicon.ico "bravo")"#

        // when
        let tree = try Parser().parse(text: input)
        let paragraph = tree.children.first as? Paragraph
        let image = paragraph?.children.first as? Image
        let range = input.range(0...48)

        // then
        XCTAssertEqual(image?.position.range, range)
        XCTAssertEqual(input[range], #"![alpha](https://example.com/favicon.ico "bravo")"#)
    }

    func testStrikethroughRange() throws {
        // given
        let input = "~~alpha~~"

        // when
        let tree = try Parser().parse(text: input)
        let paragraph = tree.children.first as? Paragraph
        let delete = paragraph?.children.first as? Delete
        let range = input.range(0...8)

        // then
        XCTAssertEqual(delete?.position.range, range)
        XCTAssertEqual(input[range], "~~alpha~~")
    }

    func testStrongRange() throws {
        // given
        let input = "**alpha**"

        // when
        let tree = try Parser().parse(text: input)
        let paragraph = tree.children.first as? Paragraph
        let node = paragraph?.children.first as? Strong
        let range = input.range(0...8)

        // then
        XCTAssertEqual(node?.position.range, range)
        XCTAssertEqual(input[range], "**alpha**")
    }

    func testStrongUnderscoreRange() throws {
        // given
        let input = "__alpha__"

        // when
        let tree = try Parser().parse(text: input)
        let paragraph = tree.children.first as? Paragraph
        let node = paragraph?.children.first as? Strong
        let range = input.range(0...8)

        // then
        XCTAssertEqual(node?.position.range, range)
        XCTAssertEqual(input[range], "__alpha__")
    }

    func testEmphasisRange() throws {
        // given
        let input = "*alpha*"

        // when
        let tree = try Parser().parse(text: input)
        let paragraph = tree.children.first as? Paragraph
        let node = paragraph?.children.first as? Emphasis
        let range = input.range(0...6)

        // then
        XCTAssertEqual(node?.position.range, range)
        XCTAssertEqual(input[range], "*alpha*")
    }

    func testEmphasisUnderscoreRange() throws {
        // given
        let input = "_alpha_"

        // when
        let tree = try Parser().parse(text: input)
        let paragraph = tree.children.first as? Paragraph
        let node = paragraph?.children.first as? Emphasis
        let range = input.range(0...6)

        // then
        XCTAssertEqual(node?.position.range, range)
        XCTAssertEqual(input[range], "_alpha_")
    }

    func testInlineCodeRange() throws {
        // given
        let input = "`alpha`"

        // when
        let tree = try Parser().parse(text: input)
        let paragraph = tree.children.first as? Paragraph
        let node = paragraph?.children.first as? InlineCode
        let range = input.range(0...6)

        // then
        XCTAssertEqual(node?.position.range, range)
        XCTAssertEqual(input[range], "`alpha`")
    }

    func testSoftBreakRange() throws {
        // given
        let input = "foo\nbar"

        // when
        let tree = try Parser().parse(text: input)
        let paragraph = tree.children.first as? Paragraph
        let softBreak = paragraph?.children[1] as? SoftBreak

        // then
        XCTAssertNil(softBreak?.position.range) // Cmark don't return any position for SoftBreak
    }

    func testSpaceLineBreakRange() throws {
        // given
        let input =
        """
        test
        test
        """

        // when
        let tree = try Parser().parse(text: input)
        let paragraph = tree.children.first as? Paragraph
        let lineBreak = paragraph?.children[1] as? Break

        // then
        XCTAssertNil(lineBreak?.position.range) // Cmark don't return any position for LineBreak
    }

    func testFootnoteReferenceRange() throws {
        // given
        let input =
        """
        Here is a footnote reference,[^1] and another.[^longnote] and some more [^alpha bravo]

        [^1]: Here is the footnote.
        [^longnote]: Here's one with multiple blocks.
        """

        // when
        let tree = try Parser().parse(text: input)
        let paragraph = tree.children.first as? Paragraph
        let node = paragraph?.children[1] as? FootnoteReference
        let node2 = paragraph?.children[3] as? FootnoteReference
        let range = input.range(29...32)
        let range2 = input.range(46...56)

        // then
        XCTAssertEqual(node?.position.range, range)
        XCTAssertEqual(input[range], "[^1]")
        XCTAssertEqual(node2?.position.range, range2)
        XCTAssertEqual(input[range2], "[^longnote]")
    }

    func testHTMLInlineRange() throws {
        // given
        let input = "<del>*foo*</del>"

        // when
        let tree = try Parser().parse(text: input)
        let paragraph = tree.children.first as? Paragraph
        let tag1 = paragraph?.children[0] as? HTML
        let tag2 = paragraph?.children[2] as? HTML
        let range = input.range(0...4)
        let range2 = input.range(10...15)

        // then
        XCTAssertEqual(tag1?.position.range, range)
        XCTAssertEqual(input[range], "<del>")
        XCTAssertEqual(tag2?.position.range, range2)
        XCTAssertEqual(input[range2], "</del>")
    }
}
