PR_FILE=pr.json

echo "[LOG] Clone source repo"
git clone https://x-access-token:${{ secrets.ACCESS_TOKEN }}@github.com/${{ $GITHUB_REPOSITORY }}.git temp && cd temp

echo "[LOG] Extract Pull Request paramaters from {{ github.issue.pull_request.url }}"
  curl -XGET https://api.github.com/repos/tunjioye/sync-source-repo/pulls/14 \
    --header "Authorization: Bearer $ACCESS_TOKEN" \
    --header 'Content-Type: application/json' \
    > $PR_FILE

if test -f "$PR_FILE"; then
  export $(cat $PR_FILE | jq -r --arg WORKFLOW_NAME "$WORKFLOW_NAME" \
  'select(.workflows | length > 0) | .workflows[] | select(.name == $WORKFLOW_NAME) | {url, html_url} | "HEAD_REF=\(.url) BASE_REF=\(.html_url)"')

  echo "---"
  echo "[LOG] HEAD_REF & BASE_REF"
  echo $HEAD_REF
  echo $BASE_REF

  # echo "[LOG] Setup global config"
  # git config --global user.email "${{ secrets.USER_EMAIL }}"
  # git config --global user.name "${{ secrets.USER_NAME }}"

  # echo "[LOG] Switch to head_ref branch"
  # git switch ${{ github.event.pull_request.head.ref }}

  # echo "[LOG] Switch to base_ref branch"
  # git switch ${{ github.event.pull_request.base.ref }}

  # echo "[LOG] Locally Merge head_ref branch to base_ref branch with --no-commit --ff-only flag"
  # git merge ${{ github.event.pull_request.head.ref }} --no-commit --ff-only

  # echo "[LOG] Update remote origin repo"
  # git remote set-url origin https://x-access-token:${{ secrets.ACCESS_TOKEN }}@github.com/${{ github.repository }}.git

  # echo "[LOG] Force push base_ref branch to origin"
  # git push origin ${{ github.event.pull_request.base.ref }} -f

  echo "[LOG] Remove folder / Clean up"
  cd .. && rm -rf temp

else
  echo "$PR_FILE does not exist."
  exit 1
fi
