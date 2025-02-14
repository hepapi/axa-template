# INSTALL 3 NODES ELASTICSEARCH,LOGSTASH, KIBANA and FileBeat

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
sudo systemctl start elasticsearch.service
```

- Check whether elasticsearch-2 added existing cluster


```bash
export ELASTIC_PASSWORD="xxxxx" # change me
curl --cacert /etc/elasticsearch/certs/http_ca.crt -u elastic:$ELASTIC_PASSWORD https://localhost:9200/_cluster/health?pretty 
```
- The call returns a response like this

```bash
{
  "cluster_name" : "tg-elk",
  "status" : "green",
  "timed_out" : false,
  "number_of_nodes" : 2,
  "number_of_data_nodes" : 2,
  "active_primary_shards" : 3,
  "active_shards" : 6,
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

- Check Which node is master

```bash
curl --cacert /etc/elasticsearch/certs/http_ca.crt -u elastic:$ELASTIC_PASSWORD https://localhost:9200/_cat/master?v
```


## Install ElasticSearch-3 and Join existing Cluster.

- Repeat the same steps we performed for Elasticsearch-2 for Elasticsearch-3

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
/usr/share/elasticsearch/bin/elasticsearch-reconfigure-node --enrollment-token eyJ2ZXIiOiI4LjE0LjAiLCJhZHIiOlsiMTcyLjMxLjI2LjIwNTo5MjAwIl0sImZnciI6ImQ3MzhkODMzYzUzZmMzYzkwNmQ0NzM5NzYyOGY2NmQ0ZDQ5YTI1OWMxYzU5OTk0ZjAxZTZmMzUzNTJiNzUzZjMiLCJrZXkiOiJnRXRVQVpVQjhheXhKQUZpNktJUzp2RHg0bzhwdFFsMjdvTFRfT2ZMazZnIn0=
```

- Go to /etc/elasticsearch/elasticsearch.yml file update below parameter and See that the security config section is created and the discovery.seed_hosts parameter is added with the IP address of elasticsearch-1

- Bu değişikliği ElasticSearch-3'de yapacağız

```bash
vi /etc/elasticsearch/elasticsearch.yml
```

```yaml
cluster.name: "tg-elk"
node.name: "es-3"


# ----------------------------------- Paths ------------------------------------
#
# Path to directory where to store the data (separate multiple locations by comma):
#
path.data: /data/elasticsearch
#
# Path to log files:
#
path.logs: /var/log/elasticsearch

network.host: <es3-vm-ip>

http.port: 9200

```

- Burda `cluster.name:` master da girdiğimiz değer ile aynı olacak
- Ayrıca `discovery.seed_hosts: discovery.seed_hosts: ["172.31.26.205:9300", "172.31.25.177:9300"]` un açılmış olduğunuda görüyoruz master node'un IP'si (yine 2 satır var bundan dikkat et)

- To create folders in a specified path and set the necessary permissions

```bash
mkdir -p /data/elasticsearch
chown -R elasticsearch:elasticsearch /data/elasticsearch
chmod -R 755 /data/elasticsearch
```
- To configure Elasticsearch-3 to start automatically when the system boots up, run the following commands

```bash
sudo /bin/systemctl daemon-reload
sudo /bin/systemctl enable elasticsearch.service
sudo systemctl start elasticsearch.service
```

- Check whether elasticsearch-3 added existing cluster

```bash
export ELASTIC_PASSWORD="xxxxx" # change me
curl --cacert /etc/elasticsearch/certs/http_ca.crt -u elastic:$ELASTIC_PASSWORD https://localhost:9200/_cluster/health?pretty 
```
- The call returns a response like this

```bash
{
  "cluster_name" : "rke2",
  "status" : "green",
  "timed_out" : false,
  "number_of_nodes" : 3,
  "number_of_data_nodes" : 3,
  "active_primary_shards" : 3,
  "active_shards" : 6,
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

- Check Which node is master

```bash
curl --cacert /etc/elasticsearch/certs/http_ca.crt -u elastic:$ELASTIC_PASSWORD https://localhost:9200/_cat/master?v
```


NOTE: When a new node is added to an existing Elasticsearch cluster using a token, the IP addresses of all the nodes in the cluster are added to the discovery.seed_hosts parameter of the new node. However, the IP address of the newly added node is not added to the existing nodes' configurations. You need to add this new node's IP address to the discovery.seed_hosts parameter of the existing nodes manually.

node-1 etc/elasticsearch/elasticsearch.yml
node-2 /etc/elasticsearch/elasticsearch.yml
node-3 /etc/elasticsearch/elasticsearch.yml

- Burda 3 node'un etc/elasticsearch/elasticsearch.yml'ında aşağıdaki düzeltmeyi yapacağız. 3 node'un da IP adreslerini yazalım

```bash
vi /etc/elasticsearch/elasticsearch.yml
```

```yaml
discovery.seed_hosts: ["<all-vm-ip-address:port>"] #You need to manually add the IP addresses of all subsequently added nodes
```
- Burdaki amaç bir node giderse lider değişsin diye

```yaml
discovery.seed_hosts: ["172.31.26.205:9300", "172.31.25.177:9300", "172.31.22.56:9300"]
```
- Bu şekilde 3 node'u da yazacağız


- check node and cluster
- 3 node için bu komutları çalıştırabilirsin

```bash
for es health

curl --cacert /etc/elasticsearch/certs/http_ca.crt -u elastic:$ELASTIC_PASSWORD https://localhost:9200

check cluster health

curl --cacert /etc/elasticsearch/certs/http_ca.crt -u elastic:$ELASTIC_PASSWORD https://localhost:9200/_cluster/health?pretty

check which one master

curl --cacert /etc/elasticsearch/certs/http_ca.crt -u elastic:$ELASTIC_PASSWORD https://localhost:9200/_cat/master?v
```

- Bu komutlardan sonra sırasıyla node'ları stop'a çek. Cluster lider değiştiriyor mu? Kontrol et

```bash
sudo systemctl stop elasticsearch.service
```


## Install Kibana 

1. Download and install the public signing key

```bash
sudo -i
rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch
```

2. Create a file called kibana.repo in the /etc/yum.repos.d/ directory for RedHat based distributions, or in the /etc/zypp/repos.d/ directory for OpenSuSE based distributions, containing:

```bash
vi /etc/yum.repos.d/kibana.repo
```

```yaml
[kibana-8.x]
name=Kibana repository for 8.x packages
baseurl=https://artifacts.elastic.co/packages/8.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md
```

3. And your repository is ready for use. You can now install Kibana with one of the following commands:

```bash
sudo yum install kibana 
```

- To configure Kibana to start automatically when the system starts, run the following commands

```bash
sudo /bin/systemctl daemon-reload
sudo /bin/systemctl enable kibana.service
sudo systemctl start kibana.service
```

- Go to Elasticsearch-1 terminal and generate  enrollment token for kibana

Note: This token is only valid for 30 minutes. When you need to add a new node in the future, you must generate a new token

```bash
/usr/share/elasticsearch/bin/elasticsearch-create-enrollment-token -s kibana
```

- Go to localhost:5601 adress and paste enrollment token for kibana and click auto configure for elasticsearch

- Master'da aldığın token'ı Kibana UI'de yapıştır.

- Go to kibana server and run command and paste the verification code

- Aşağıdaki komutla Kibana'dan verification code'unu al

```bash
/usr/share/kibana/bin/kibana-verification-code
```

- UI'in gelmesi uzun sürerse sayfayı yenile.

```bash
username: elastic
password: <elasticsearch-password>
```
- Buraya superuser token'ı veriliyor.

Explore on my own --> Hamburger Menü --> Stack Monitoring

## Install Logstash

- Download and install the Public Signing Key


```bash
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo gpg --dearmor -o /usr/share/keyrings/elastic-keyring.gpg
```

- You may need to install the apt-transport-https package on Debian before proceeding

```bash
sudo apt-get install apt-transport-https
```

- Save the repository definition to /etc/apt/sources.list.d/elastic-8.x.list

```bash
echo "deb [signed-by=/usr/share/keyrings/elastic-keyring.gpg] https://artifacts.elastic.co/packages/8.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-8.x.list
```

- Run sudo apt-get update and the repository is ready for use. You can install it with

```bash
sudo apt-get update && sudo apt-get install logstash
```

- Logstash needs to securely send logs to Elasticsearch via HTTPS, which requires us to copy the http_ca.crt certificate located under the /etc/elasticsearch/certs/ path in Elasticsearch to Logstash.

Create a folder under /etc/logstash named certs in logstash

```bash
mkdir -p /etc/logstash/certs
```

copy /etc/elasticsearch/certs/http_ca.crt file to /etc/logstash/certs/http_ca.crt  in logstash


```bash
vi http_ca.crt 
```

- Go to /etc/logstash/jvm.options and update below parameters depends on logstash vm memory size.Best practice %50

```bash
## JVM configuration

# Xms represents the initial size of total heap space
# Xmx represents the maximum size of total heap space
-Xms4g  #memory 8gb
-Xmx4g
```


- Go to /etc/logstash/conf.d folder in logstash and create new file .conf extension

```bash
vi tg-prod.conf

input {
  beats {
   port => 5044
  }
}

filter {
}

output {
      elasticsearch {
         hosts => ["https://172.19.24.8:9200", "https://172.19.24.9:9200", "https://172.19.24.10:9200"]
         data_stream => "true"
         #data_stream_type => "logs"
         data_stream_dataset => "tg-prod"
         data_stream_namespace => "default"
         ssl_enabled => true
         ssl_certificate_authorities => "/etc/logstash/certs/http_ca.crt"
         ssl_verification_mode => "full"
         user => "ChangeMe"
         password => "ChangeMe"
         compression_level => 3
      }
}

```


- Update <elasticsearch-ips>, index,user and password.
- You can add filter based on the status of the logs
- You can check whether Logstash has established a connection with Elasticsearch by inspecting the /var/log/logstash/logstash-plain.log file

- Start and Enable logstash

```bash
sudo systemctl start logstash.service
sudo systemctl enable logstash.service
```

To check if your Logstash pipeline is running, you can use this command. This command will help you ensure that Logstash is properly configured and running

```bash
tail -f /var/log/logstash/logstash-plain.log
```

- The call returns a response like this.

```bash
[2024-05-28T12:07:11,925][INFO ][logstash.outputs.elasticsearch][main] Installing Elasticsearch template {:name=>"ecs-logstash"}
[2024-05-28T12:07:12,549][INFO ][logstash.javapipeline    ][main] Pipeline Java execution initialization time {"seconds"=>0.7}
[2024-05-28T12:07:12,559][INFO ][logstash.inputs.beats    ][main] Starting input listener {:address=>"0.0.0.0:5044"}
[2024-05-28T12:07:12,568][INFO ][logstash.javapipeline    ][main] Pipeline started {"pipeline.id"=>"main"}
[2024-05-28T12:07:12,588][INFO ][logstash.agent           ] Pipelines running {:count=>1, :running_pipelines=>[:main], :non_running_pipelines=>[]}
```


## Filebeat Installation

- Create a `filebeat-values.yaml` 

```bash
vi filebeat-values.yaml 
```

```yaml
daemonset:
  extraEnvs:
    - name: "ELASTICSEARCH_USERNAME"
      valueFrom:
        secretKeyRef:
          name: elasticsearch-master-credentials
          key: username
    - name: "ELASTICSEARCH_PASSWORD"
      valueFrom:
        secretKeyRef:
          name: elasticsearch-master-credentials
          key: password
  hostNetworking: false
  secretMounts:
    - name: elasticsearch-master-certs
      secretName: elasticsearch-master-certs
      path: /usr/share/filebeat/certs/
  filebeatConfig:
    filebeat.yml: |
      filebeat.config:
        modules:
          path: ${path.config}/modules.d/*.yml
          # Reload module configs as they change:
          reload.enabled: false
      filebeat.autodiscover:
        providers:
          - type: kubernetes
            templates:
              - condition:
                  not:
                    or:
                      - equals:
                          kubernetes.namespace: "kube-system"
                      - equals: 
                          kubernetes.namespace: "calico-system"
                      - equals:
                          kubernetes.namespace: "default"
                      - equals:
                          kubernetes.namespace: "elastic-system"
                      - equals: 
                          kubernetes.namespace: "instana-agent"
                      - equals:
                          kubernetes.namespace: "ingress-basic"
                      - equals:
                          kubernetes.namespace: "kube-public"
                      - equals: 
                          kubernetes.namespace: "kube-node-lease"
                      - equals:
                          kubernetes.namespace: "monitoring"
                      - equals:
                          kubernetes.namespace: "tigera-operator"

                config:
                  - type: container
                    paths:
                      - /var/log/containers/*-${data.kubernetes.container.id}.log
                    containers.ids:
                      -  "${data.kubernetes.container.id}"
      output.logstash:
        hosts: ["172.19.24.11:5044"]

      processors:
        - include_fields: 
            fields: ["kubernetes.deployment.name", "container.image.name", "kubernetes.namespace", "kubernetes.node.name", "kubernetes.pod.name", "message", "kubernetes.pod.ip", "kubernetes cronjob.name"]

  maxUnavailable: 1
  securityContext:
    runAsUser: 0
    privileged: false
  resources:
    requests:
      cpu: "100m"
      memory: "100Mi"
    limits:
      cpu: "1000m"
      memory: "500Mi"
  tolerations:
          - key: node-role.kubernetes.io/control-plane
            effect: NoSchedule
          - key: node-role.kubernetes.io/master
            effect: NoSchedule
          - key: workload
            operator: Equal
            value: b2b
          - key: workload
            operator: Equal
            value: appuser
          - key: workload
            operator: Equal
            value: merch
          - key: workload
            operator: Equal
            value: newuser
          - key: workload
            operator: Equal
            value: order

replicas: 1

hostPathRoot: /var/lib

image: "docker.elastic.co/beats/filebeat"
imageTag: "8.5.1"
imagePullPolicy: "IfNotPresent"
imagePullSecrets: []

livenessProbe:
  exec:
    command:
      - sh
      - -c
      - |
        #!/usr/bin/env bash -e
        curl --fail 127.0.0.1:5066
  failureThreshold: 3
  initialDelaySeconds: 10
  periodSeconds: 10
  timeoutSeconds: 5

readinessProbe:
  exec:
    command:
      - sh
      - -c
      - |
        #!/usr/bin/env bash -e
        filebeat test output
  failureThreshold: 3
  initialDelaySeconds: 10
  periodSeconds: 10
  timeoutSeconds: 5

managedServiceAccount: true

clusterRoleRules:
  - apiGroups:
      - ""
    resources:
      - namespaces
      - nodes
      - pods
    verbs:
      - get
      - list
      - watch
  - apiGroups:
      - "apps"
    resources:
      - replicasets
    verbs:
      - get
      - list
      - watch

updateStrategy: RollingUpdate

nameOverride: ""
fullnameOverride: ""
```

- Create a `Secret` for Elasticsearch credentials

```bash
vi elasticsearch-master-credentials.yaml
```

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: elasticsearch-master-credentials
  namespace: logging
data:
  username: <BASE64_ENCODED_USERNAME>
  password: <BASE64_ENCODED_PASSWORD>
```

- Create a `Secret` for Elasticsearch certificates

```bash
vi elasticsearch-master-certs.yaml
```

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: elasticsearch-master-certs
  namespace: logging
data:
  ca.crt: |
  <BASE64_ENCODED_CA_CERT>
```

Note: If a namespace named logging does not already exist, create a namespace named logging

- Apply the Secrets

```bash
kubectl apply -f elasticsearch-master-credentials.yaml
kubectl apply -f elasticsearch-master-certs.yaml
```

- Install Filebeat with Helm

```bash
helm repo add elastic https://helm.elastic.co
helm upgrade --install filebeat elastic/filebeat --version 8.5.1 -n logging -f filebeat-values.yaml
```

## Index Life Cycle Management

### Index Lifecycle Policy

- Go to Kibana UI and select Stack Management Under Left Hand Menu

- Click Index Lifecycle Policies and Create Policy section.

- Give a name whatever you want such as `tg-policy` and determine your necessity for example --> `Maximum primary shard size: 30`  , `Maximum age: 15`  under Hot phase --> Advance Settings.

- Enable `Delete data after this phase` section and determine `Move data into phase when` under `Delete Phase`. such as 15 days and save policy.
 
### Index Template

- Go to Kibana UI and select Stack Management Under Left Hand Menu.

- Click Index Management, Click Index Templates and Create Template button.

- Enter Index Template Name and Index Index pattern such as `logs-tg-prod-default`. Enable `Create data stream` Click Next button.

- Leave as a Default `Component templates` Section and click Next button.

- Add Parameter as a your necessity like as and click next
```json
{
  "index": {
    "lifecycle": {
      "name": "tg-policy"
    },
    "number_of_shards": "1",
    "number_of_replicas": "1"
  }
}
```

-  Leave as a Default `Mapping` Section and click Next button.

- Leave as a Default `Aliases (optional)` Section and click Next button.

- Lastly save template.

### Create Index via Dev Tool

- Go to Kibana UI and select Dev Tool from Left Hand Menu under Management Section.

- Paste below command and run.

```json
PUT /logs-tg-prod-default
```

### Check your Index Policy and Template

- Go to Kibana UI and select Stack Management Under Left Hand Menu.

- Click Index Management section and select Data Stream.

- Select your Index and Check your `Index lifecycle policy` and Index `template`.

## Enable Stack Monitoring
- Go to Kibana WebUI,click hamburger menu and select Stack Monitoring.

- Click metricbeat configuration

- Go to elasticsearch-1 VM terminal and Install Metricbeat

```bash
curl -L -O https://artifacts.elastic.co/downloads/beats/metricbeat/metricbeat-8.17.0-amd64.deb
sudo dpkg -i metricbeat-8.17.0-amd64.deb
```

- Set the host and port where Metricbeat can find the Elasticsearch installation, and set the username and password of a user who is authorized to set up Metricbeat 

`/etc/metricbeat/metricbeat.yml`

```bash
setup.kibana:
  host: "https://172.19.24.12:5601"

output.elasticsearch:
  hosts: ["https://172.19.24.8:9200", "https://172.19.24.9:9200", "https://172.19.24.10:9200"]
  preset: balanced
  protocol: "https"
  username: "elastic"
  password: <elasticsearch-password> #update
  ssl:
    enabled: true
    ca_trusted_fingerprint: <update>
```

- You can learn ca_trusted_fingerprint by using below command:

```bash
openssl x509 -fingerprint -sha256 -in /etc/elasticsearch/certs/http_ca.crt
```

```bash
9D:18:8D:D7:45:85:7F:43:27:D2:5B:40:67:0A:7E:C4:15:EB:CF:11:2F:77:07:CD:C9:EF:18:C2:3D:EC:D3:CB
```
- Remove the colons and convert all letters to lowercase you can use this website `https://convertcase.net/` or chatgpt :-)

- Enable the Elasticsearch module in Metricbeat on each Elasticsearch node.

```bash
metricbeat modules enable elasticsearch-xpack
```

Configure the Elasticsearch module in Metricbeat on Elasticsearch node. First create /etc/metricbeat/http_ca.crt file and add elasticsearch /etc/elasticsearch/certs/http_ca.crt to this file 

```bash
/etc/metricbeat/modules.d/elasticsearch-xpack.yml

- module: elasticsearch
  xpack.enabled: true
  period: 10s
  hosts: ["https://localhost:9200"]
  username: "elastic"
  password: <elasticsearch-password> #update
  ssl.enabled: true
  ssl.certificate_authorities: ["/etc/metricbeat/http_ca.crt"]
```

- Start and enabled metricbeat

```bash
systemctl start metricbeat
systemctl enable metricbeat
```

- Set xpack.monitoring.collection.enabled to true on the Elasticcluster. By default, it is is disabled (false).

Run Dev Tools


```bash
PUT _cluster/settings
{
  "persistent": {
    "xpack.monitoring.collection.enabled": true
  }
}
```

```bash
PUT _cluster/settings
{
  "persistent": {
    "xpack.monitoring.history.duration" : "2d"
  }
}
```

- Bu komutları tek tek serverlara girmemiz gerekiyor ki versionlar sabit kalsın ElastichSearch ile kibana aynı sürüm olması lazım

```bash
sudo apt-mark hold kibana
sudo apt-mark hold elasticsearch
```
