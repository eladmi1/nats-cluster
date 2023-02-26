NATS Cluster Deployment on AWS ECS (Fargate)
This repository contains a deployment plan for a NATS cluster on AWS ECS (Fargate). The cluster consists of 3 servers: 1 seed server and 2 additional servers. 

Tasks on ECS Cluster
1 seed server
2 additional servers
Seed Server Docker Command
["--cluster_name", "NATS", "--cluster", "nats://0.0.0.0:6222", "--http_port", "8222"]

Additional Server Docker Command
["--cluster_name", "NATS", "--cluster", "nats://0.0.0.0:6222", "--routes=nats://ruser:T0pS3cr3t@route.314d.link:6222"]

Route Configuration
Seed server registers to "route.314d.link" R53
Additional servers register to seed cluster using the above Docker command

Monitoring
Seed task exposes monitoring HTTP port on "monitor.314d.link" R53
Check status using curl -v http://monitor.314d.link:8222/routez

Health Check
Python script subscribes and publishes to each server in nested loops over 3 server URLs


High level diagram

![image](https://user-images.githubusercontent.com/50584728/221425683-424667ff-7e46-49e2-b01c-304623207120.png)


