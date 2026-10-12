#!/usr/bin/env bash
# Render background-worker entrypoint: keep all agent state on the persistent disk,
# then run the built-in APScheduler loop (MORNING 9:00 / INTRADAY 10:30 / EOD 16:00 ET).
set -euo pipefail

DATA_DIR="${DATA_DIR:-/var/data}"
mkdir -p "$DATA_DIR"/state/logs "$DATA_DIR"/state/research "$DATA_DIR"/sessions \
         "$DATA_DIR"/journal "$DATA_DIR"/cache

# Point the repo's relative write paths at the disk.
link() {  # link <repo path> <disk path>
  if [ -e "$1" ] && [ ! -L "$1" ]; then rm -rf "$1"; fi
  mkdir -p "$(dirname "$1")"
  ln -sfn "$2" "$1"
}
link state/logs       "$DATA_DIR/state/logs"
link backtest/sessions "$DATA_DIR/sessions"
link data/journal     "$DATA_DIR/journal"
link .cache           "$DATA_DIR/cache"

export STATE_FILE_PATH="$DATA_DIR/state/portfolio.json"
export RESEARCH_DIR="$DATA_DIR/state/research"

exec python main.py --session "${SESSION_ID:-paper}"
