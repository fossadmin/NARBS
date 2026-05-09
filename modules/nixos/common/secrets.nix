{ inputs, config, ... }:
{
  imports = [ inputs.sops-nix.nixosModules.sops ];

  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml; # Your encrypted file
    validateSopsFiles = false;

    # Use your existing SSH keys to decrypt the secrets
    age.keyFile = "/var/lib/sops-nix/key.txt";

    secrets = {
      "dashboard/api_key" = { };
      "admin/password" = {
        neededForUsers = true;
      };
    };
  };
}
