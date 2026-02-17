module "gcl_to_grafana" {
    source  = "git@github.com:KaveTech/tf-gcp-gcl-to-grafana.git"
  
    project = { 
        id = local.project.id 
    }
    grafana = {
      create_datasource = true
    }

}