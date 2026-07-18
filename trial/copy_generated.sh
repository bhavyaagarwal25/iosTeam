#!/bin/bash
images="icecream_product dahi_product sauce_product bread_product vegetables_product"
assets_dir="/Users/bhavyaagarwal/iosTeam/trial/trial/Assets.xcassets"
work_dir="/Users/bhavyaagarwal/.gemini/antigravity-ide/brain/e3d0be91-008c-4800-bd45-603a7f1a2504"

for img in $images; do
    imageset="$assets_dir/${img}.imageset"
    mkdir -p "$imageset"
    
    # Find the latest png in work dir matching the name
    latest_png=$(ls -t $work_dir/${img}_*.png | head -1)
    
    if [ -n "$latest_png" ]; then
        cp "$latest_png" "$imageset/${img}.png"
        
        cat << JSON > "$imageset/Contents.json"
{
  "images": [
    {
      "filename": "${img}.png",
      "idiom": "universal",
      "scale": "1x"
    },
    {
      "idiom": "universal",
      "scale": "2x"
    },
    {
      "idiom": "universal",
      "scale": "3x"
    }
  ],
  "info": {
    "author": "xcode",
    "version": 1
  }
}
JSON
        echo "Copied $img"
    else
        echo "Failed to find png for $img"
    fi
done
