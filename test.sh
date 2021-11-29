OUTPUT_FILE=output.json
FINAL_OUTPUT_FILE=finaloutput.json

curl -XGET https://api.github.com/repos/$DEST_REPO/actions/workflows \
  --header "Authorization: Bearer $ACCESS_TOKEN" \
  --header 'Content-Type: application/json' \
  > $OUTPUT_FILE

# jq < './output.json' ".workflows[] | select(.name == \"$WORKFLOW_NAME\") | {url, html_url} | \"URL=\(.url) REF=\(.html_url)\""

if test -f "$OUTPUT_FILE"; then
  export $(cat $OUTPUT_FILE | jq -r --arg WORKFLOW_NAME "$WORKFLOW_NAME" \
  'select(.workflows | length > 0) | .workflows[] | select(.name == $WORKFLOW_NAME) | {url, html_url} | "URL=\(.url) REF=\(.html_url)" | sub("(?<head>REF=).*\/blob\/(?<ref>.*)\/\\.github.*";"\(.head)\(.ref)")')

  curl --location --request POST "$URL/dispatches" \
    --header "Authorization: Bearer $ACCESS_TOKEN" \
    --header 'Content-Type: application/json' \
    --data-raw "{\"ref\": \"$REF\"}" \
    > $FINAL_OUTPUT_FILE


  if test -f "$FINAL_OUTPUT_FILE"; then
    MESSAGE=$(jq < $FINAL_OUTPUT_FILE '.message')

    # checks if $FINAL_OUTPUT_FILE .message field is empty
    if test -z "$MESSAGE"; then
      echo "SUCCESS running workflow."
      exit 0
    else
      echo "FAILED to trigger workflow."
      echo "Error Message => $MESSAGE"
      cat $FINAL_OUTPUT_FILE
      exit 1
    fi

  else
    echo "$FINAL_OUTPUT_FILE does not exist."
    exit 1
  fi

else
  echo "$OUTPUT_FILE does not exist."
  exit 1
fi
