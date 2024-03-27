#!/bin/bash
#
# Copyright (C) 2021 Nethesis S.r.l.
# http://www.nethesis.it - info@nethesis.it
#
# This file is part of Icaro project.
#
# Icaro is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License,
# or any later version.
#
# Icaro is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with Icaro.  If not, see COPYING.
#

users_auth () {

	IFS=$'\n'
	for auth_session in $(echo $1 | jq  --compact-output '.[]'); do

		sessionid=$(echo $auth_session | jq -r '.session_id')

		#Check if the sessionid is present on the unit's current sessions list
		device_session=$(echo "$2" | grep $sessionid)
		if [ $? -eq 0 ]; then

			device_mac=$(echo $device_session | awk '{print $1}')
			auth_type=$(echo $auth_session | jq -r '.type')
			device_username=$(echo $device_session | awk '{print $6}')

			if [ "$auth_type" = "login" ]; then

				username=$(echo ${auth_session} | jq -r '.username')
				password=$(echo ${auth_session} | jq -r '.password')

				#In case of temporary session, first deauthenticate the device
				if [ "$device_username" = "temporary" ]; then
					dedalo query logout mac ${device_mac}
				fi

				#Authenticate the device
				dedalo query login mac ${device_mac} username "${username}" password "${password}"

			elif [ "$auth_type" = "temporary" ]; then

				#Check if a temporary session does not already exist
				if [ "$device_username" != "temporary" ]; then
					sessiontimeout=$(echo ${auth_session} | jq -r '.session_timeout')
					#Open a temporary session
					dedalo query authorize mac ${device_mac} username "temporary" sessiontimeout ${sessiontimeout}

				fi
			fi
		fi
done
}

while true
do
	devices_list=$(dedalo query list 2>/dev/null | grep -e dnat -e temporary)

	if [ $? -eq 0 ]; then

		. /opt/icaro/dedalo/config
		HS_DIGEST=$(echo -n "$HS_SECRET$HS_UUID" | md5sum | awk '{print $1}')

		auth_session_list_json=$(curl -L -f -s "${HS_AAA_URL}/auth?digest=${HS_DIGEST}&uuid=${HS_UUID}&secret=${HS_SECRET}")

		if [ $? -eq 0 ]; then

			users_auth  "$auth_session_list_json" "$devices_list"
		fi
	fi

	sleep 10s
done
