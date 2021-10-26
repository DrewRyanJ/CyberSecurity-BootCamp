The files in this repository were used to configure the network depicted below.

![](https://github.com/DrewRyanJ/CyberSecurity-BootCamp/blob/main/Diagrams/Project%201.drawio.png)

These files have been tested and used to generate a live ELK deployment on Azure. They can be used to either recreate the entire deployment pictured above. Alternatively, select portions of the playbook file may be used to install only certain pieces of it, such as Filebeat.

#### Playbook 1: pentest.yml
```
---
  - name: My first playbook
    hosts: webservers
    become: true
    tasks:

    - name: Install docker-container
      apt:
        force_apt_get: yes
        update_cache: yes
        name: docker.io
        state: present

    - name: Install pip3
      apt:
        force_apt_get: yes
        name: python3-pip
        state: present

    - name: Install Docker python module
      pip:
        name: docker
        state: present

    - name: download and launch a docker web container
      docker_container:
        name: dvwa
        image: cyberxsecurity/dvwa
        state: started
        restart_policy: always
        published_ports: 80:80

    - name: Enable docker service
      systemd:
        name: docker
        enabled: yes
```

#### Playbook 2: elk_playbook.yml
```
---
   - name: Configure Elk VM with Docker
     hosts: elk
     remote_user: azureuser
     become: true
     tasks:

     - name: Install docker.io
       apt:
         update_cache: yes
         force_apt_get: yes
         name: docker.io
         state: present


     - name: Install python3-pip
       apt:
         force_apt_get: yes
         name: python3-pip
         state: present


     - name: Install Docker module
       pip:
         name: docker
         state: present


     - name: Increase virtual memory
       command: sysctl -w vm.max_map_count=262144


     - name: Use more memory
       sysctl:
         name: vm.max_map_count
         value: 262144
         state: present
         reload: yes


     - name: download and launch a docker elk container
       docker_container:
         name: elk
         image: sebp/elk:761
         state: started
         restart_policy: always
         published_ports:
           -  5601:5601
           -  9200:9200
           -  5044:5044

     - name: Enable service docker on boot
       systemd:
         name: docker
         enabled: yes

```

#### Playbook 3: filebeat-playbook.yml
```
---
  - name: installing and launching filebeat
    hosts: webservers
    become: yes
    tasks:

    - name: download filebeat deb
      command: curl -L -O https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-7.6.1-amd64.deb

    - name: install filebeat deb
      command: sudo dpkg -i filebeat-7.6.1-amd64.deb

    - name: drop in filebeat.yml
      copy:
        src: /etc/ansible/filebeat-config.yml
        dest: /etc/filebeat/filebeat.yml

    - name: enable and configure system module
      command: sudo filebeat modules enable system

    - name: setup filebeat
      command: sudo filebeat setup

    - name: start filebeat service
      command: sudo service filebeat start

    - name: enable service filebeat on boot
      systemd:
        name: filebeat
        enabled: yes

```

#### Playbook 4: metricbeat-playbook.yml
```
---
  - name: installing and launching metricbeat
    hosts: webservers
    become: yes
    tasks:

    - name: download metricbeat deb
      command: curl -L -O https://artifacts.elastic.co/downloads/beats/metricbeat/metricbeat-7.6.1-amd64.deb

    - name: install metricbeat deb
      command: sudo dpkg -i metricbeat-7.6.1-amd64.deb

    - name: drop in metricbeat.yml
      copy:
        src: /etc/ansible/metricbeat-config.yml
        dest: /etc/metricbeat/metricbeat.yml


    - name: enable and configure system module
      command: sudo metricbeat modules enable docker

    - name: setup metricbeat
      command: sudo metricbeat setup

    - name: start metricbeat service
      command: sudo service metricbeat start

    - name: enable service metricbeat on boot
      systemd:
        name: metricbeat
        enabled: yes
```

This document contains the following details:
- Description of the Topology
- Access Policies
- ELK Configuration
  - Beats in Use
  - Machines Being Monitored
- How to Use the Ansible Build


### Description of the Topology

The main purpose of this network is to expose a load-balanced and monitored instance of DVWA, the D*mn Vulnerable Web Application.

Load balancing ensures that the application will be highly available, in addition to restricting access to the network.
- _TODO: What aspect of security do load balancers protect? What is the advantage of a jump box?_
	
	- The load balancer defends an organization against distributed denial of service (DDoS) attacks. It does this by shifting attack traffic from the corporate server to a public cloud provider.
	- A jump box is a secure computer that all admins first connect to before launching any administrative task or use as an origination point to connect to other servers or untrusted environments.
	

Integrating an ELK server allows users to easily monitor the vulnerable VMs for changes to the configuration and system files.
- What does Filebeat watch for? Filebeat is used to monitor log files or locations that you specify, collects log events, and forwards them either to Elasticsearch or Logstash for indexing.
- What does Metricbeat record? Metricbeat is used to collect operating system and service statistics from monitored VMs 

The configuration details of each machine may be found below.
_Note: Use the [Markdown Table Generator](http://www.tablesgenerator.com/markdown_tables) to add/remove values from the table_.

| Name     | Function | IP Address | Operating System |
|----------|----------|------------|------------------|
| Jump Box | Gateway  | 10.0.0.4   | Linux            |
| Web-1    | DVWA     | 10.0.0.12  | Linux            |
| Web-2    | DVWA     | 10.0.0.13  | Linux            |
| Elk-1    | ELK      | 10.1.0.4   | Linux            |

### Access Policies

The machines on the internal network are not exposed to the public Internet. 

Only the Jump Box machine can accept connections from the Internet. Access to this machine is only allowed from the following IP addresses:
- 69.138.158.26

Machines within the network can only be accessed by The Jump Box.
- The Jump Box can access the ELK VM using SSH. The Jump Box's IP address is 10.0.0.4

A summary of the access policies in place can be found in the table below.

| Name     | Publicly Accessible | Allowed IP Addresses | Allowed Ports |
|----------|---------------------|----------------------|---------------| 
| Jump Box | Yes (SSH)           | 69.138.158.26        | 22            |
| Web-1    | Yes (HTTP)          | 69.138.158.26        | 80            |
| Web-2    | Yes (HTTP)          | 69.138.158.26        | 80            |
| Elk-1    | Yes (HTTP)          | 69.138.158.26        | 5601          |

### Elk Configuration

Ansible was used to automate configuration of the ELK machine. No configuration was performed manually, which is advantageous because...
- What is the main advantage of automating configuration with Ansible? Ansible automation helps considerably with the representation of Infrastructure as Code. It involves provisioning and mangement of computing infrastructure and related configuration through machine-processable definition files.
- Administrators could find opportunities to work in collaboration with developers that improves development speed.

The playbook implements the following tasks:

#### Playbook 1: pentest.yml
- Installs Docker
- Installs Python
- Installs Docker's Python Module
- Downloads and launces the DVWA Docker container
- Enables the Docker service

#### Playbook 2: elk_playbook.yml
- Installs Docker
- Installs Python
- Installs Docker's Python Module
- Increase virtual memory to support the ELK stack
- Increase memory to support the ELK stack
- Download and launch the Docker ELK container

#### Playbook 3: filebeat-playbook.yml
- Downloads and installs Filebeat
- Enables and configures the system module
- Configures and launches Filebeat

#### Playbook 4: metricbeat-playbook.yml
- Downloads and installs Metricbeat
- Enables and configures the system module
- Configures and launches Metricbeat

The following screenshot displays the result of running `docker ps` after successfully configuring the ELK instance.

![](https://github.com/DrewRyanJ/CyberSecurity-BootCamp/blob/main/Diagrams/sebp_elk.PNG)

### Target Machines & Beats
This ELK server is configured to monitor the following machines:
- Web-1: 10.0.0.12
- Web-2: 10.0.0.13

We have installed the following Beats on these machines:
- Filebeat
- Metricbeat

These Beats allow us to collect the following information from each machine:
- Filebeat collects and ships logs from VMs running the Filebeat agent.
- Metricbeat collects and ships system metrics form the operating system and services of VMs running the Metricbeat agent.

### Using the Playbook
In order to use the playbook, you will need to have an Ansible control node already configured. Assuming you have such a control node provisioned: 

SSH into the control node and follow the steps below:
- Copy the playbook file to Ansible Docker Container.
- Update the Ansible hosts file to include...

```
[webservers]
10.0.0.12 ansible_python_interpreter=/usr/bin/python3
10.0.0.13 ansible_python_interpreter=/usr/bin/python3

[elkservers]
10.1.0.4 ansible_python_interpreter=/usr/bin/python3
```


- Run the playbook, and navigate to http://[your.VM.IP]:5601/app/kibana. to check that the installation worked as expected.

_TODO: Answer the following questions to fill in the blanks:_
- _Which file is the playbook? Where do you copy it? The Filebeat configuration. Copy /etc/ansible/filebeat-config.yml to /etc/filebeat/filebeat.yml
- _Which file do you update to make Ansible run the playbook on a specific machine? How do I specify which machine to install the ELK server on versus which to install Filebeat on? update filebeat-config.yml -- specify which machine to install by updating the host files with ip addresses of web/elk servers and selecting which group to run on in ansible.
- _Which URL do you navigate to in order to check that the ELK server is running? http://[your.VM.IP]:5601/app/kibana.

_As a **Bonus**, provide the specific commands the user will need to run to download the playbook, update the files, etc._
