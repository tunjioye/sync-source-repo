curl -XGET https://api.github.com/repos/$DEST_REPO/actions/workflows \
  --header "'Authorization: Bearer $ACCESS_TOKEN'" \
  --header 'Content-Type: application/json' \
  > output.json

# jq < './output.json' ".workflows[] | select(.name == \"$WORKFLOW_NAME\") | {url, html_url} | \"URL=\(.url) REF=\(.html_url)\""

export $(cat output.json | jq -r --arg WORKFLOW_NAME "$WORKFLOW_NAME" \
'select(.workflows | length > 0) | .workflows[] | select(.name == $WORKFLOW_NAME) | {url, html_url} | "URL=\(.url) REF=\(.html_url)" | sub("(?<head>REF=).*\/blob\/(?<ref>.*)\/\\.github.*";"\(.head)\(.ref)")')

echo "---"
echo "[LOG] URL & REF"
echo $URL
echo $REF

curl --location --request POST "$URL/dispatches" \
  --header "Authorization: Bearer $ACCESS_TOKEN" \
  --header 'Content-Type: application/json' \
  --data-raw "{\"ref\": \"$REF\"}"
