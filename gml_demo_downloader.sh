#!/bin/bash
# 
# GML Demo Tools (Mac)
#
# This script downloads the latest GML tag from 000000book.com
# then uses AppleScript to refresh 3 applications:
#
# - Graffiti Analysis
# - Safari (for canvasplayer, TokiWoki player or others)
# - Firefox4 (for the WebGL GML demo)
# 

FREQUENCY="2" # seconds

GA_DIR="/Applications/graffiti_analysis"
DIR="$GA_DIR/data/tags"
TAG="latest"
URL="http://000000book.com/data/$TAG"

# Check if the latest tag has differed
XML="$DIR/$TAG/$TAG.xml"
XML_TEMP="$XML-temp"
GML="$DIR/$TAG/$TAG.gml"

while [ 1 ]; do
  
  # Download the latest GML 
  # Include our nodename+OS version as a unique-ish useragent
  curl --user-agent "gml_demo 0.7/#{`uname -mnrs`}" --silent "$URL.xml" > "$XML_TEMP"

  # If so, download the latest & fire our "restart world" osascripts
  if [ ! -e "$XML" ] || ! diff "$XML_TEMP" "$XML" >/dev/null; then

    echo "Downloading latest.gml ..."
    rm -f "$XML"
    mv "$XML_TEMP" "$XML"
    curl --silent "$URL.gml" > "$GML"
    echo "Restarting demo applications ..."

    # Graffiti Analysis
    echo "* Graffiti Analysis..."
    PID=$(ps aux | grep [o]penFrameworksDebug | awk '{ print $2 }')
    [ ! -z $PID ] && kill -0 $PID && kill $PID || echo "GA not running..."
    sleep 1 # ...
    open "$GA_DIR/openFrameworksDebug.app"

    # Safari
    echo "* Safari..."
    osascript <<END
      tell application "Safari"
        activate
        tell application "System Events" to keystroke "r" using command down
      end tell
END

    # Firefox
    echo "* Firefox4..."
    osascript <<END
      tell application "Firefox4"
        activate
        tell application "System Events" to keystroke "r" using command down
      end tell
END

  else
    echo "http://000000book.com/latest.gml - nothing to see here - sleeping for $FREQUENCY seconds..."
    sleep $FREQUENCY
  fi
done

exit 0
