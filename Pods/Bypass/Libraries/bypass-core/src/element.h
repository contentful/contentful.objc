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

#ifndef _BYPASS_ELEMENT_H_
#define _BYPASS_ELEMENT_H_

#include <string>
#include <vector>
#include <map>
#include <iostream>
#include <set>

namespace Bypass {

	enum Type {

		// Block Element Types

		BLOCK_CODE      = 0x000,
		BLOCK_QUOTE     = 0x001,
		BLOCK_HTML      = 0x002,
		HEADER          = 0x003,
		HRULE           = 0x004,
		LIST            = 0x005,
		LIST_ITEM       = 0x006,
		PARAGRAPH       = 0x007,
		TABLE           = 0x008,
		TABLE_CELL      = 0x009,
		TABLE_ROW       = 0x00A,

		// Span Element Types

		AUTOLINK        = 0x10B,
		CODE_SPAN       = 0x10C,
		DOUBLE_EMPHASIS = 0x10D,
		EMPHASIS        = 0x10E,
		IMAGE           = 0x10F,
		LINEBREAK       = 0x110,
		LINK            = 0x111,
		RAW_HTML_TAG    = 0x112,
		TRIPLE_EMPHASIS = 0x113,
		TEXT            = 0x114,
		STRIKETHROUGH   = 0x115
	};

	/*!
	 \brief An object that describes some portion of a markdown document.

	 The portion of the markdown that it represents depends on what the given
	 text is surrounded with. For example, `*this*` would produce an emphasized
	 word that would in turn be rendered in italics.

	 */
	class Element {
	public:

		/*!
		 \brief The type of a collection of attributes; essentially a collection of
		        name-value pairs.
		 */
		typedef std::map<std::string, std::string> AttributeMap;

		/*!
		 \brief Creates a new `Element`.
		 */
		Element();

		/*!
		 \brief Destroys the `Element`.
		 */
		~Element();

		std::string text;

		/*!
		 \brief Sets the text for this `Element`.
		 \param text The actual text to set for this `Element`.
		 */
		void setText(const std::string& text);

		/*!
		 \brief Returns the text of this `element`.
		 */
		const std::string& getText();

		/*!
		 \brief Adds an attribute to this `Element`.

		 The term "attribute" was intentionally borrowed from the world of HTML,
		 even though the resultant `Document` will not be rendered as HTML. This
		 was done so that a unified language could be succinctly defined and
		 easily understood.

		 \param name The name or LHS of the attribute.
		 \param value The value of RHS of the attribute.
		 */
		void addAttribute(const std::string& name, const std::string& value);

		/*!
		 \brief Gets an attribute by name.
		 \param name The name of the attribute to return.
		 \return The value of the named attribute.
		 */
		std::string getAttribute(const std::string& name);

		/*!
		 \brief Gets an iterator pointing to the first attribute.
		 */
		AttributeMap::iterator attrBegin();

		/*!
    	 \brief Gets an iterator pointing to the last attributr.
		 */
		AttributeMap::iterator attrEnd();

		/*!
 		 \brief gets the number of attributes.
		 */
		size_t attrSize() const;

		/*!
		 \brief Appends a block element to this element.
		 \param blockElement The block element to nest within this element.
		 */
		void append(const Element& blockElement);

		/*!
		 \brief Gets a child `Element` of this `Element`.
		 \param i The index of the child to retrieve.
		 \return The child.
		 */
		Element getChild(size_t i);

		/*!
		 \brief Gets a child `Element` of this `Element`.
		 \param i The index of the child to retrieve.
		 \return The child.
		 */
		Element operator[](size_t i);

		/*!
		 \brief Sets the type of this `Dlement`.
		 \param type The type of this `Element`.
		 */
		void setType(Type type);

		/*!
		 \brief Gets the type of this element.
		 \return The `Type` of this element.
		 */
		Type getType();

		/*!
		 \brief Indicates whether or not this element is a block element.
		 */
		bool isBlockElement();

		/*!
		 \brief Indicates whether or not this element is a span element.
		 */
		bool isSpanElement();

		/*!
		 \brief The number of children this particular `Element` has.
		 */
		size_t size();
		friend std::ostream& operator<<(std::ostream& out, const Element& element);
	private:
		AttributeMap attributes;
		std::vector<Element> children;
		Type type;
	};

}

#endif // _BYPASS_ELEMENT_H_
