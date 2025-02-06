#### RKE-2 Downstream Cluster Worker Kurulumu
- Rke-2 worker oluşturma;
   ```
    cd ~/ansible_files        ## ansible server dan yapılmalıdır
    ansible-playbook playbooks/downstream-worker-playbook.yaml
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
  `kubectl get node -o wide --kubeconfig=/etc/rancher/rke2/rke2.yaml