#!/bin/bash

# Define the SFTP server details and the shell command
FTPHOST="192.168.178.53"
FTPUSER="pi"
FTPPASS="1"
FTPPORT="22"
SHELLSTOPCOMMAND="sudo systemctl stop flutter_pi.service"
SHELLSTARTCOMMAND="sudo systemctl start flutter_pi.service"

# Run the Flutter build command
echo "Building the Flutter project..."
flutter pub global run flutterpi_tool build --release --arch=arm64 --cpu=pi4

# Check if the build command was successful
if [ $? -ne 0 ]; then
  echo "Flutter build failed."
  exit 1
fi
echo "Flutter build successful."

# Run the shell stop command on the SFTP server
sshpass -p $FTPPASS ssh -p $FTPPORT $FTPUSER@$FTPHOST "$SHELLSTOPCOMMAND"
if [ $? -ne 0 ]; then
  echo "Could not stop the service."
  exit 1
fi
echo "Stopped the service."

# Transfer the flutter_assets directory to the SFTP server
sshpass -p $FTPPASS rsync -avz -e "ssh -p $FTPPORT" --progress ./build/flutter_assets $FTPUSER@$FTPHOST:/home/pi/ff_alarm_monitor/

# Check if the transfer was successful
if [ $? -ne 0 ]; then
  echo "File transfer failed."
  exit 1
fi
echo "File transfer successful."

# Run the shell stop command on the SFTP server
sshpass -p $FTPPASS ssh -p $FTPPORT $FTPUSER@$FTPHOST "$SHELLSTARTCOMMAND"

# Check if the shell command was successful
if [ $? -ne 0 ]; then
  echo "Could not start the service."
  exit 1
fi
echo "Started the service."
