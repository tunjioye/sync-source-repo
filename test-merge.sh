PR_FILE=pr.json

echo "[LOG] Clone source repo"
git clone https://x-access-token:${{ secrets.ACCESS_TOKEN }}@github.com/${{ $GITHUB_REPOSITORY }}.git temp && cd temp

echo "[LOG] Extract Pull Request paramaters from {{ github.issue.pull_request.url }}"
  curl -XGET https://api.github.com/repos/tunjioye/sync-source-repo/pulls/14 \
    --header "Authorization: Bearer $ACCESS_TOKEN" \
    --header 'Content-Type: application/json' \
    > $PR_FILE

if test -f "$PR_FILE"; then
  export $(cat $PR_FILE | jq -r '"BASE_REF=\(.base.ref) HEAD_REF=\(.head.ref)"')

  echo "---"
  echo "[LOG] HEAD_REF & BASE_REF"
  echo $HEAD_REF
  echo $BASE_REF

  echo "[LOG] Remove folder / Clean up"
  cd .. && rm -rf temp

else
  echo "$PR_FILE does not exist."
  exit 1
fi
