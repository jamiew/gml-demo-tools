#!/bin/bash

SNOOZE="1"
GA_DIR="/Applications/graffiti_analysis"
DIR="$GA_DIR/data/tags"
TAG="latest"
URL="http://000000book.com/data/$TAG" # sans extension pls

# TODO -- wrap all this in a fuckin loop yo

# Check if the latest tag has differed
XML="$DIR/$TAG/$TAG.xml"
XML_TEMP="$XML-temp"
GML="$DIR/$TAG/$TAG.gml"

while [ 1 ]; do
  curl --user-agent "gml_demo 0.7/lolwut" --silent "$URL.xml" > "$XML_TEMP"

  # If so, download the latest & fire our "restart world"
  if [ ! -e "$XML" ] || ! diff "$XML_TEMP" "$XML" >/dev/null; then
    echo "Latest changed or no XML/GML! Downloading..."
    rm -f "$XML"
    mv "$XML_TEMP" "$XML"
    curl --silent "$URL.gml" > "$GML"
    echo "Restarting demo applications..."

    echo "* Graffiti Analysis"
    PID=$(ps aux | grep [o]penFrameworksDebug | awk '{ print $2 }')
    [ ! -z $PID ] && kill -0 $PID && kill $PID || echo "GA not running..."
    sleep 1 # ...
    open "$GA_DIR/openFrameworksDebug.app"

    echo "* Safari..."
    osascript <<END
      tell application "Safari"
        activate
        tell application "System Events" to keystroke "r" using command down
      end tell
END
    # sleep 1

    echo "* Firefox4..."
    osascript <<END
      tell application "Firefox4"
        activate
        tell application "System Events" to keystroke "r" using command down
      end tell
END
    # sleep 1

  else
    echo "http://000000book.com/latest.gml - nothing to see here - sleeping for $SNOOZE seconds..."
    sleep $SNOOZE
  fi
done

exit 0
