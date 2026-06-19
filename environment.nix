# Umgebungsvariablen für den Helferlein NixOS-Server
# Passen Sie diese Werte an Ihre Domain an

{
  current = {
    domain = "example.com";
    email = "admin@example.com";
    hostname = "helferlein-server";

    database = {
      name = "akkoma";
      user = "akkoma";
      password = "secure_password_here";
    };

    akkoma = {
      secret = "change_this_secret_key";
      admin_user = "admin";
      admin_email = "admin@example.com";
    };

    jitsi = {
      hostname = "meet";
    };

    # helferlein/docker/keycloak
    keycloak = {
      domain = "idm.example.com";
      adminPassword = "change_me";
      databasePassword = "keycloak";
    };

    # helferlein/docker/uptime-kuma
    uptimeKuma = {
      domain = "uptime.example.com";
    };

    # helferlein/docker/pleroma
    pleroma = {
      hostname = "social";
      instanceName = "My Fediverse Instance";
      adminEmail = "admin@example.com";
      notifyEmail = "admin@example.com";
      databaseName = "pleroma";
      databaseUser = "pleroma";
    };

    # helferlein/docker/redpanda
    redpanda = {
      enableConsole = true;
    };
  };
}
