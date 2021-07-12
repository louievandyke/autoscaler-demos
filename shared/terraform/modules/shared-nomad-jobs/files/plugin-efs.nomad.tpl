job "plugin-aws-efs-nodes" {
  datacenters = ["dc1"]

  type = "system"



    constraint {
    attribute = "$${node.class}"
    value     = "${namespace}"
    operator  = "="
  }
  
  namespace = "${namespace}"
  
  constraint {
    operator = "distinct_hosts"
    value    = true
  }
  group "nodes" {
    task "plugin" {
      driver = "docker"

      config {
        image = "amazon/aws-efs-csi-driver:master"

        args = [
          "node",
          "--endpoint=unix://tmp/csi.sock",
          "--logtostderr",
          "--v=5",
        ]

        # node plugins must run as privileged jobs because they
        # mount disks to the host
        privileged = true
      }

      csi_plugin {
        id        = "aws-efs"
        type      = "node"
        mount_dir = "/tmp"
      }

      resources {
        cpu    = 512
        memory = 256
      }
    }
  }
}