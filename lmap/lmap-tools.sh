#!/bin/sh

set -e

OPENWRT_ROOT="$(dirname "$(readlink -f "${0}")")/../"
LMAP_BUILD_DIR="${OPENWRT_ROOT}/build_dir/lmap"

TROOT="$(find "${OPENWRT_ROOT}/build_dir/"target-*/root-* -maxdepth 0 -type d |head -n1)"
TOROOT="$(find "${OPENWRT_ROOT}/build_dir/"target-*/root.orig-* -maxdepth 0 -type d |head -n1)"
BINROOT="$(find "${OPENWRT_ROOT}/bin/targets/"*/* -maxdepth 0 -type d |head -n1)"

test -d "${TROOT}"
test -d "${TOROOT}"
test "${TROOT}" != ""
test "${TOROOT}" != ""

# Find binaries that escaped our overrides
find "${OPENWRT_ROOT}/files/bin/" "${OPENWRT_ROOT}/files/usr/bin/" "${OPENWRT_ROOT}/files/usr/sbin/" -xtype l | while read -r f; do
    f="$(basename "${f}")"
    if [ "$(find "${TROOT}" -name "${f}" -wholename "*bin*" \! -xtype l)" != "" ]; then
        echo "ERROR: '${f}' is present, but it should be missing" >&2
        exit 1
    fi
done

rm -rf "${LMAP_BUILD_DIR}/" || true
mkdir -p "${LMAP_BUILD_DIR}/"

# Copy removed files
find files/ -xtype l | while read -r f; do
    DST="${LMAP_BUILD_DIR}/$(readlink "${f}")"
    mkdir -p "$(dirname "${DST}")"
    cp -a "${TOROOT}/$(echo "${f}" | sed 's#^files/##')" "${DST}"
done

# Make sure that the /ispmon symlink is created as early as possible
mkdir -p "${LMAP_BUILD_DIR}/ispmon/runonce.d/"
cat > "${LMAP_BUILD_DIR}/ispmon/runonce.d/000-symlink_ispmon.sh" <<EOF
#!/bin/sh

if [ ! -e /ispmon ]; then
   ln -s /tmp/ispmon /ispmon
fi
EOF
chmod +x "${LMAP_BUILD_DIR}/ispmon/runonce.d/000-symlink_ispmon.sh"

# Prevent u-boot access
mkdir -p "${LMAP_BUILD_DIR}/ispmon/runonce.d/"
cat > "${LMAP_BUILD_DIR}/ispmon/runonce.d/001-bootdelay.sh" <<EOF
#!/bin/sh

if [ "\$(cat /etc/samknows/firmwareversion)" == "3" ]; then
    if [ "\$(fw_printenv -n bootdelay)" != 0 ]; then
        fw_setenv bootdelay 0
    fi
fi

EOF
chmod +x "${LMAP_BUILD_DIR}/ispmon/runonce.d/001-bootdelay.sh"

# Create tarball
tar czf "${LMAP_BUILD_DIR}/removed-tools.tgz" --owner=root --group=root -C "${LMAP_BUILD_DIR}/" ispmon
cp "${LMAP_BUILD_DIR}/removed-tools.tgz" "${BINROOT}"
