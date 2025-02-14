 INSTALL 3 NODES ELASTICSEARCH,LOGSTASH, KIBANA and FileBeat

[elastic-install-link](https://www.elastic.co/guide/en/elasticsearch/reference/current/rpm.html)
[logstash-install-link](https://www.elastic.co/guide/en/logstash/current/installing-logstash.html)
[kibana-install-link](https://www.elastic.co/guide/en/kibana/current/install.html)
[filebeat-install-link](https://artifacthub.io/packages/helm/elastic/filebeat)


### ELASTICSEARCH

- Öncesinde Volume işlemlerini yapmamız gerekiyor

```bash
lsblk

NAME         MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
loop0          7:0    0 25.2M  1 loop /snap/amazon-ssm-agent/7993
loop1          7:1    0 55.7M  1 loop /snap/core18/2829
loop2          7:2    0   64M  1 loop /snap/core20/2379
loop3          7:3    0   87M  1 loop /snap/lxd/29351
loop4          7:4    0 38.8M  1 loop /snap/snapd/21759
nvme0n1      259:0    0   16G  0 disk 
├─nvme0n1p1  259:2    0 15.9G  0 part /
├─nvme0n1p14 259:3    0    4M  0 part 
└─nvme0n1p15 259:4    0  106M  0 part /boot/efi
nvme1n1      259:1    0   10G  0 disk 


sudo fdisk /dev/nvme1n1

Command (m for help): 

n 
p
enter
enter
enter
w
```
- böylece nvme1n1 diskini 1 partiona böldük

```bash
lsblk

NAME         MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
loop0          7:0    0 25.2M  1 loop /snap/amazon-ssm-agent/7993
loop1          7:1    0 55.7M  1 loop /snap/core18/2829
loop2          7:2    0   64M  1 loop /snap/core20/2379
loop3          7:3    0   87M  1 loop /snap/lxd/29351
loop4          7:4    0 38.8M  1 loop /snap/snapd/21759
nvme0n1      259:0    0   16G  0 disk 
├─nvme0n1p1  259:2    0 15.9G  0 part /
├─nvme0n1p14 259:3    0    4M  0 part 
└─nvme0n1p15 259:4    0  106M  0 part /boot/efi
nvme1n1      259:1    0   10G  0 disk 
└─nvme1n1p1  259:6    0   10G  0 part 
```
- burda nvme1n1p1 pariton1 ile işlem yapacağız

```bash
sudo mkfs -t ext4 /dev/nvme1n1p1

sudo mkdir -p /data

sudo mount /dev/nvme1n1p1 /data

sudo vi /etc/fstab
```

```yaml
/dev/nvme1n1p1   /data    ext4    defaults    8 2
```

```bash
lsblk

NAME         MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
loop0          7:0    0 25.2M  1 loop /snap/amazon-ssm-agent/7993
loop1          7:1    0 55.7M  1 loop /snap/core18/2829
loop2          7:2    0   64M  1 loop /snap/core20/2379
loop3          7:3    0   87M  1 loop /snap/lxd/29351
loop4          7:4    0 38.8M  1 loop /snap/snapd/21759
nvme0n1      259:0    0   16G  0 disk 
├─nvme0n1p1  259:2    0 15.9G  0 part 
├─nvme0n1p14 259:3    0    4M  0 part 
└─nvme0n1p15 259:4    0  106M  0 part /boot/efi
nvme1n1      259:1    0   10G  0 disk 
└─nvme1n1p1  259:6    0   10G  0 part /data
```

## Install Elasticsearch-1

1.  Import the Elasticsearch public GPG key to the rpm package manager.

```bash
sudo -i
rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch
```

2. Insert the following lines to the repository configuration file elasticsearch.repo:

```bash
vi /etc/yum.repos.d/elasticsearch.repo
```

```yaml
[elasticsearch]
name=Elasticsearch repository for 8.x packages
baseurl=https://artifacts.elastic.co/packages/8.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=0
autorefresh=1
type=rpm-md
```

3. Install the Elasticsearch package.

```bash
yum install --enablerepo=elasticsearch elasticsearch
```

- When the installation is complete, you will be prompted to start and enable elasticsearch:

```bash
--------------------------- Security autoconfiguration information ------------------------------

Authentication and authorization are enabled.
TLS for the transport and HTTP layers is enabled and configured.

The generated password for the elastic built-in superuser is : UiVHFXbVX5x+u*hgoIwD

If this node should join an existing cluster, you can reconfigure this with
'/usr/share/elasticsearch/bin/elasticsearch-reconfigure-node --enrollment-token <token-here>'
after creating an enrollment token on your existing cluster.

You can complete the following actions at any time:

Reset the password of the elastic built-in superuser with 
'/usr/share/elasticsearch/bin/elasticsearch-reset-password -u elastic'.

Generate an enrollment token for Kibana instances with 
 '/usr/share/elasticsearch/bin/elasticsearch-create-enrollment-token -s kibana'.

Generate an enrollment token for Elasticsearch nodes with 
'/usr/share/elasticsearch/bin/elasticsearch-create-enrollment-token -s node'.

-------------------------------------------------------------------------------------------------
### NOT starting on installation, please execute the following statements to configure elasticsearch service to start automatically using systemd
 sudo systemctl daemon-reload
 sudo systemctl enable elasticsearch.service
### You can start elasticsearch service by executing
 sudo systemctl start elasticsearch.service

/usr/lib/tmpfiles.d/elasticsearch.conf:1: Line references path below legacy directory /var/run/, updating /var/run/elasticsearch → /run/elasticsearch; please update the tmpfiles.d/ drop-in file accordingly.

  Verifying        : elasticsearch-8.17.2-1.x86_64                                                    1/1 
Installed products updated.

Installed:
  elasticsearch-8.17.2-1.x86_64                                                                           

Complete!
```

- Buradaki çıktı önemli bize superuser token veriyor bunu bir dosyaya kaydedelim

```bash
vi info.txt
```

```txt
--------------------------- Security autoconfiguration information ------------------------------

Authentication and authorization are enabled.
TLS for the transport and HTTP layers is enabled and configured.

The generated password for the elastic built-in superuser is : UiVHFXbVX5x+u*hgoIwD 

If this node should join an existing cluster, you can reconfigure this with
'/usr/share/elasticsearch/bin/elasticsearch-reconfigure-node --enrollment-token <token-here>'
after creating an enrollment token on your existing cluster.

You can complete the following actions at any time:

Reset the password of the elastic built-in superuser with 
'/usr/share/elasticsearch/bin/elasticsearch-reset-password -u elastic'.

Generate an enrollment token for Kibana instances with 
 '/usr/share/elasticsearch/bin/elasticsearch-create-enrollment-token -s kibana'.

Generate an enrollment token for Elasticsearch nodes with 
'/usr/share/elasticsearch/bin/elasticsearch-create-enrollment-token -s node'.

-------------------------------------------------------------------------------------------------
```


4. Go to /etc/elasticsearch/elasticsearch.yml config file and update below parameters 

```bash
vi /etc/elasticsearch/elasticsearch.yml
```

```yaml
cluster.name: "tg-elk"
node.name: "es-1"

```

If you want to store Elasticsearch's own logs and the logs it retains in a different folder, you need to update the following parameters. For example, if you have attached an additional volume to an AWS instance and want to keep the logs on this volume, you need to update the paths below according to the mounted volume path.

```yaml
# ----------------------------------- Paths ------------------------------------
#
# Path to directory where to store the data (separate multiple locations by comma):
#
path.data: /data/elasticsearch
#
# Path to log files:
#
path.logs: /var/log/elasticsearch

network.host: 172.19.24.8 

http.port: 9200

cluster.initial_master_nodes: ["172.19.24.8"]
```
- cluster.initial_master_nodes: ["172.19.24.8"] 2 tane var buraya dikkat et

5. To create folders in a specified path and set the necessary permissions
- Burda external mount ettiğimiz klasör yapısını ayarlıyoruz.

```bash
mkdir -p /data/elasticsearch
chown -R elasticsearch:elasticsearch /data/elasticsearch
chmod -R 755 /data/elasticsearch
```


6. To configure Elasticsearch to start automatically when the system boots up, run the following commands
- Bu komutlarlarla artık Elasticsearch'i çalıştıracağız.

```bash
sudo /bin/systemctl daemon-reload
sudo /bin/systemctl enable elasticsearch.service
sudo systemctl start elasticsearch.service
```

- You can test that your Elasticsearch node is running by sending an HTTPS request to port 9200 on localhost

```bash
export ELASTIC_PASSWORD="UiVHFXbVX5x+u*hgoIwD" # change me
curl --cacert /etc/elasticsearch/certs/http_ca.crt -u elastic:$ELASTIC_PASSWORD https://localhost:9200 

```
- Burda ELASTIC_PASSWORD'ümüz superuser token'ı onu ekliyoruz.

- Eğer bir hata alırsak loglarına bakmak için

```bash
tail -f /var/log/elasticsearch/<cluster_name>.log
```

- The call returns a response like this

```bash
curl --cacert /etc/elasticsearch/certs/http_ca.crt -u elastic:$ELASTIC_PASSWORD https://localhost:9200
{
  "cluster_name" : "rke2",
  "status" : "green",
  "timed_out" : false,
  "number_of_nodes" : 1,
  "number_of_data_nodes" : 1,
  "active_primary_shards" : 3,
  "active_shards" : 3,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 0,
  "unassigned_primary_shards" : 0,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 100.0
}
```

## Install ElasticSearch-2

- Öncesinde Volume işlemlerini burda da yapıyoruz.

1.  Import the Elasticsearch public GPG key to the rpm package manager.

```bash
sudo -i
rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch
```

2. Insert the following lines to the repository configuration file elasticsearch.repo:

```bash
vi /etc/yum.repos.d/elasticsearch.repo
```

```yaml
[elasticsearch]
name=Elasticsearch repository for 8.x packages
baseurl=https://artifacts.elastic.co/packages/8.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=0
autorefresh=1
type=rpm-md
```

3. Install the Elasticsearch package.

```bash
yum install --enablerepo=elasticsearch elasticsearch
```

- Burda ElasticSearch-2'de verdiği token'ın bir önemi yok

Reconfigure a node to join an existing cluster

- Go to Elasticsearch-1 terminal and generate a node enrollment token

Note: This token is only valid for 30 minutes. When you need to add a new node in the future, you must generate a new token

```bash
/usr/share/elasticsearch/bin/elasticsearch-create-enrollment-token -s node
```

- Save and Copy the enrollment token, which is output to your terminal 

- On your new Elasticsearch node, pass the enrollment token 

```bash
/usr/share/elasticsearch/bin/elasticsearch-reconfigure-node --enrollment-token <enrollment-token>
```

- Go to /etc/elasticsearch/elasticsearch.yml file update below parameter and See that the security config section is created and the discovery.seed_hosts parameter is added with the IP address of elasticsearch-1

- Bu değişikliği ElasticSearch-2'de yapacağız

```bash
vi /etc/elasticsearch/elasticsearch.yml
```

```yaml
cluster.name: "tg-elk"
node.name: "es-2"


# ----------------------------------- Paths ------------------------------------
#
# Path to directory where to store the data (separate multiple locations by comma):
#
path.data: /data/elasticsearch
#
# Path to log files:
#
path.logs: /var/log/elasticsearch

network.host: <es2-vm-ip>

http.port: 9200

```

- Burda `cluster.name:` master da girdiğimiz değer ile aynı olacak
- Ayrıca discovery.seed_hosts: ["172.31.26.205:9300"] un açılmış olduğunuda görüyoruz master node'un IP'si (yine 2 satır var bundan dikkat et)

- To create folders in a specified path and set the necessary permissions

```bash
mkdir -p /data/elasticsearch
chown -R elasticsearch:elasticsearch /data/elasticsearch
chmod -R 755 /data/elasticsearch
```
- To configure Elasticsearch-2 to start automatically when the system boots up, run the following commands

```bash
sudo /bin/systemctl daemon-reload
sudo /bin/systemctl enable elasticsearch.service
sudo systemctl ...