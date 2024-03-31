{ inputs, ... }: {

  imports = [
    inputs.xremap.homeManagerModules.default
  ];

  services.xremap = {
    withHypr = true;

    config = {
      keymap = { };
    };
  };
}
