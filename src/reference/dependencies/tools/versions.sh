#!/bin/bash

release_info="https://www.rudder-project.org/release-info/"

versions=$(curl -s ${release_info}/rudder/versions | sort -rV)

echo "[cols=\"1,4,2,2,4\", options=\"header\"] 
|===
| |Status |First release |Latest release |Links"

for ver in ${versions}; do
  state=$(curl -s ${release_info}/rudder/versions/${ver}/release-status)
  if [ ${state} != "final" ]; then continue; fi
  minor=$(curl -s ${release_info}/rudder/versions/${ver}/release)
  minor_date=$(curl -s ${release_info}/rudder/versions/${ver}/release/${minor}/due_date)
  release_date=$(curl -s ${release_info}/rudder/versions/${ver}/release-date)
  eol_date=$(curl -s ${release_info}/rudder/versions/${ver}/eol-date)
  if [[ $eol_date =~ .*internal.* ]]; then eol_date=""; fi
  extended_support_date=$(curl -s ${release_info}/rudder/versions/${ver}/extended-support-date)
  if [[ $extended_support_date =~ .*internal.* ]]; then extended_support_date=""; fi

  is_eol=$(curl -s ${release_info}/rudder/versions/${ver}/eol)
  is_extended_support=$(curl -s ${release_info}/rudder/versions/${ver}/extended-support)
  
  [ "${is_eol}" = "True" ] && state="End of life"
  [ "${is_eol}" = "False" ] && [ "${is_extended_support}" = "True" ] && state="*Maintained (_Extended Support_)*"
  [ "${is_eol}" = "False" ] && [ "${is_extended_support}" = "False" ] && state="*Maintained*"

  if [ "${is_eol}" = "False" ] && [ ! -z $eol_date ]; then eol_notice=" +\n=> until *${eol_date}*"; else eol_notice=""; fi
  if [ "${is_extended_support}" = "False" ] && [ ! -z $extended_support_date ]; then extended_support_notice=" +\n=> until *${extended_support_date}* +\n=> _Extended Support_ afterwards"; else extended_support_notice=""; fi

  if [ "${is_eol}" = "False" ]; then pretty_ver="-> *${ver}*"; else pretty_ver="${ver}"; fi
  if [[ $ver =~ (2|3|4)\..* ]]; then doc_url="https://docs.rudder.io/history/${ver}/"; else doc_url="https://docs.rudder.io/reference/${ver}/index.html"; fi

  if [ "${is_eol}" = "False" ]; then
    nightly=" +\nnightly: https://repository.rudder.io/rpm/${ver}-nightly/[rpm] ‧ https://repository.rudder.io/apt/${ver}-nightly/[apt] ‧ https://repository.rudder.io/sources/${ver}-nightly/[sources]"
  else
    nightly=""
  fi

  printf "|${pretty_ver} |${state} ${extended_support_notice} ${eol_notice} |${release_date} |${minor_date} +\n Rudder ${minor} | https://docs.rudder.io/changelogs/${ver}/index.html[changelog] ‧ ${doc_url}[docs] +\nhttps://repository.rudder.io/rpm/${ver}/[rpm] ‧ https://repository.rudder.io/rpm/${ver}/[apt] ‧ https://repository.rudder.io/sources/${ver}/[sources]${nightly}\n"
done

echo "|==="

