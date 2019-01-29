#!/bin/vbash

log() {
    if [ -z "$2" ]
    then
        printf -- "%s %s\n" "[$(date)]" "$1"
    fi
}

RUN=/opt/vyatta/sbin/vyatta-cfg-cmd-wrapper

TMPFILE=$(tempfile)
GROUP=MDL_IP_LIST

log "Fetching https://www.malwaredomainlist.com/hostslist/ip.txt"
curl https://www.malwaredomainlist.com/hostslist/ip.txt -o ${TMPFILE} &> /dev/null

log "Updating address-group ${GROUP}"

${RUN} begin
${RUN} delete firewall group address-group ${GROUP} &> /dev/null

${RUN} set firewall group address-group ${GROUP} description "MDL IP List"
for i in `cat ${TMPFILE}`; do
${RUN} set firewall group address-group ${GROUP} address ${i//[[:space:]]/}
done
${RUN} commit
log "Saving configuration..."
${RUN} save &> /dev/null
${RUN} end

rm ${TMPFILE}

log "Done"
