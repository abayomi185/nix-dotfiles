{
  lib,
  fetchFromGitHub,
  stdenvNoCC,
  nodejs,
  fetchNpmDeps,
  buildPackages,
  php83,
  nixosTests,
  nix-update-script,
  dataDir ? "/var/lib/firefly-iii-data-importer",
}: let
  pname = "firefly-iii-data-importer";
  version = "1.5.5";

  src = fetchFromGitHub {
    owner = "firefly-iii";
    repo = "data-importer";
    rev = "v${version}";
    hash = "sha256-XnPdoNtUoJpOpKVzQlFirh7u824H4xKAe2VRXfGIKeg=";
  };
in
  stdenvNoCC.mkDerivation (finalAttrs: {
    inherit pname src version;

    buildInputs = [php83];

    nativeBuildInputs = [
      nodejs
      nodejs.python
      buildPackages.npmHooks.npmConfigHook
      php83.composerHooks.composerInstallHook
      php83.packages.composer-local-repo-plugin
    ];

    composerNoDev = true;
    composerNoPlugins = true;
    composerNoScripts = true;
    composerStrictValidation = true;
    strictDeps = true;

    vendorHash = "sha256-EjEco8zBR787eQuPhNsRScfuPQ6eS6TIJmMJOcmZA+Q=";

    npmDeps = fetchNpmDeps {
      inherit src;
      name = "${pname}-npm-deps";
      hash = "sha256-VP1wM0+ca17aQU4FJ9gSbT2Np/sxb8wZ4pCJ6FV1V7w=";
    };

    composerRepository = php83.mkComposerRepository {
      inherit
        (finalAttrs)
        pname
        src
        vendorHash
        version
        ;
      composerNoDev = true;
      composerNoPlugins = true;
      composerNoScripts = true;
      composerStrictValidation = true;
    };

    preInstall = ''
      npm run build --workspace=v2
    '';

    passthru = {
      phpPackage = php83;
      tests = nixosTests.firefly-iii-data-importer;
      updateScript = nix-update-script {};
    };

    postInstall = ''
      rm -R $out/share/php/firefly-iii-data-importer/{storage,bootstrap/cache,node_modules}
      mv $out/share/php/firefly-iii-data-importer/* $out/
      rm -R $out/share
      ln -s ${dataDir}/storage $out/storage
      ln -s ${dataDir}/cache $out/bootstrap/cache
    '';

    meta = {
      changelog = "https://github.com/firefly-iii/data-importer/releases/tag/v${version}";
      description = "Firefly III Data Importer can import data into Firefly III.";
      homepage = "https://github.com/firefly-iii/data-importer";
      license = lib.licenses.agpl3Only;
    };
  })
