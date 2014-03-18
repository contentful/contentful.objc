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

#ifndef _BYPASS_DOCUMENT_H_
#define _BYPASS_DOCUMENT_H_

#include <vector>
#include "element.h"

namespace Bypass
{

	/*!
	 \brief An object that serves as the root of a markdown `Element` tree.
	 */
	class Document
	{
	public:
		/*!
		 \brief Creates a new `Document`.
		 */
		Document();

		/*!
		 \brief Destroys the `Document`.
		 */
		~Document();

		/*!
		 \brief Appends the given element to the tail of this document.
		 \param element The element to append to the tail.
		 */
		void append(const Element& element);

		/*!
		 \brief Allows for sequentially accessing elements in this `Document` tree.
		 \param i The index of the element to retrieve.
		 \return Element The element at the given index.
		 */
		Element operator[](size_t i);

		/*!
	     \brief Indicates the number of elements in this `Document`.
	     \return The number of elements.
		 */
		size_t size();
	private:
		std::vector<Element> elements;
	};
}

#endif // _BYPASS_DOCUMENT_H_
