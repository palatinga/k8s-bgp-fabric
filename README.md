# k8s bgp fabric

Exposing Kubernetes services on bare metal with BGP, in a fully reproducible datacenter lab with every failure measured

## Problem

Kubernetes has no built-in load balancer outside the cloud. On bare metal,
a `Service` of type `LoadBalancer` stays `<pending>` forever. The usual fix
is to make the cluster announce service IPs over BGP. The routers then spread
traffic across the nodes (ECMP) and stop sending to a node when it fails.

Making it work is the easy part. What I wanted to know is how it *fails*:
how long traffic is lost when a node or link dies, why it happens, and how
to cut that time down. This project builds the full setup and measures it.

## What this lab covers

- A leaf-spine datacenter fabric running eBGP (FRR)
- A k8s cluster (kind + Cilium) wired into the fabric like physical servers
- Service IPs announced via MetalLB, then migrated to Cilium's BGP Control Plane
- Fault injection and downtime measurement for every stage
- Hardening: prefix filters, BGP authentication, graceful restart
- Optional: hybrid connectivity to AWS over IPsec + BGP

## Architecture

_Work in progress._

## Results

_Work in progress — measurements are added as each stage is completed._

## How to run

_Work in progress._
