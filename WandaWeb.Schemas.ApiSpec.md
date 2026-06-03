# `WandaWeb.Schemas.ApiSpec`
[🔗](https://github.com/trento-project/wanda/blob/main/lib/wanda_web/schemas/api_spec.ex#L4)

OpenApi specification entry point

`api_version` must be provided to specify the version of this openapi specification

Example:
  use WandaWeb.OpenApi.ApiSpec,
    api_version: "v1"

  # For all endpoints:
  use WandaWeb.OpenApi.ApiSpec,
    api_version: "all"

  # For unversioned endpoints:
  use WandaWeb.OpenApi.ApiSpec,
    api_version: "unversioned"

# `build_paths_for_version`

# `build_version`

---

*Consult [api-reference.md](api-reference.md) for complete listing*
