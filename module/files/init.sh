#!/bin/sh
DATA_DISK=${data_disk}
WAL_DATA_DISK=${wal_data_disk}
META_DATA_DISK=${meta_data_disk}
DEVICE=$(lsblk | grep nvme* | awk 'FNR>=3 {print "/dev/" $1}')
DATABASE=${data_base}
DURATION=${duration}
DEBUG_DURATION=${debug_duration}

# ---------------------------------------------------------------------------------------------------------------------
# Set OS Buffer
# ---------------------------------------------------------------------------------------------------------------------
echo "Setting OS Buffer"
echo ${read_buffer} >> /etc/sysctl.conf
sudo sysctl -w net.core.rmem_max=${read_buffer}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE DIRECTORIES
# ---------------------------------------------------------------------------------------------------------------------
echo "Creating directories for data, wal and meta directories"
sudo mkdir -p  /var/lib/influxdb/{data,wal,meta}

# ---------------------------------------------------------------------------------------------------------------------
# MOUNT ATTACHED DISKS AND CHANGE OWNERSHIP TO INFLUXDB USER
# ---------------------------------------------------------------------------------------------------------------------
echo "Checking NVME's to find correct data, wal and meta volumes."
echo "Checking for Data Volume"
for d in $DEVICE
do
if sudo nvme id-ctrl -v $d | grep $DATA_DISK;
  then
    if sudo file -s $d | grep XFS;
      then
        echo "Mount Data Device"
        mount $d /var/lib/influxdb/data
      else
        echo "Creating file system for data directories"
        sudo mkfs -t xfs $d
        echo "Mount Data Device"
        mount $d /var/lib/influxdb/data
    fi
  else
    echo "Could not mount Data Device"
fi
done || exit 1

echo "Checking for WAL Data Volume"
for d in $DEVICE
do
if sudo nvme id-ctrl -v $d | grep $WAL_DATA_DISK;
  then
    if sudo file -s $d | grep XFS;
      then
        echo "Mount WAL Data Device"
        mount $d /var/lib/influxdb/wal
      else
        echo "Creating file system for wal directories"
        sudo mkfs -t xfs $d
        echo "Mount WAL Data Device"
        mount $d /var/lib/influxdb/wal
    fi
  else
    echo "Could not mount WAL device"
fi
done || exit 1

echo "Checking for Meta Data Volume"
for d in $DEVICE
do
if sudo nvme id-ctrl -v $d | grep $META_DATA_DISK;
  then
    if sudo file -s $d | grep XFS;
      then
        echo "Mount Meta Data Device"
        mount $d /var/lib/influxdb/meta
      else
        echo "Creating file system for meta directories"
        sudo mkfs -t xfs $d
        echo "Mount Meta Data Device"
        mount $d /var/lib/influxdb/meta
    fi
  else
    echo "Could not mount Meta Data device"
fi
done || exit 1

echo "Change ownership of mounted volumes to influx"
sudo chown -R influxdb:influxdb /var/lib/influxdb

# ---------------------------------------------------------------------------------------------------------------------
# Create Self Signed Cert for last mile encryption
# ---------------------------------------------------------------------------------------------------------------------
echo "Create Self Signed Certs for Encryption"
echo "Generating SSL for $(uname -n)"
commonname=$(uname -n)
country=US
state=NY
locality=NYC
organization=RandomNYC
organizationalunit=RandomNYCOrg
email=RandomNYC@abc.com
password=$(openssl rand -base64 32)

#Generate a key
openssl genrsa -des3 -passout pass:$password -out /etc/ssl/influxdb-selfsigned.key 2048 -noout

#Remove passphrase from the key. Comment the line out to keep the passphrase
echo "Removing passphrase from key"
openssl rsa -in /etc/ssl/influxdb-selfsigned.key -passin pass:$password -out /etc/ssl/influxdb-selfsigned.key

#Create the request
echo "Creating CSR"
openssl req -new -key /etc/ssl/influxdb-selfsigned.key -out /etc/ssl/influxdb-selfsigned.csr -passin pass:$password \
    -subj "/C=$country/ST=$state/L=$locality/O=$organization/OU=$organizationalunit/CN=$commonname/emailAddress=$email"

#Create Cert
echo "Creating Cert"
openssl x509 -req -days 365 -in /etc/ssl/influxdb-selfsigned.csr -signkey /etc/ssl/influxdb-selfsigned.key -out /etc/ssl/influxdb-selfsigned.crt

# Clean up CSR
echo "Clean up CSR"
sudo rm -rf /etc/ssl/influxdb-selfsigned.csr

#Set permissions
echo "Setting Permissions"
sudo chmod 0400 /etc/ssl/influxdb-selfsigned.*
sudo chown influxdb:influxdb /etc/ssl/influxdb-selfsigned.*

# ---------------------------------------------------------------------------------------------------------------------
# RUN INFLUXDB WITH CONFIG FILE
# ---------------------------------------------------------------------------------------------------------------------
echo "Configure UDP settings"
echo "  batch-size = ${batch_size}" >> /etc/influxdb/influxdb.conf
echo "  batch-pending = ${batch_pending}" >> /etc/influxdb/influxdb.conf
echo "  batch-timeout = \"${batch_timeout}\"" >> /etc/influxdb/influxdb.conf
echo "  read-buffer = ${read_buffer}" >> /etc/influxdb/influxdb.conf
echo "  database = \"${data_base}\"" >> /etc/influxdb/influxdb.conf

echo -ne "Add performance variables... "
echo "  max-series-per-database = 0" /etc/influxdb/influxdb.conf
echo "  max-values-per-tag = 0" /etc/influxdb/influxdb.conf
echo "OK"

# ---------------------------------------------------------------------------------------------------------------------
# RUN INFLUXDB WITH CONFIG FILE
# ---------------------------------------------------------------------------------------------------------------------
echo "Starting InfluxDB Service"
sudo systemctl restart influxdb.service

echo "Enable Influxdb on OS Boot"
sudo systemctl enable influxdb

echo "Providing Config file to InfluxDB"
influxd -config /etc/influxdb/influxdb.conf

# ---------------------------------------------------------------------------------------------------------------------
# Create Databases
# ---------------------------------------------------------------------------------------------------------------------
echo -ne "Creating Database $DATABASE... "
sudo influx -execute "CREATE DATABASE $DATABASE WITH DURATION $DURATION" -ssl -unsafeSsl 

echo -ne "Create Debug Database debug$DATABASE"
sudo influx -execute "CREATE DATABASE debug$DATABASE WITH DURATION $DEBUG_DURATION" -ssl -unsafeSsl 
