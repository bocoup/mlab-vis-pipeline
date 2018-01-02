#!/bin/bash

# Run all parts of the pipeline with a provided end date.
# options:
#    -m staging|production|sandbox: environment to use

set -e
set -x

usage() {
  echo "Usage: KEY_FILE=<path> $0 -m staging|production|sandbox" $1 1>&2; exit 1;
}

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

while getopts ":t:e:s:m:" opt; do
  case $opt in
    m)
      echo "${OPTARG} environment"
      if [[ "${OPTARG}" == production ]]; then
        source $DIR/environments/production.sh
      elif [[ "${OPTARG}" == staging ]]; then
        source $DIR/environments/staging.sh
      elif [[ "${OPTARG}" == sandbox ]]; then
        source $DIR/environments/sandbox.sh
      else
        echo "BAD ARGUMENT TO $0: ${OPTARG}"
        exit 1
      fi
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

DATAFLOW_DIR="${DIR}/dataflow"
JAR_BASEDIR="${DIR}/dataflow/target"
JAR_FILE="${JAR_BASEDIR}/mlab-vis-pipeline.jar"

echo "Project: ${PROJECT}"

# echo "moving into dir: ${DATAFLOW_DIR}"
cd ${DATAFLOW_DIR}

echo "Starting server for bigquery metrics & bigtable pipeline"
if [ -n "${KEY_FILE}" ]; then
  GOOGLE_APPLICATION_CREDENTIALS=${KEY_FILE} java -cp ${JAR_FILE} mlab.dataviz.main.BTRunner \
    --runner=com.google.cloud.dataflow.sdk.runners.DataflowPipelineRunner \
    --project=${PROJECT} --instance=${BIGTABLE_INSTANCE} \
    --stagingLocation="${STAGING_LOCATION}"
else
  java -cp ${JAR_FILE} mlab.dataviz.main.BTRunner \
    --runner=com.google.cloud.dataflow.sdk.runners.DataflowPipelineRunner \
    --project=${PROJECT} --instance=${BIGTABLE_INSTANCE} \
    --stagingLocation="${STAGING_LOCATION}"
fi

