#! /bin/sh

set -e

HERE=`dirname $0`;
CONTENT=`cat "${HERE}/build.manifest"`
MANIFEST="${HERE}/manifest.json"
RE='^\s*"version"\s*:\s*"\([0-9\.]\+\(-\?\w\+\)\?\)"\s*,\s*$'

VERSION=`grep "$RE" "${MANIFEST}" | sed -e "s|$RE|\1|g"`
STEMP=`date +"%H%m-%d%m%y"`

if [ ! -z "$VERSION" ]; then
  XPI="usbmailaction-${VERSION}${STEMP}.xpi"
else
  XPI="usbmailaction.xpi"
fi

if test -e "${XPI}"
then
	rm -f "${XPI}"
fi

XPI="`pwd`/${XPI}";

( cd $HERE;
  echo -n "build.sh: building ${XPI}... ";
  if zip -r "${XPI}" $CONTENT > /dev/null; then
    echo "done."
  else
    echo "failed."
  fi
)

cp ${XPI} /tmp/
mv -f  ${XPI} .. 

