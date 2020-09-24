#
# Copyright (c) 2018 by Delphix. All rights reserved.
#

##DEBUG## In Delphix debug.log
#set -x

#
# Program Name ...
#
PGM_NAME='startStagedDB.sh'

#
# Load Library ...
#
eval "${DLPX_LIBRARY_SOURCE}"
result=`hey`
log "------------------------- Start"
log "Library Loaded ... hey $result"

printParams

# These passwords contain special characters so need to wrap in single / literal quotes ...
STAGINGPASS=`echo "'"${STAGINGPASS}"'"`
log "Staging Connection: ${STAGINGCONN}"
RESULTS=$( buildConnectionString "${STAGINGCONN}" "${STAGINGPASS}" "${STAGINGPORT}" )
#log "${RESULTS}"
STAGING_CONN=`echo "${RESULTS}" | jq --raw-output ".string"`
log "Staging Connection: ${STAGING_CONN}"

#
# Process Status ...
#
log "Database Port: ${STAGINGPORT}"
RESULTS=$( portStatus "${STAGINGPORT}" )
zSTATUS=`echo "${RESULTS}" | $DLPX_BIN_JQ --raw-output ".status"`

JSON="{
  \"port\": \"${STAGINGPORT}\",
  \"processId\": \"\",
  \"processCmd\": \"${MYSQLD}\",
  \"socket\": \"${STAGINGDATADIR}/mysql.sock\",
  \"baseDir\": \"${SOURCEBASEDIR}\",
  \"dataDir\": \"${STAGINGDATADIR}/data\",
  \"myCnf\": \"${STAGINGDATADIR}/my.cnf\",
  \"serverId\": \"${STAGINGSERVERID}\",
  \"pidFile\": \"${STAGINGDATADIR}/clone.pid\",
  \"tmpDir\": \"${STAGINGDATADIR}/tmp\",
  \"logSync\": \"${LOGSYNC}\",
  \"status\": \"${zSTATUS}\"
}"

log "JSON: ${JSON}"

#
# Startup ...
#
if [[ "${zSTATUS}" != "ACTIVE" ]]
then
   log "Startup ..."
   startDatabase "${JSON}" "${STAGING_CONN}" ""
else
   log "Database is Already Started ..."
fi

#log "Environment: "
#export DLPX_LIBRARY_SOURCE=""
#export REPLICATION_PASS=""
#export STAGINGPASS=""
#env | sort  >>$DEBUG_LOG
log "------------------------- End"
exit 0
