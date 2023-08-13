#!/usr/bin/env bash
# unofficial strict mode
# note bash<=4.3 chokes on empty arrays with set -o nounset
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
# https://sharats.me/posts/shell-script-best-practices/
set -o errexit
set -o nounset
set -o pipefail

IFS=$'\n\t'
shopt -s nullglob globstar

[[ "${TRACE:-0}" == "1" ]] && set -o xtrace

usage() {
  filename="$(basename "")"
  echo "Usage: ./${filename} <arg one> <arg two>

This is an awesome bash script to make your life better."
  exit
}

[[ "${1:-}" =~ ^-*h(elp)?$ ]] && usage

cd "$(dirname "$0")"

COUNTRY_COLUMN='Country / Dependency'
POPULATION_COLUMN='Population'
wiki-to-country-population() {
  wiki_file="${1:?missing \`wiki_file\`}"
  cat "$wiki_file" \
    | csvsql --query "SELECT \"${COUNTRY_COLUMN}\" as \"country\", CAST(\"${POPULATION_COLUMN}\" as INT) as \"population\" FROM stdin" \
    | sed 's/ (.*)"\?,/,/'
}

replace-names() {
  # 'Congo' gets replaced with 'Republic of the Congo' later lol
  sed \
    -e 's/DR Congo/Democratic Congo/' \
    -e 's/Gambia/The Gambia/' \
    -e 's/Congo/Republic of the Congo/' \
    -e 's/Micronesia/Federated States of Micronesia/' \
    -e 's/United States/United States of America/' \
    -e 's/Bahamas/The Bahamas/' \
    -e 's/Curacao/Curaçao/' \
    -e 's/US Virgin Islands/United States Virgin Islands/' \
    -e 's/Artaskh/Republic of Artsakh/' \
    -e 's/Åland/Åland Islands/'
}

# if the file is too long, the join seems to fail on the last couple, so remove
# some unused lines
remove-unused() {
  grep -v -E 'World|Sahara|Barth|Pierre|Helena|Cocos|Keeling|Pitcairn'
}

MAIN_CSV='src/data/main.csv'
wiki-join-data() {
  wiki_file="${1:?missing \`wiki_file\`}"
  wiki-to-country-population "$wiki_file" \
    | replace-names \
    | remove-unused \
    | csvstack '-' 'manual.csv' \
    | csvjoin \
      --columns 'country' \
      --left \
      "$MAIN_CSV" \
      '-'
}

main() {
  wiki-join-data "$@"
  #wiki-to-country-population "$@" | replace-names
}

main "$@"

exit 0
