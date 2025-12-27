#!/usr/bin/env bash

a_ws=$(hyprctl -j activeworkspace | jq '.id')
dpid=$(hyprctl -j clients | jq --arg wid "$a_ws" '.[] | select(.workspace.id == ($wid | tonumber)) | select(.class == "org.kde.dolphin") | .pid')
if [ ! -z ${dpid} ] ; then
    hyprctl dispatch closewindow pid:${dpid}
    hyprctl dispatch exec dolphin &
fi
