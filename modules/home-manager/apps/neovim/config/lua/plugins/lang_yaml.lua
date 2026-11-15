---@type LazySpec
return {
  {
    "b0o/SchemaStore.nvim",
    lazy = true,
    dependencies = {
      {
        "AstroNvim/astrolsp",
        optional = true,
        ---@type AstroLSPOpts
        opts = {
          ---@diagnostic disable: missing-fields
          config = {
            yamlls = {
              on_new_config = function(config)
                config.settings.yaml.schemas = vim.tbl_deep_extend(
                  "force",
                  config.settings.yaml.schemas or {},
                  require("schemastore").yaml.schemas()
                )
              end,
              settings = {
                yaml = {
                  schemaStore = { enable = false, url = "" },
                  schemas = {
                    kubernetes = {
                      "clusterrole.yaml",
                      "clusterrolebinding.yaml",
                      "configmap.yaml",
                      "cronjob.yaml",
                      "daemonset.yaml",
                      "deployment.yaml",
                      "ingress.yaml",
                      "job.yaml",
                      "namespace.yaml",
                      "networkpolicy.yaml",
                      "persistentvolume.yaml",
                      "persistentvolumeclaim.yaml",
                      "role.yaml",
                      "rolebasedaccesscontrol.yaml",
                      "rolebinding.yaml",
                      "secret.yaml",
                      "service.yaml",
                      "serviceaccount.yaml",
                      "statefulset.yaml",
                    },
                    ["https://raw.githubusercontent.com/fluxcd-community/flux2-schemas/refs/heads/main/kustomization-kustomize-v1.json"] = {
                      "ks.yaml",
                    },
                  },
                },
              },
            },
          },
        },
      },
    },
  },
  {
    "AstroNvim/astrolsp",
    optional = true,
    ---@param opts AstroLSPOpts
    opts = {
      config = {
        yaml = {
          -- Cloudformation custom tags for yaml_ls
          customTags = {
            "!fn",
            "!And",
            "!If",
            "!Not",
            "!Equals",
            "!Or",
            "!FindInMap sequence",
            "!Base64",
            "!Cidr",
            "!Ref",
            "!Ref Scalar",
            "!Sub",
            "!GetAtt",
            "!GetAZs",
            "!ImportValue",
            "!Select",
            "!Split",
            "!Join sequence",
          },
        },
      },
    },
  },
}
