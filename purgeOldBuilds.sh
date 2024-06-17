#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <subscription_code> <api_key>"
    exit 1
fi

SUBSCRIPTION_CODE="$1"
API_KEY="$2"
API_URL="https://portalapi.commerce.ondemand.com/v2/subscriptions/${SUBSCRIPTION_CODE}/builds?\$top=100"

if [[ "$OSTYPE" == "darwin"* ]]; then
    THREE_MONTHS_AGO=$(date -v-3m +%s)
else
    THREE_MONTHS_AGO=$(date --date="3 months ago" +%s)
fi

response=$(curl -s -X GET "$API_URL" \
    -H "Accept: application/json" \
    -H "Authorization: Bearer ${API_KEY}")

builds=$(echo "$response" | jq '.value')

if [ $? -ne 0 ]; then
    echo "Failed to parse response with jq"
    echo "Response: $response"
    exit 1
fi

for build in $(echo "${builds}" | jq -r '.[] | @base64'); do
    _jq() {
        echo ${build} | base64 --decode | jq -r ${1}
    }

    build_end_timestamp=$(_jq '.buildEndTimestamp')
    build_code=$(_jq '.code')

    build_end_timestamp=$(echo "${build_end_timestamp}" | sed -e 's/Z$//' -e 's/\.[0-9]*//')

    if [[ "$OSTYPE" == "darwin"* ]]; then
        build_end_seconds=$(date -j -f "%Y-%m-%dT%H:%M:%S" "${build_end_timestamp}" +%s 2>/dev/null)
    else
        build_end_seconds=$(date -d "${build_end_timestamp}" +%s 2>/dev/null)
    fi

    if [ -n "${build_end_seconds}" ] && [ "${build_end_seconds}" -lt "${THREE_MONTHS_AGO}" ]; then
        echo "Build with code: ${build_code} is older than 3 months. Deleting..."
        DELETE_URL="https://portalapi.commerce.ondemand.com/v2/subscriptions/${SUBSCRIPTION_CODE}/builds/${build_code}"
        curl -s -X DELETE "$DELETE_URL" \
            -H "Accept: application/json" \
            -H "Authorization: Bearer ${API_KEY}"
        echo "Deleted build with code: ${build_code}"
    fi
done
