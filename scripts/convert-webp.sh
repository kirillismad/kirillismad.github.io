#!/usr/bin/env bash
# Использование: convert-webp.sh ORIGIN OUT SMALL_SIZE BIG_SIZE SMALL_QUALITY BIG_QUALITY
set -euo pipefail

origin=$1
out=$2
small_size=$3
big_size=$4
small_quality=$5
big_quality=$6

mkdir -p "$out/small" "$out/big"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

shopt -s nullglob nocaseglob
for f in "$origin"/*.{heic,heif,jpg,jpeg,png}; do
  name=$(basename "${f%.*}")

  for variant in small big; do
    if [ "$variant" = small ]; then
      size=$small_size; q=$small_quality
    else
      size=$big_size; q=$big_quality
    fi
    sips -s format jpeg -s formatOptions 100 -Z "$size" "$f" --out "$tmp/$name.jpg" >/dev/null
    # cwebp игнорирует EXIF-ориентацию, ffmpeg применяет её к пикселям
    ffmpeg -y -loglevel error -i "$tmp/$name.jpg" "$tmp/$name.png"
    cwebp -quiet -q "$q" -m 6 "$tmp/$name.png" -o "$out/$variant/$name.webp"
    echo "$out/$variant/$name.webp"
  done
done
