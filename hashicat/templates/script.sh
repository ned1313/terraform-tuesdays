usage() { echo "Usage: $0 -c CONTENT_DIRECTORY -o ORG_NAME -w WORKSPACE_NAME" 1>&2; exit 1; }

while getopts c:o:w: opt; do
    case $opt in
      c)
        CONTENT_DIRECTORY=${OPTARG};;
      o)
        ORG_NAME=${OPTARG};;
      w)
        WORKSPACE_NAME=${OPTARG};;
      *)
        usage;;
    esac
done
shift $((OPTIND-1))

if [ -z "$CONTENT_DIRECTORY" ] || [ -z "$ORG_NAME" ] || [ -z "$WORKSPACE_NAME" ]; then
  echo "Usage: $0"
  exit 0
fi

TOKEN=$(jq -r '.credentials."app.terraform.io".token' $HOME/.terraform.d/credentials.tfrc.json)

UPLOAD_FILE_NAME="./content-$(date +%s).tar.gz"
tar -zcvf "$UPLOAD_FILE_NAME" -C "$CONTENT_DIRECTORY" .

WORKSPACE_ID="$(curl \
  --header "Authorization: Bearer $TOKEN" \
  --header "Content-Type: application/vnd.api+json" \
  https://app.terraform.io/api/v2/organizations/$ORG_NAME/workspaces/$WORKSPACE_NAME \
  | jq -r '.data.id')"

echo '{"data":{"type":"configuration-versions"}}' > ./create_config_version.json

UPLOAD_URL="$(curl \
  --header "Authorization: Bearer $TOKEN" \
  --header "Content-Type: application/vnd.api+json" \
  --request POST \
  --data @create_config_version.json \
  https://app.terraform.io/api/v2/workspaces/$WORKSPACE_ID/configuration-versions \
  | jq -r '.data.attributes."upload-url"')"

curl \
--header "Content-Type: application/octet-stream" \
--request PUT \
--data-binary @"$UPLOAD_FILE_NAME" \
$UPLOAD_URL

rm "$UPLOAD_FILE_NAME"
rm ./create_config_version.json
