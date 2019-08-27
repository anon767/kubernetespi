#!/bin/sh

echo "[KubernetesPI] Installing Docker nightly\n"
if [[ -x "$(command -v docker)" ]]; then
	echo "[KubernetesPI] docker already installed\n"
else
	curl -sSL get.docker.com | CHANNEL=nightly sh
  	sudo usermod pi -aG docker
fi

echo "[KubernetesPI] turning off swapfile - causes problems with kubernetes\n"
sudo dphys-swapfile swapoff
sudo dphys-swapfile uninstall
sudo update-rc.d dphys-swapfile remove

echo "[KubernetesPI] adding gpg for packages.cloud.google\n"
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list 

echo "[KubernetesPI] updating\n"
sudo apt-get update -q

echo "[KubernetesPI] installing kubeadm kubelet kubectl kubernetes-cns\n"
sudo apt-get install -qy kubeadm kubelet kubectl kubernetes-cns
  
echo "[KubernetesPI] Adding  cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory to /boot/cmdline.txt\n"
sudo cp /boot/cmdline.txt /boot/cmdline_backup.txt
orig="$(head -n1 /boot/cmdline.txt) cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory"
echo $orig | sudo tee /boot/cmdline.txt

echo "[KubernetesPI] Please reboot\n"
