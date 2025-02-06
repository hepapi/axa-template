#### 6.Postgres Server Kurulumu
  ```
    cd ~/ansible_files       ## ansible server dan yapılmalıdır
    ansible-playbook playbooks/postgres-playbook.yaml
  ```

- Postgres kontrolü yapmak için postgres userına geçip;

  `psql -h localhost -U <username> -d <databasename> -p 5432`