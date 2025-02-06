#### 7.Redis Server Kurulumu
  ```
    cd ~/ansible_files      ## ansible server dan yapılmalıdır
    ansible-playbook playbooks/redis-playbook.yaml
  ```

- Redis kontrolü yapmak için

  `redis-cli -h localhost -p 6379 -a <redis-password>`