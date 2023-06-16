echo "----Configuring Proxy"

cp /etc/yum.conf /tmp/yum.conf
cp /etc/profile /tmp/profile
cp /etc/environment /tmp/environment 

echo "proxy=http://${Proxy_URL}:${Proxy_Port}/" >> /tmp/yum.conf
echo "http_proxy=http://${Proxy_URL}:${Proxy_Port}/" >> /tmp/profile
echo "https_proxy=http://${Proxy_URL}:${Proxy_Port}/" >> /tmp/profile
echo "http_proxy=http://${Proxy_URL}:${Proxy_Port}/" >> /tmp/environment
echo "https_proxy=http://${Proxy_URL}:${Proxy_Port}/" >> /tmp/environment
echo "HTTP_PROXY=http://${Proxy_URL}:${Proxy_Port}/" >> /tmp/environment
echo "HTTPS_PROXY=http://${Proxy_URL}:${Proxy_Port}/" >> /tmp/environment
echo "no_proxy=${proxy_exclusions}" >> /tmp/environment

sudo mv /tmp/yum.conf /etc/yum.conf
echo "----yum.conf"
sudo cat /etc/yum.conf
sudo mv /tmp/profile /etc/profile
echo "----profile"
sudo tail /etc/profile
sudo mv /tmp/environment /etc/environment
echo "----environment"
sudo cat /etc/environment

# cp  /etc/rhsm/rhsm.conf /tmp/rhsm.conf
# sed -i -e 's/^proxy_hostname =/& ${Proxy_URL}/' -e 's/^proxy_port =/& ${Proxy_Port}/' /tmp/rhsm.conf
# sudo mv /tmp/rhsm.conf /etc/rhsm/rhsm.conf

echo "setenv http_proxy http://${Proxy_URL}:${Proxy_Port}/" > /tmp/http_proxy.csh
echo "export http_proxy=http://${Proxy_URL}:${Proxy_Port}/" >> /tmp/http_proxy.sh
echo "export https_proxy=http://${Proxy_URL}:${Proxy_Port}/" >> /tmp/http_proxy.sh
echo "export ftp_proxy=http://${Proxy_URL}:${Proxy_Port}/" >> /tmp/http_proxy.sh
echo "export no_proxy=${proxy_exclusions}" >> /tmp/http_proxy.sh
sudo mv /tmp/http_proxy.csh /etc/profile.d/http_proxy.csh
sudo mv /tmp/http_proxy.sh /etc/profile.d/http_proxy.sh