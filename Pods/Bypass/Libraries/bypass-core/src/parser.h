//
//  Copyright 2013 Uncodin, Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#ifndef _BYPASS_PARSER_H_
#define _BYPASS_PARSER_H_

#include <iostream>
#include <string>
#include <vector>
#include <sstream>
#include <cstdio>
#include <cstdlib>
#include <map>
#include "document.h"
#include "element.h"

extern "C" {
#include "soldout/markdown.h"
}

#include "document.h"
#include "element.h"

#define INPUT_UNIT 1024
#define OUTPUT_UNIT 64

namespace Bypass {

	/*!
     \brief A parser that converts textual markdown into a Document object.

	 The `Document` object can subsequently be interpreted in whatever way makes
	 most sense to the applicable platform based on individual needs and
	 idiosyncrasies. This object is not a "parser" proper, but is instead an
	 abstraction of the [libsoldout](http://fossil.instinctive.eu/libsoldout/index)
	 markdown parser. The Parser's primary purpose is to receive and interpret
	 callbacks from libsoldout so that a `Document` object can be effectively
	 constructed.

	 When constructing a `Document` object, there are basically two types of
	 elements that nodes in the `Document` tree can consist of:

	 - those that move the cursor downward vertically (known as block elements),
	 - and those that follow text runs horizontally (known as span elements).

	 These definitions coincide with those used in [John Gruber's Markdown
	 Syntax documentation](http://daringfireball.net/projects/markdown/syntax).

	 */
	class Parser {
	public:

		/*!
		 \brief Creates a `Parser`.
		 */
		Parser();

		/*!
	     \brief Destroys the `Parser`.
		 */
		~Parser();

		/*!
		 \brief Parses the given markdown into a `Document`.
		 \param markdown The textual representation of the markdown as a character
		                 array.
		 \return A `Document` object that represents the supplied markdown.
		 */
		Document parse(const char* markdown);

		/*!
		 \brief Parses the given markdown into a `Document`.
		 \param markdown The textual representation of the markdown as a string.
		 \return A `Document` object that represents the supplied markdown.
		 */
		Document parse(const std::string &markdown);

		/*!
		 \brief Populates the given `tokens` with the result of splitting the
		        given `text` around the given `sep`.
		 \param tokens The set of tokens produced by splitting around the `sep` character.
		 \param text The text to split.
		 \param sep A character separator.
		 */
		void split(std::vector<std::string> &tokens, const std::string &text, char sep);

		// Block Element Callbacks

		/*!
		 \brief Handles the [block code](http://daringfireball.net/projects/markdown/syntax#precode)
		 parser callback.

		 A `block code` element is a block element.

		 \param ob The designated output buffer.
		 \param text The parsed text.
		 */
		void parsedBlockCode(struct buf *ob, struct buf *text);

		/*!
		 \brief Handles the [block quote](http://daringfireball.net/projects/markdown/syntax#blockquote)
		 parser callback.

		 A `block quote` element is a block element.

		 \param ob The designated output buffer.
		 \param text The parsed text.
		 */
		void parsedBlockQuote(struct buf *ob, struct buf *text);

		/*!
		 \brief Handles the [header](http://daringfireball.net/projects/markdown/syntax#header)
		 parser callback.

		 A `header` element is a block element.

		 \param ob The designated output buffer.
		 \param text The parsed text.
		 \param level The level of the header; ie. 1-6
		 */
		void parsedHeader(struct buf *ob, struct buf *text, int level);

		/*!
		 \brief Handles the [list](http://daringfireball.net/projects/markdown/syntax#list)
		 parser callback.

		 A `list` element is a block element.

		 \param ob The designated output buffer.
		 \param text The parsed text.
		 \param flags The kind of list that has been parsed, ie. ordered, block, etc.
		 */
		void parsedList(struct buf *ob, struct buf *text, int flags);

		/*!
		 \brief Handles the `list item` parser callback.

		 A `list item` element is a block element.

		 \param ob The designated output buffer.
		 \param text The parsed text.
		 \param flags The kind of list that has been parsed, ie. ordered, block, etc.
		 */
		void parsedListItem(struct buf *ob, struct buf *text, int flags);

		/*!
		 \brief Handles the [paragraph](http://daringfireball.net/projects/markdown/syntax#p)
		 parser callback.

		 A `list item` element is a block element.

		 \param ob The designated output buffer.
		 \param text The parsed text.
		 */
		void parsedParagraph(struct buf *ob, struct buf *text);

		// Span Element Callbacks

		/*!
		 \brief Handles the [code span](http://daringfireball.net/projects/markdown/syntax#code)
		  parser callback.

		  A `list item` element is a span element.

		  \param ob The designated output buffer.
		  \param text The parsed text.
		  \return whether or not the callback was handled
		  */
		int parsedCodeSpan(struct buf *ob, struct buf *text);

		/*!
		 \brief Handles the [double emphasis](http://daringfireball.net/projects/markdown/syntax#em)
		  parser callback.

		  Text that is treated with double emphasis is emboldened. A `double
		  emphasis` element is a span element.

		  \param ob The designated output buffer.
		  \param text The parsed text.
		  \param c
		  \return whether or not the callback was handled
		  */
		int parsedDoubleEmphasis(struct buf *ob, struct buf *text, char c);

		/*!
		 \brief Handles the [emphasis](http://daringfireball.net/projects/markdown/syntax#em)
		  parser callback.

		  Text that is treated with emphasis is italicized. An `emphasis` element
		  is a span element.

		  \param ob The designated output buffer.
		  \param text The parsed text.
		  \param c
		  \return whether or not the callback was handled
		  */
		int parsedEmphasis(struct buf *ob, struct buf *text, char c);

		/*!
		 \brief Handles the [triple emphasis](http://daringfireball.net/projects/markdown/syntax#em)
		  parser callback.

		  Text that is treated with triple emphasis is both italicized and emboldened.
		  A `triple emphasis` element is a span element.

		  \param ob The designated output buffer.
		  \param text The parsed text.
		  \param c
		  \return whether or not the callback was handled
		  */
		int parsedTripleEmphasis(struct buf *ob, struct buf *text, char c);

		/*!
		 \brief Handles an explicit [line break](http://daringfireball.net/projects/markdown/syntax#p)
		  parser callback.

		  A `line break` element is similar to a span element in the it can be a
		  sibling to other span elements, but it's also like a block element in
		  that it adds vertical space.

		  \param ob The designated output buffer.
		  \return whether or not the callback was handled
		  */
		int parsedLinebreak(struct buf *ob);

		/*!
		 \brief Handles a [link](http://daringfireball.net/projects/markdown/syntax#link)
		  parser callback.

		  A `link` element is a span element.

		  Note that there is no special treatment for inline links like
		  `http://www.google.com`. You must explicitly demarcate links with one
		  of the approaches outlined in the link above.

		  \param ob The designated output buffer.
		  \param link The URL for the link.
		  \param title The title of the link.
		  \param content The content of the link.
		  \return whether or not the callback was handled
		  */
		int parsedLink(struct buf *ob, struct buf *link, struct buf *title, struct buf *content);

		// Low Level Callbacks

		/*!
		 \brief Handles the event of normal text being extracted.

		 Normal text is given its own span element in a `Document` and can be a
		 sibling to other span elements. For example, the following markdown...

		     Hello, *my* name is Damian.

		 ...would produce a `text`, `emphasis`, and another `text` element that
		 were children of a `paragraph` element.

		  \param ob The designated output buffer.
		  \param text The text.
		 */
		void parsedNormalText(struct buf *ob, struct buf *text);

		// Debugging

		void printBuf(struct buf *b);

	private:
		Document document;
		std::map<int, Element> elementSoup;
		int elementCount;
		void handleBlock(Type, struct buf *ob, struct buf *text, int extra = -1);
		void handleSpan(Type, struct buf *ob, struct buf *text, struct buf *extra = NULL, struct buf *extra2 = NULL, bool output = true);
		void createSpan(const Element&, struct buf *ob);
		void eraseTrailingControlCharacters(const std::string& controlCharacters);
	};

}

#endif // _BYPASS_PARSER_H_
