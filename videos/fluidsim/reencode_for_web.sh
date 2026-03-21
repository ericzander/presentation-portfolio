#!/usr/bin/bash
# For each out<number>.mp4 (not *_web*), write out<number>_web.mp4 (yuv420p H.264 for <video>).
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR"

if ! command -v ffmpeg >/dev/null 2>&1; then
  echo "ffmpeg not found. Install it (e.g. apt install ffmpeg) and retry." >&2
  exit 1
fi

shopt -s nullglob
for in in out*.mp4; do
  [[ "$in" =~ ^out[0-9]+\.mp4$ ]] || continue

  num="${in#out}"   # 9.mp4
  num="${num%.mp4}"
  out="out${num}_web.mp4"
  tmp="out${num}_web.tmp.$$.mp4"

  echo "Re-encoding: $in -> $out"
  ffmpeg -y -hide_banner -loglevel error -stats \
    -i "$in" \
    -c:v libx264 -pix_fmt yuv420p -profile:v high -crf 20 \
    -an \
    -movflags +faststart \
    "$tmp"
  mv -f "$tmp" "$out"
  echo "Done: $out"
done

echo "All done."
