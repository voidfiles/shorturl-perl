#! /bin/bash
rm -fR build;
mkdir build;
cp -fR cpanfile build/;
cp -fR cpanfile.snapshot build/;
cp -fR short.pl build/;
cp -fR local build/;
rm -fR build/local/bin;
rm -fR build/local/lib;
cp -fR Shorturl build/;
cp -fR app.psgi build/;
cp -fR t build/;
export BUILD_TAG=`date "+%Y%m%d%H%M%S"`
export BUILD_TAG="shorturl-$BUILD_TAG"
mv build $BUILD_TAG;
time tar -cf "$BUILD_TAG.tar.gz" "$BUILD_TAG";
mv $BUILD_TAG build;
scp  -o StrictHostKeyChecking=no $BUILD_TAG.tar.gz root@192.241.228.197:/srv/shorturl/builds/
ssh -o StrictHostKeyChecking=no root@192.241.228.197 'bash -s' <<SCRIPT
set -ax;
cd /srv/shorturl/builds/;
tar xf $BUILD_TAG.tar.gz;
ln -sf $BUILD_TAG current;
cd current;
carton install --deployment --cached;
/usr/bin/supervisorctl restart shorturl;
SCRIPT

