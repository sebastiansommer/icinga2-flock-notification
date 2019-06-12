#!/bin/bash

ICINGA_HOSTNAME=${1}
FLOCK_WEBHOOK_URL=${2}

NOTIFICATIONTYPE=${3}
HOSTNAME=${4}
HOSTDISPLAYNAME=${5}

SERVICEDISPLAYNAME=$(echo "${6}" | sed -e "s/\"/\\\\\"/g")
SERVICESTATE=${7}
SERVICEOUTPUT=${8}

NOTIFICATIONAUTHORNAME=${9}
NOTIFICATIONCOMMENT=${10}

#Set the message icon based on icinga2 service state
if [ "$SERVICESTATE" = "CRITICAL" ]
then
    ICON=":exclamation:"
elif [ "$SERVICESTATE" = "WARNING" ]
then
    ICON=":warning:"
elif [ "$SERVICESTATE" = "OK" ]
then
    ICON=":white_check_mark:"
elif [ "$SERVICESTATE" = "UNKNOWN" ]
then
    ICON=":question:"
else
    ICON=":white_medium_square:"
fi

#Send message to Flock
PAYLOAD="payload={\"text\": \"${ICON} ${NOTIFICATIONTYPE}: ${HOSTNAME} -> *${SERVICEDISPLAYNAME}: [ ${SERVICESTATE} ]* | ${SERVICEOUTPUT} | <https://${ICINGA_HOSTNAME}/icingaweb2/monitoring/host/services?host=${HOSTNAME}> | [ *${NOTIFICATIONAUTHORNAME}* ]: ${NOTIFICATIONCOMMENT} \"}"

echo "$PAYLOAD" >> /var/log/icinga2/flock-service-notification.log

curl --connect-timeout 30 --max-time 60 -s -S -X POST --data-urlencode "${PAYLOAD}" "${FLOCK_WEBHOOK_URL}"