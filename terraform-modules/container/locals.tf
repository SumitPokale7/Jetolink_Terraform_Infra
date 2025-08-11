locals {
  ecs_ports = {
    for pair in flatten([
      for svc_name, svc in var.ecs_services : [
        for mapping in svc.portMappings : {
          key   = "${svc_name}-${mapping.containerPort}"
          value = mapping.containerPort
        }
      ]
    ]) : pair.key => pair.value
  }
}
