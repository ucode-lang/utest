# Stock rootfs with libucode upgraded from the 25.12 package index. Stock images
# ship libucode 2026.01.16; every 25.12 index now serves 2026.07.09, whose regex
# engine makes ^/$ per-line and stops '.'/'[^...]' matching '\n' (upstream
# 8a8b4d12). utest must pass on both, so CI runs the meta-test on each.
ARG ROOTFS_IMAGE=openwrt/rootfs:x86-64-25.12.4
FROM ${ROOTFS_IMAGE}
# The last check asserts the behavior, not a version string, so later releases pass.
RUN mkdir -p /var/lock \
 && apk update \
 && apk upgrade libucode20230711 ucode \
 && ucode -e 'exit(match("a\nb", /^b$/) ? 0 : 1)' \
 || { echo 'libucode upgrade did not bring the per-line regex engine' >&2; exit 1; }
