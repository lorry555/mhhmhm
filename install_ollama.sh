#!/bin/sh
# This script installs Ollama on Linux.
# It runs the official installer, which detects the architecture, installs the
# matching release and sets up the systemd service and GPU drivers when available.

set -eu

curl -fsSL https://ollama.com/install.sh | sh
