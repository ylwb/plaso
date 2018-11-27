#!/bin/bash
#
# plaso installation script for macOS.
#
# This file is generated by l2tdevtools update-dependencies.py, any dependency
# related changes should be made in dependencies.ini.

EXIT_SUCCESS=0;
EXIT_FAILURE=1;

DEPENDENCIES="PyYAML XlsxWriter artifacts backports.lzma bencode biplist certifi chardet dateutil dfdatetime dfvfs dfwinreg dtfabric efilter elasticsearch-py elasticsearch5-py future hachoir-core hachoir-metadata hachoir-parser idna libbde libesedb libevt libevtx libewf libfsapfs libfsntfs libfvde libfwnt libfwsi liblnk libmsiecf libolecf libqcow libregf libscca libsigscan libsmdev libsmraw libvhdi libvmdk libvshadow libvslvm pefile psutil pycrypto pyparsing pysqlite python-lz4 pytsk3 pytz pyzmq requests six urllib3 yara-python";

SCRIPT_NAME=$(basename $0);
DEPENDENCIES_ONLY=0;
SHOW_HELP=0;

echo "===============================================================";
echo " plaso macOS installation script";
echo "===============================================================";

while test $# -gt 0;
do
  case $1 in
  --dependenciesonly | --dependencies-only | --dependencies_only )
    DEPENDENCIES_ONLY=1;
    shift;
    ;;

  -h | --help )
    SHOW_HELP=1;
    shift;
    ;;

  *)
    ;;
  esac
done

if test ${SHOW_HELP} -ne 0;
then
  echo "Usage: ./${SCRIPT_NAME} [--dependencies-only] [--help]";
  echo "";
  echo "  --dependencies-only: only install dependencies, not plaso.";
  echo "  --help:              shows this help.";
  echo "";
  echo "";

  exit ${EXIT_SUCCESS};
fi

if test "$USER" != "root";
then
  echo "This script requires root privileges. Running: sudo.";

  sudo echo > /dev/null;
  if test $? -ne 0;
  then
    echo "Do you have root privileges?";

    exit ${EXIT_FAILURE};
  fi
fi

VOLUME_NAME="/Volumes/plaso-@VERSION@";

if ! test -d ${VOLUME_NAME};
then
  echo "Unable to find installation volume: ${VOLUME_NAME}";

  exit ${EXIT_FAILURE};
fi

echo "Installing dependencies.";

for PACKAGE_NAME in ${DEPENDENCIES};
do
  for PACKAGE in $(find ${VOLUME_NAME} -name "${PACKAGE_NAME}-*.pkg");
  do
    FILENAME=$(basename ${PACKAGE});
    sudo installer -target / -pkg "${VOLUME_NAME}/packages/${FILENAME}";
  done
done

# If the --only-dependencies option was passed to the installer script
# the plaso package is not installed.
if test ${DEPENDENCIES_ONLY} -eq 0;
then
  echo "Installing plaso.";

  sudo installer -target / -pkg "${VOLUME_NAME}/packages/python-plaso-@VERSION@.pkg";
fi

echo "Done.";

# Check for the existence of two versions of the pyparsing module.
if test -f "/System/Library/Frameworks/Python.framework/Versions/2.7/Extras/lib/python/pyparsing.pyc";
then
  if test -f "/Library/Python/2.7/site-packages/pyparsing.py";
  then
    echo "WARNING: Detected multiple version of the pyparsing module on your system.";

    if test ${DEPENDENCIES_ONLY} -eq 0;
    then
      echo "Use the plaso tools helper scripts e.g. log2timeline.sh instead of the Python scripts: log2timeline.py";
     fi
  fi
fi

exit ${EXIT_SUCCESS};

