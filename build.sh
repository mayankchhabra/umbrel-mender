#!/bin/bash
echo "Cloning mender-convert"
git clone https://github.com/mendersoftware/mender-convert.git mender-convert

echo "Downloading mender-artifact"
wget -q https://d1b0l86ne08fsf.cloudfront.net/mender-artifact/3.3.0/linux/mender-artifact
chmod +x mender-artifact
sudo mv mender-artifact /usr/local/bin/

echo "Getting latest Umbrel OS Image"
wget -q https://github.com/getumbrel/umbrel-os/releases/download/v0.0.2-build.10/image_2020-06-08-umbr3l-lite.zip

echo "Unzipping Umbrel OS Image"
unzip image_2020-06-08-umbr3l-lite.zip

INPUT_DISK_IMAGE=$(ls *umbr3l*.img)
echo "Disk image: $INPUT_DISK_IMAGE"

cd mender-convert
mkdir -p input
mv ../$INPUT_DISK_IMAGE input/umbrel-os.img

echo "Installing mender-convert dependencies"
sudo apt install $(cat requirements-deb.txt)

echo "Bootstrapping rootfs overlay"
./scripts/bootstrap-rootfs-overlay-demo-server.sh \
    --output-dir ${PWD}/rootfs_overlay_demo \
    --server-ip 54.159.58.48

echo "Installing pxz for some unknown reason"
sudo apt-get install -y pxz

echo "Running mender-convert"
MENDER_ARTIFACT_NAME=release-1 ./mender-convert \
   --disk-image input/umbrel-os.img \
   --config configs/raspberrypi4_config \
   --config ../mender-config \
   --overlay rootfs_overlay_demo/

echo "Delete ext4 image as we don't need it"
rm deploy/*.ext4