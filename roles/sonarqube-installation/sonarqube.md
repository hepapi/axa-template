#### Sonarqube Kurulumu
  ```
    cd ~/ansible_files        ## ansible server dan yapılmalıdır
    ansible-playbook playbooks/sonarqube-playbook.yaml
  ```

- Sonarqube kurulumu developer edition için yapılmıştır.  ### farklı kurulum ve paketler için https://binaries.sonarsource.com/?prefix=

- Uygulamanın ui kontrolü için;

    `http://server-ip:9000`