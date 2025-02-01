#!/bin/bash

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  SELF="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$SELF/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done

MYDIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

cd $MYDIR

TMPDIR=$MYDIR/tmp
mkdir -p $TMPDIR/work

cp Dockerfile.stub $TMPDIR/Dockerfile.tmp

for d in ${MYDIR}/platforms/* ; do 
  D=$(basename ${d})
done

rm -rf $TMPDIR/mbed-cloud-client-example
cd $TMPDIR/work
git clone http://github.com/PelionIoT/mbed-cloud-client-example -b 4.13.2
cp $MYDIR/mbed-cloud-client-example-aarch64.patch $TMPDIR/work
cp $MYDIR/curl_update.patch $TMPDIR/work

# look in platforms folder, and slap all stub files into a single Dockerfile.temp
cd $MYDIR
for d in ${MYDIR}/platforms/* ; do 
  echo "platform: ${d}"
  D=$(basename ${d})
  ADDS=tmp/${D}/adds
  # this is a directory on the container image
  MYPLATFORM=/builder/${D}
  CONTAINTER_OUTPUT=/out
  mkdir -p $TMPDIR/${D}/adds
  if [ -e $MYDIR/platforms/${D}/prebuild.sh ]; then
    echo "prebuild for ${D}..."
    ADDS=${ADDS} CONTAINTER_OUTPUT=/out bash $MYDIR/platforms/${D}/prebuild.sh
  else 
    echo "No prebuild.sh for platform ${D}"
  fi
  if [ -e $MYDIR/platforms/${D}/Dockerfile.stub ]; then
  # make the generator from the template
    $MYDIR/bash-tpl $MYDIR/platforms/${D}/Dockerfile.stub > $TMPDIR/${D}/Dockerfile.stub.out
    # run generator to create final stub of Dockerfile
    MYDIR=platforms/${D} ADDS=${ADDS} CONTAINTER_OUTPUT=/out MYPLATFORM=${MYPLATFORM} bash $TMPDIR/${D}/Dockerfile.stub.out > $TMPDIR/${D}/Dockerfile.stub.final
    cat $TMPDIR/${D}/Dockerfile.stub.final >> $TMPDIR/Dockerfile.tmp
  else 
    echo "No Dockerfile.stub for platform ${D}"
  fi
done

docker build . -f $TMPDIR/Dockerfile.tmp --tag izuma-cloud-client-builder:latest

