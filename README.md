## Project Structure

```text
task4/
├── ansible/
│   ├── roles/
│   │   ├── jenkins/
│   │   │   └── tasks/
│   │   │       └── main.yml
│   │   │   └── handlers/
│   │   │       └── main.yml
│   │   │   └── templates/
│   │   │       └── security.groovy.j2
│   │   └── system/
│   │       └── tasks/
│   │           └── main.yml
│   ├── ansible.cfg
│   ├── inventory.ini
│   ├── playbook.yml
│   └── ssh_config.tpl
├── terraform/
│   ├── backend/
│   │   └── main.tf
│   ├── jenkisn-slave/
│   │   ├── main.tf
│   │   ├── user_data.sh
│   │   └── variables.tf
│   ├── alb.tf
│   ├── ec2.tf
│   ├── iam.tf
│   ├── providers.tf
│   ├── sg.tf
│   ├── terraform.tfvars
│   ├── vpc.tf
│   └── variables.tf
├── .gitignore
└── README.md
```
