#!/bin/bash


SPACE_ID="hvjkfbzcwrfn"
AUTH_HEADER="Authorization: Bearer ${CONTENTFUL_TEST_ORG_CMA_TOKEN}"

# Fetch space
curl -is "https://api.contentful.com/spaces/${SPACE_ID}" \
	--request GET \
  --header "$AUTH_HEADER" \
	> /tmp/Obj-C_CMA_Recordings/fetch-space.response



# Create empty asset
curl -is "https://api.contentful.com/spaces/$SPACE_ID/assets/" \
	--request POST \
  --header "$AUTH_HEADER" \
	--data '
{
  "fields":{}
}' \
  >  /tmp/Obj-C_CMA_Recordings/create-empty-asset.response

# Archive asset after creation
curl -is "https://api.contentful.com/spaces/hvjkfbzcwrfn/assets/3E0RuZRAEo0I2QMMO6AKQU/archived" \
  --request PUT \
  --header "$AUTH_HEADER" \
  --header "X-Contentful-Version: 3" \
  > /tmp/Obj-C_CMA_Recordings/archive-asset-after-creation.response

