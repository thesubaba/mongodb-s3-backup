#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

S3PATH="s3://$S3_BUCKET_NAME/"
TIMESTAMP=`date -u +"%Y-%m-%dT%H-%M-%SZ"`
S3BACKUP=$S3PATH$TIMESTAMP.dump.gz
S3LATEST=$S3PATH"latest".dump.gz

echo "Backing up $MONGO_DATABASE"
echo "[default]" > .s3cfg
echo "access_key = $AWS_ACCESS_KEY_ID" >> .s3cfg
echo "secret_key = $AWS_SECRET_ACCESS_KEY" >> .s3cfg
echo "bucket_location = $AWS_DEFAULT_REGION" >> .s3cfg
echo "use_https = True" >> .s3cfg

aws s3 mb $S3PATH
mongodump --uri="$MONGO_URI" --gzip --archive | aws s3 cp - $S3BACKUP
aws s3 cp $S3BACKUP $S3LATEST

rm .s3cfg

echo -n "Restore: "
echo -n "aws s3 cp $S3LATEST - | mongorestore --uri="$MONGO_URI" --archive --gzip"