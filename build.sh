# init
rm -rf themes
mkdir themes

rm -rf build
mkdir build
cd build

# merge default dark modern theme with its requirements
jq -s '
def deep_merge($val1; $val2):
  [($val1,$val2)|type] as $types
  | if $types==["object","object"] then
      reduce ([($val1,$val2)|keys[]]|unique[]) as $k ({}; 
        .[$k] = (if ($val1[$k]? and $val2[$k]?) then deep_merge($val1[$k];$val2[$k]) else ($val1[$k]// $val2[$k]) end)
      )
    elif $types==["array","array"] then $val1+$val2
    else $val2
    end;
reduce .[] as $item ({}; deep_merge(.; $item))
' \
'/Applications/Visual Studio Code.app/Contents/Resources/app/extensions/theme-defaults/themes/dark_vs.json' \
'/Applications/Visual Studio Code.app/Contents/Resources/app/extensions/theme-defaults/themes/dark_plus.json' \
'/Applications/Visual Studio Code.app/Contents/Resources/app/extensions/theme-defaults/themes/dark_modern.json' \
> merged.json

# rename and remove include key
jq '
  del(.include)
  | .name = "Darker Modern"
' merged.json > darker_modern.json

# apply theming
uv run --project ../theme-editor theme-editor init darker_modern.json
uv run --project ../theme-editor theme-editor run darker_modern.json "darken 0.05" "desaturate 0.2"

# copy output theme
cp darker_modern.json ../themes

# clean up
cd ..
rm -rf build
