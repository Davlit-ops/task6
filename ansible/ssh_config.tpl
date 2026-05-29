Host bastion
    HostName ${bastion_ip}
    User ubuntu
    IdentityFile /home/vdavl/.ssh/task6_key
    StrictHostKeyChecking no

Host task6-jenkins
    HostName ${jenkins_ip}
    User ubuntu
    IdentityFile /home/vdavl/.ssh/task6_key
    ProxyJump bastion
    StrictHostKeyChecking no
