#!/bin/bash

# Install libvirt
sudo apt-get update
sudo apt install qemu qemu-kvm libvirt-bin  bridge-utils  virt-manager libvirt-daemon-system -y

# Get the services running
sudo service libvirtd start
sudo update-rc.d libvirtd enable

# Prep the data disk for usage
echo 'type=83' | sudo sfdisk /dev/sda
sudo mkfs.ext4 /dev/sda1
sudo mkdir /vms
sudo mount /dev/sda1 /vms

# Add data disk to fstab
#first make a backup of /etc/fstab
sudo cp /etc/fstab /etc/fstab.backup
sudo bash -c 'echo "/dev/sda1 /vms ext4" >> /etc/fstab'

# At this point we might be able to use Terraform to configure libvirt and VMs
