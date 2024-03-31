{ inputs, ... }: {

  imports = [
    inputs.xremap.homeManagerModules.default
  ];

  services.xremap = {
    withHypr = true;

    config = {
      modmap = [
        # {
        #   name = "Capslock to Super";
        #   remap = {
        #     capslock = "Super_L";
        #   };
        # }
      ];
    };
  };
}
