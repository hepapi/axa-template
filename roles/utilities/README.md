# utilities Role

This role provides common functionality for other roles.

Task filenames are prefixed with underscore(`_`) to make a distinction.

**They are not meant to be called directly, but rather used by other tasks via `import_tasks` feature.**

### Task: \_write_consul_kv.yml

- Use to write to a key in Consul Key/Value Store.

```yml
- name: Test Consul Connectivity — read datacenters
  import_tasks: roles/utilities/tasks/_read_consul.yml
  vars:
    consul_token: "" # TODO: consul token is not supported in -dev env,
    consul_uri: "{{ consul_address }}v1/catalog/datacenters"
    status_code: [200, 201, 202]
    register_to: consul_data_centers_response
# - debug:
#     var: consul_data_centers_response
```

### Task: \_read_consul.yml

- Use write data to a key in Consul KeyValue Store.

```yml
- name: Write to Consul KeyValue Store
  import_tasks: roles/utilities/tasks/_write_consul_kv.yml
  vars:
    consul_token: ""  # TODO: consul token is not supported in -dev env,
    consul_uri: "{{ consul_address }}v1/kv/dev/backend/account-service/api" 
    register_to: consul_write_kv_response
    request_body: "{{ lookup('ansible.builtin.template','templates/consul-kv.json') }}"
    status_code: [200,201,202]

- debug:
    var: consul_write_kv_response
```

### Task: \_git_clone

- Use to clone a remote repository to a local directory.

```yml title="example usage"
- import_tasks: roles/utilities/tasks/_git_clone_with_ssh.yml
  vars:
    repo_github_ssh_uri: "{{ dapr_repo_github_ssh_uri }}"
    repo_clone_dest: "{{ dapr_repo_clone_dest }}"
    repo_sshkey_rel_path: "{{ role_path }}{{ dapr_repo_sshkey_rel_path }}"
    repo_branch: "{{ dapr_repo_branch }}"
```

### Task: \_git_add_commit_push_ssh

- Use to add, commit and push changed files in a local git repository
- Requires multiple variables to be set.
- `register_to` can be used to save the result of the write operation to a variable — or a fact.

```yml title="example usage"
- import_tasks: roles/utilities/tasks/_git_add_commit_push_ssh.yml
  vars:
    git_author_name: "{{ GIT_AUTHOR_NAME }}"
    git_author_email: "{{ GIT_AUTHOR_EMAIL }}"
    repo_github_ssh_uri: "{{ dapr_repo_github_ssh_uri }}"
    repo_clone_dest: "{{ dapr_repo_clone_dest }}"
    repo_branch: "{{ dapr_repo_branch }}"
    repo_sshkey_rel_path: "{{ role_path }}{{ dapr_repo_sshkey_rel_path }}"
    update_rel_filepaths_str_list: "{{ dapr_components_update_rel_filepaths }}"
    git_commit_message: "Ansible: append new microservice to dapr configs"
    register_to: "git_acp_script_output"
```

### Task: \_write_vault_kv2

- Use to write secrets to vault kv2 secrets engine.
- Requires `secret_path`(str) and `secret_data`(dict) variables to be set.
- `register_to` can be used to save the result of the write operation to a variable — or a fact.

```yml
- import_tasks: roles/utilities/tasks/_write_vault_kv2.yml
  vars:
    secret_path: "apps/hello"
    secret_data:
      test: deneme
      test2: deneme2
    register_to: vault_hello_result
```

After the task is executed, `vault_hello_result` variable will be available to the playbook.

```yml
- name: Display the result of the secret write of vault_hello_result
  ansible.builtin.debug:
    msg: "{{ vault_hello_result }}"
  when: vault_hello_result is defined
```

### Task: \_read_vault_kv2

- Use to read secrets from vault kv2 secrets engine.
- Requires `secret_path`(str) and `register_to`(str) variables to be set.
- `register_to` can be used to save the result of the write operation to a variable — or a fact.

```yml
- import_tasks: roles/utilities/tasks/_read_vault_kv2.yml
  vars:
    secret_path: "apps/hello"
    register_to: vault_hello_read
```

After the task is executed, `vault_hello_read` variable will be available to the playbook.

```yml
- name: Display the result of the secret read of vault_hello_read
  ansible.builtin.debug:
    msg: "{{ vault_hello_read }}"
  when: vault_hello_read is defined
```
