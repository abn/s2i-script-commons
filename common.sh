#!/bin/bash -e
#
# Common functions and configurations for source-to-image scripts.
#
################################################################################
# Global Configuration
################################################################################
if [ -v DEBUG ]; then
  set -x
  MV_OPTS="-v"
  CP_OPTS="-v"
fi

# ensure * matches . prefixed files/directories
shopt -s dotglob

# ensure defaults for expected vars
S2I_DESTINATION=${S2I_DESTINATION:-/tmp}
OPENSHIFT_SOURCE_DIR=${OPENSHIFT_SOURCE_DIR:-/opt/source}
OPENSHIFT_DEPLOYMENT_DIR=${OPENSHIFT_DEPLOYMENT_DIR:-/opt/openshift}

# configure script variables
S2I_SOURCE=${S2I_DESTINATION}/src
S2I_ARTIFACTS=${S2I_DESTINATION}/artifacts

################################################################################
# Logging Helper Functions
################################################################################
function debug() {
  [[ -v DEBUG ]] && echo -e "[DEBUG] ${1}" >&1 || :
}

function info() {
  echo -e "[INFO] ${1}" >&1
}

function warn() {
  echo -e "[WARN] ${1}" >&2
}

function error() {
  echo -e "[ERROR] ${1}" >&2
}

function critical() {
  error ${1}
  exit 1
}

################################################################################
# Helper Functions
################################################################################
# restore any saved artifacts
function restore-artifacts() {
  [[ -d "${S2I_ARTIFACTS}" ]] && {
    info "Restoring artifacts from previous build.";
    mv ${S2I_ARTIFACTS}/* ${OPENSHIFT_SOURCE_DIR}/.;
  } || debug "No artifact directory found. Skipping restore."
}

# prepare source and saved artifacts prior to build
function prepare() {
  restore-artifacts
  info "Installing source from s2i destination (${S2I_SOURCE})."
  cp -R ${CP_OPTS} ${S2I_SOURCE}/* ${OPENSHIFT_SOURCE_DIR}/.
}

# clean prepared artifacts and source
function clean() {
  if [ ! -v SKIP_CLEAN ]; then
    info "Cleaning all artifacts at ${S2I_SOURCE} and ${OPENSHIFT_SOURCE_DIR}"
    rm -rf ${S2I_SOURCE}
    rm -rf ${OPENSHIFT_SOURCE_DIR}
  fi
}
