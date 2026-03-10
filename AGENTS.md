# AGENTS.md

Guia para agentes de codigo que trabajen en repositorios IaC de Kave Tech basados en este template.

## Scope y precedencia

- Este archivo define el comportamiento por defecto para nuevos repositorios creados desde `iac-template`.
- Si existe otro `AGENTS.md` mas cercano al archivo editado, ese archivo local tiene prioridad.

## Contexto de plataforma (Kave)

- Stack principal: Terraform para Google Cloud Platform (GCP).
- Estrategia operativa: `template-first`, minimo privilegio y estandarizacion entre proyectos.
- Computo por defecto: Cloud Run v2 detras de External Application Load Balancer.
- Observabilidad por defecto: integracion GCL -> Grafana mediante modulo reutilizable.
- Secretos:
  - En repositorio: SOPS + Google KMS.
  - En runtime: Secret Manager (y Vault/ESO en casos GKE).

### Tecnologias GCP mas usadas en estos IaC

- Resource Manager: `google_project`, `google_folder`, `google_project_service`.
- IAM y cuentas de servicio: `google_project_iam_member`, `google_service_account`.
- Networking: VPC/subredes, `google_vpc_access_connector`, Private Service Access (`google_service_networking_connection`), Cloud Router/NAT en topologias GKE.
- Compute principal: `google_cloud_run_v2_service` + `google_compute_region_network_endpoint_group` (serverless NEG).
- Load balancing y TLS: IP global, `google_compute_url_map`, proxies HTTP/HTTPS, `google_compute_managed_ssl_certificate`, `EXTERNAL_MANAGED`.
- Datos y estado: Cloud SQL, Cloud Storage (state y buckets de app), Secret Manager, KMS.
- Plataforma contenedores: Artifact Registry, Cloud Build (segun repositorio), GKE Autopilot en plataformas especificas.
- DNS: Cloudflare como proveedor dominante para registros publicos.

### Providers que debes esperar en la organizacion

- Base: `hashicorp/google`, `hashicorp/google-beta`, `carlpett/sops`.
- Frecuentes segun caso: `grafana/grafana`, `cloudflare/cloudflare`.
- En repos con Kubernetes/plataforma: `kubernetes`, `helm`, `vault`.

### Modulos Terraform privados KaveTech mas comunes

- `tf-gcp-state-bucket`: backend remoto de estado en GCS.
- `tf-gcp-gcl-to-grafana`: export de logs de GCP y datasource de Grafana.
- `tf-gcp-cloud-sql`: provisionado estandar de Cloud SQL.
- `tf-cloudflare-dns-record`: gestion de records DNS en Cloudflare.
- `tf-helm-external-secrets` y `tf-k8s-external-secrets`: integracion ESO + Vault en GKE.
- `tf-vault-gke-publisher`: publicacion de secretos/credenciales de clustres en Vault.
- Modulos de caso de uso puntual (segun repo): `tf-gcp-azure-iap`, `tf-gcp-lalaguna`.

## Principios que un agente debe respetar

1. No romper el patron del template sin motivo claro.
2. Preferir cambios pequenos, reversibles y consistentes con naming existente.
3. Mantener IaC declarativo: evitar hardcodear valores sensibles o manuales.
4. Aplicar minimo privilegio en IAM para nuevas service accounts.
5. No introducir drift deliberado entre Terraform y despliegues de aplicacion.

## Convenciones estructurales

- Archivos raiz en `*.tf`, separados por dominio (`project.tf`, `state.tf`, `run.tf`, `lb.tf`, `dns.tf`, etc.).
- `locals.tf` centraliza `base_name`, `pretty_name`, `region` y referencias comunes de proyecto.
- Modulos privados KaveTech por `git@github.com:KaveTech/...` con `?ref=<tag>` pinneado.
- Providers y versiones en `versions.tf`; configuracion de provider adicional en `providers.tf`.
- En repositorios IaC (root), evitar `vars.tf`: para este tipo de valores se usa `locals.tf`.
- Reservar `variables.tf`/`vars.tf` para modulos reutilizables de Terraform, no para el IaC de aplicacion.

### Nomenclatura y agrupacion de archivos `.tf`

- Objetivo: que al ejecutar `ls` los ficheros queden ordenados por grupos funcionales y relaciones de dependencia.
- Regla acordada: usar el patron `<recurso>.<dependencia_del_recurso_anterior_si_corresponde>.tf`.
- Mantener prefijos estables por dominio (por ejemplo, `run`, `lb`, `vpc`, `registry`, `kms`, `dns`).
- Anidar detalle tecnico por sufijos incrementales (por ejemplo, `sa`, `iam`, `neg`, `storage`, `secrets`).
- Evitar nombres genericos (`main.tf`, `misc.tf`, `temp.tf`) cuando el recurso ya tiene grupo claro.

Ejemplos validos:

- `run.tf`
- `run.sa.tf`
- `run.sa.iam.tf`
- `run.registry.tf`
- `run.registry.iam.tf`
- `lb.tf`
- `lb.neg.tf`

Practica recomendada:

- Si un archivo depende conceptualmente del anterior, extender el nombre en cascada en lugar de crear un nombre nuevo no relacionado.
- Mantener esta convencion en nuevos repositorios y al refactorizar estructura existente.

## Workspaces y entornos

Patron recomendado para proyectos multi-entorno:

- `default` representa `sys` (recursos compartidos: state bucket, KMS, etc.).
- `dev` y `pro` para entornos de aplicacion.

Reglas de `count` tipicas:

```hcl
# Solo sys/default
count = terraform.workspace == "default" ? 1 : 0

# Solo entornos de aplicacion
count = terraform.workspace == "default" ? 0 : 1
```

Cuando uses `count`, referenciar siempre el indice correcto (`[0]`) al consumir outputs/atributos.

## Flujo bootstrap esperado (repos nuevos)

1. Completar `locals.tf` (`base_name`, `pretty_name`) y ajustes de `project.tf`.
2. Revisar providers y versiones de modulos.
3. `terraform init`
4. Crear bucket de estado:
   - `terraform apply --target=module.state_bucket`
5. Configurar backend `gcs` en `versions.tf` con el bucket creado.
6. Migrar estado:
   - `terraform init -migrate-state`
7. Ejecutar `terraform plan` y `terraform apply` completos.

## Patrones de implementacion recomendados

### Proyecto GCP

- `project_id` con sufijo aleatorio para evitar colisiones globales.
- Labels minimas:
  - `managed-by = terraform`
  - `region = <region>`
  - `environment = <sys|dev|pro>`

### Cloud Run + LB

- Ingress recomendado para servicio privado via LB:
  - `INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER`
- LB externo administrado:
  - `load_balancing_scheme = "EXTERNAL_MANAGED"`
- SSL gestionado por Google (`google_compute_managed_ssl_certificate`) y redireccion HTTP -> HTTPS.
- Si CI/CD gestiona imagen, preservar `lifecycle.ignore_changes` para `template[0].containers[0].image`.

### GKE (cuando aplica)

- Usar GKE Autopilot como patron por defecto en plataformas de cluster.
- Integrar secretos de workloads con Vault + External Secrets Operator.
- Mantener IAM Workload Identity y permisos acotados por namespace/servicio.

### Estado y modulos base

- Mantener `module.state_bucket` en el repositorio salvo razon excepcional.
- Mantener `module.gcl_to_grafana` para estandar de observabilidad.

### Secretos

- Nunca commitear secretos en plano.
- Usar `sops_file` para secretos requeridos por Terraform.
- Para runtime, preferir Secret Manager y referencias por `latest` cuando aplique.

## Lo que NO debe hacer un agente

- No eliminar `prevent_destroy` en recursos criticos (por ejemplo, KMS keys) salvo peticion explicita.
- No introducir providers/modulos sin version o sin justificar su necesidad.
- No desactivar validaciones de pre-commit como solucion rapida.
- No escribir credenciales, tokens o claves reales en `*.tf`, `*.tfvars`, `README` o ejemplos.

## Validacion minima antes de terminar cambios

Ejecutar, como minimo:

```bash
terraform fmt
terraform validate
pre-commit run --all-files
```

Si el cambio afecta recursos en varios workspaces, validar al menos `default` y un workspace de aplicacion (`dev` o `pro`) con `terraform plan`.

## Ejemplos utiles para agentes

### Habilitar API de GCP

```hcl
resource "google_project_service" "apis" {
  for_each = toset([
    "run.googleapis.com",
    "secretmanager.googleapis.com",
  ])

  project            = local.project.id
  service            = each.value
  disable_on_destroy = true
}
```

### Recurso solo en `sys`

```hcl
resource "google_kms_key_ring" "sops" {
  count    = terraform.workspace == "default" ? 1 : 0
  name     = format("%s-sops-keyring", local.base_name)
  project  = local.project.id
  location = local.region
}
```

### Recurso solo en `dev/pro`

```hcl
resource "google_compute_network" "vpc" {
  count                   = terraform.workspace == "default" ? 0 : 1
  name                    = format("%s-vpc", local.base_name)
  project                 = local.project.id
  auto_create_subnetworks = false
}
```

## Checklist rapido para PRs automatizadas

- [ ] El cambio respeta patron de workspaces (`default`/`dev`/`pro`) cuando aplica.
- [ ] No hay secretos en plano ni datos sensibles en diff.
- [ ] Modulos/providers con versiones pinneadas.
- [ ] `terraform fmt`, `terraform validate` y hooks de pre-commit en verde.
- [ ] README actualizado si cambia el flujo operativo del repo.

## Nota final

Este archivo captura la forma de trabajo estandar de Kave para IaC basado en template. Si un repositorio necesita reglas adicionales de dominio, deben definirse en su `AGENTS.md` local y convivir con esta base comun.
