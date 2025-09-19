# get_checksum_from_json() {
#   local version="$1" os="$2" arch="$3"
#   local json_url="https://go.dev/dl/?mode=json"

#   if command -v jq >/dev/null 2>&1; then
#     curl -s "$json_url" | \
#       jq -r --arg ver "go${version}" \
#             --arg file "go${version}.${os}-${arch}.tar.gz" \
#         '.[] | select(.version == $ver) | .files[] | select(.filename == $file) | .sha256' \
#       | head -n1
#   else
#     # fallback using grep if jq not installed
#     curl -s "$json_url" | tr -d '\n' | \
#       grep -oP "\"filename\":\"go${version}\.${os}-${arch}\.tar\.gz\".*?\"sha256\":\"\K[0-9a-f]{64}" \
#       | head -n1
#   fi
# }

# get_checksum_from_json "1.24.7" "linux" "amd64"
get_checksum_from_html() {
  local version="$1" os="$2" arch="$3"
  local dl_page="https://go.dev/dl/"
  local file="go${version}.${os}-${arch}.tar.gz"

  curl -s "$dl_page" | awk -v f="$file" '
    BEGIN { RS="</tr>"; FS="\n" }
    $0 ~ f {
      if (match($0, /<tt>[0-9a-f]+<\/tt>/)) {
        checksum = substr($0, RSTART+4, RLENGTH-9)
        print checksum
        exit
      }
    }'
}

echo "1"
get_checksum_from_html "1.24.7" "linux" "amd64"
echo "2"
get_checksum_from_html "1.3rc1" "windows" "amd64" # not working yet