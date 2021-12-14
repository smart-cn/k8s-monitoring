# k8s-monitoring
Configs + Install script for installation Prometheus and Grafana in K8s cluster.

Script "**install.sh**" will install Prometheus and Grafana to your K8s cluster, and configure access to them using corresponding prefixes. Also, this script will add Prometheus server as a default data source in Grafana and add some dashboards to the installed Grafana

## Also, Grafana can be runed as separate instance in docker dontainer:

*(Credentials in both cases with docker - will be **admin:admin** and should be changed at first login!)*

**Run Grafana container with persistent storage (recommended)**

    # create a persistent volume for your data in /var/lib/grafana (database and plugins)
    docker volume create grafana-storage    
    # start grafana
    docker run --restart unless-stopped -d -p 8800:3000 --name=grafana -v grafana-storage:/var/lib/grafana grafana/grafana

**Run Grafana container using bind mounts**

You may want to run Grafana in Docker but use folders on your host for the database or configuration. When doing so, it becomes important to start the container with a user that is able to access and write to the folder you map into the container.

    mkdir grafana-data # creates a folder for your data
    ID=$(id -u) # saves your user id in the ID variable    
    # starts grafana with your user id and using the data folder
    docker run --restart unless-stopped -d --user $ID --volume "$PWD/grafana-data:/var/lib/grafana" -p 8800:3000 grafana/grafana
