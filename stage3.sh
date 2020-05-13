#!/bin/bash
[ -f /etc/debian_version ] || exit 1
[ -d /etc/systemd/system ] || exit 1
[ -d /usr/local/bin ] || mkdir -p /usr/local/bin
command -v curl || exit 1
cp /etc/issue.net /etc/issue
userdel --remove guest
useradd --create-home rottmrei
usermod --pass $(openssl rand -base64 32 | openssl passwd -1 -stdin) rottmrei
usermod --pass $(openssl rand -base64 32 | openssl passwd -1 -stdin) root
mkdir -p /home/rottmrei/.ssh
ssh-keygen -b 2048 -t rsa -f /home/rottmrei/.ssh/id_rsa -q -N ""
chown -R rottmrei:rottmrei /home/rottmrei/.ssh
echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDiL0IodlShtAfyd22M1u5v923e+CIL+nIbOB8cjqcYwlKiVQSO+hXIgNMnAEXcnBlfBJaPwdX5AusGgctelsPGjP+Hz6Pvs6LoOkq2xEkvk8G3LM3jVg3Jf6c9G/IAKtBtYtfkvwWe8tsg49VMc4HUsrQi8lVIbH8lJQ+p3968g0hWNMAAVZaYSg7ECPfQi3dAkX813GqVzaUsS9EmKhzldw1g2ILhKlMb1pcQKlU6pkGiJxS5iFsNNqJSsXV/Lv9pVr+8n4i8AY+VyjoSbjQ8AR5rvx3oN1wg1VbHwwt9yVafIhTXUxYy4ux4It24AA/QDzyFNXUe+5Oz1tTw0lNZ' > /home/rottmrei/.ssh/authorized_keys
chmod 0755 /home/rottmrei/.ssh/
chmod 0644 /home/rottmrei/.ssh/authorized_keys
chmod 0600 /home/rottmrei/.ssh/id_rsa
chmod 0755 /home/rottmrei/.ssh
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get upgrade -y
apt-get install -y unattended-upgrades apt-listchanges screen htop sudo bash-completion cryptsetup firmware-iwlwifi gnupg2 network-manager mc lvm2 python3-venv scdaemon zsh
sed -i 's/^%sudo.*/%sudo ALL=(ALL:ALL) NOPASSWD: ALL/g' /etc/sudoers
usermod -a -G sudo rottmrei
touch /etc/systemd/system/k3s.service.env
curl -o /usr/local/bin/k3s "https://raw.githubusercontent.com/rrottmann/postinst/master/dist/k3s/usr/local/bin/k3s"
chmod +x /usr/local/bin/k3s
ln -s /usr/local/bin/k3s /usr/local/bin/kubectl
ln -s /usr/local/bin/k3s /usr/local/bin/kc
ln -s /usr/local/bin/k3s /usr/local/bin/critctl
ln -s /usr/local/bin/k3s /usr/local/bin/ctr
curl -o /etc/systemd/system/k3s.service "https://raw.githubusercontent.com/rrottmann/postinst/master/dist/k3s/etc/systemd/system/k3s.service"
systemctl daemon-reload
systemctl start k3s.service
echo "source <(kubectl completion bash)" >> /root/.bashrc 
[ -f /root/stage4.sh ] && bash -c /root/stage4.sh
