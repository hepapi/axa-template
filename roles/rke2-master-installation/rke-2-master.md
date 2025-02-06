#### RKE-2 Upstream Cluster Master Kurulumu
  ```
    cd ~/ansible_files   ## ansible server dan yapılmalıdır
    ansible-playbook playbooks/upstream-master-playbook.yaml
  ```

- Prerequestler için kontrol komutları;
  ```
    sysctl vm.panic_on_oom
    sysctl vm.overcommit_memory 
    sysctl kernel.panic 
    sysctl kernel.panic_on_oops 
    sysctl net.ipv4.ip_forward 
    sysctl net.bridge.bridge-nf-call-iptables 
    sysctl net.bridge.bridge-nf-call-ip6tables 
  ```
  Beklenen Çıktı;
  ```
    vm.panic_on_oom = 0
    vm.overcommit_memory = 1
    kernel.panic = 10
    kernel.panic_on_oops = 1
    net.ipv4.ip_forward = 1
    net.bridge.bridge-nf-call-iptables = 1
    net.bridge.bridge-nf-call-ip6tables = 1
  ```
  Dosya limitleri;
  `cat /etc/security/limits.conf`
  Dosya en alt kısımda görülmesi gereken değerler;
  ```
    root hard nofile 1024000
    root hard nproc 1024000
    root soft nofile 1024000
    root soft nproc 1024000
    * hard nofile 1024000
    * hard nproc 1024000
    * soft nofile 1024000
    * soft nproc 1024000
  ```
  Swap kontrolü
  `free -h`

  Firewall Kontrolü
  `systemctl status ufw `

- Node kontrol etmek için;
  `kubectl get node -o wide --kubeconfig=/etc/rancher/rke2/rke2.yaml`
  

#### Rancher Kurulumu (Bring your own certificate)

- Sertifikalardan kubernetes secret larının oluşturulması; 

  - TLS secret
    ```
    kubectl -n cattle-system create secret tls tls-rancher-ingress \
    --cert=tls.crt \
    --key=tls.key
    ```

- Helm ile rancher kurulumu;
  ```
  helm repo add rancher-stable https://releases.rancher.com/server-charts/stable

    helm install rancher rancher-stable/rancher \
    --namespace cattle-system \
    --set hostname=rancher-dev.hepapi.com \   #change hostname
    --set bootstrapPassword=admin \
    --set ingress.tls.source=secret
  ```

- Kontrol etmek için;
  ```
    kubectl -n cattle-system get deploy rancher
  ```


#### RKE-2 Downstream Cluster Master Kurulumu
- Rke-2 master oluşturma;
  ```
    cd ~/ansible_files        ## ansible server dan yapılmalıdır
    ansible-playbook playbooks/downstream-master-playbook.yaml
  ```

- Prerequestler için kontrol komutları;
  ```
    sysctl vm.panic_on_oom
    sysctl vm.overcommit_memory 
    sysctl kernel.panic 
    sysctl kernel.panic_on_oops 
    sysctl net.ipv4.ip_forward 
    sysctl net.bridge.bridge-nf-call-iptables 
    sysctl net.bridge.bridge-nf-call-ip6tables 
  ```
  Beklenen Çıktı;
  ```
    vm.panic_on_oom = 0
    vm.overcommit_memory = 1
    kernel.panic = 10
    kernel.panic_on_oops = 1
    net.ipv4.ip_forward = 1
    net.bridge.bridge-nf-call-iptables = 1
    net.bridge.bridge-nf-call-ip6tables = 1
  ```
  Dosya limitleri;
  `cat /etc/security/limits.conf`
  Dosya en alt kısımda görülmesi gereken değerler;
  ```
    root hard nofile 1024000
    root hard nproc 1024000
    root soft nofile 1024000
    root soft nproc 1024000
    * hard nofile 1024000
    * hard nproc 1024000
    * soft nofile 1024000
    * soft nproc 1024000
  ```
  Swap kontrolü
  `free -h`

  Firewall Kontrolü
  `systemctl status ufw `

- Node kontrol etmek için;
  `kubectl get node -o wide --kubeconfig=/etc/rancher/rke2/rke2.yaml`
