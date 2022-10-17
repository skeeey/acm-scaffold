#!/bin/bash
CURRENT_DIR="$(dirname "${BASH_SOURCE[0]}")"
PARENT_DIR="$(cd ../${CURRENT_DIR} && pwd)"
DEMO_DIR="$(cd ${CURRENT_DIR} && pwd)"

${DEMO_DIR}/patch_klusterlet.sh
${DEMO_DIR}/patch_addons.sh
${DEMO_DIR}/patch_appliedmanifestworks.sh
