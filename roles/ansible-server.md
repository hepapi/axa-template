#### Ansible Server Kurulumu

- Internet bağlantısı kontrol edilmesive server ın update edilmesi,
    `sudo apt update -y`
- Ansible Intallation
    `sudo apt install ansible -y`
    ```
    git clone <ansible_files_repo>
    ```

- Public ve Private key oluşturulması,
    ```
    mkdir ~/.ssh 
    cd ~/.ssh
    ssh-keygen
    ```

#### SSH Key Oluşturma ve Dağıtma

- Oluşturulan public key in ansible ile konfigure edilmesi istenen VM lere eklenmesi,
  - Jump Server da ~/.ssh/id_rsa.pub dosya içeriğinin kopyalanması,
  - İlgili VM lerde ~/.ssh/authorized_keys dosyasının oluşturulması,
  - İlgili VM lerde ~/.ssh/authorized_keys içerisinde yapıştırılması.

#### Jump Server Kurulumu
  ```
    cd ~/ansible_files
    ansible-playbook playbooks/ansible-playbook.yaml
  ```
