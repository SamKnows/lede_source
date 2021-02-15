#!/bin/sh

. /etc/unit_specific

quit() {
    led_set_preparing
    reboot -n -f
    exit 1
}

led_set_downloading

MAC=$(cat /sys/class/net/eth0/address | sed 's/://g' | tr [a-f] [A-F])
VERSION=$(uclient-fetch -q --timeout 20 -O - "http://dcs-global.samknows.com/firmware?mac=${MAC}&model=${UNIT_MODEL}")
if [ $? -ne 0 -o -z "${VERSION}" ]; then
    quit
fi

MD5SUM=$(uclient-fetch -q --timeout 30 -O - "http://dcs-global.samknows.com/upgrade/${UNIT_MODEL}/${VERSION}.md5sum")
if [ $? -ne 0 -o -z "${MD5SUM}" ]; then
    echo "Download md5 sum of firmware failed"
    quit
fi

# Retrive the firmware
uclient-fetch -q --timeout 600 -O /tmp/firmware.bin "http://dcs-global.samknows.com/upgrade/${UNIT_MODEL}/${VERSION}.bin"
if [ $? -ne 0 ]; then
    echo "Download firmware failed"
    quit
fi

FIRMWARESIZE=$(stat -c '%s' /tmp/firmware.bin)

FIRMWARESUM=$(md5sum /tmp/firmware.bin | cut -d " " -f 1)
if [ $? -ne 0 -o -z "${FIRMWARESUM}" ]; then
    quit
fi

echo "Downloaded firmware md5sum ${FIRMWARESUM}, correct md5sum ${MD5SUM}"
if [ "$FIRMWARESUM" = "$MD5SUM" ]; then
    led_set_flashing
    mtd write /tmp/firmware.bin mainimage
    WRITTENSUM=$(head -c $FIRMWARESIZE /dev/mtdblock3 | md5sum | cut -d " " -f 1)
    if [ "$WRITTENSUM" = $MD5SUM ]; then
        uclient-fetch -q --timeout 10 "http://dcs-global.samknows.com/firmware_upgrade_success?mac=${MAC}&model=${UNIT_MODEL}&newversion=${VERSION}"
        fw_setenv bootcount 0
        reboot -n -f
    fi
fi

qui
