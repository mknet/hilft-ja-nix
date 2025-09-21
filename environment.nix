# Umgebungsvariablen für den Akkoma Server
# Passen Sie diese Werte an Ihre Domain an

{
  current = {
    # Ihre Domain (z.B. "example.com")
    domain = "example.com";
    
    # Admin E-Mail für Let's Encrypt Zertifikate
    email = "admin@example.com";
    
    # Server Hostname
    hostname = "akkoma-server";
    
    # PostgreSQL Datenbank-Konfiguration
    database = {
      name = "akkoma";
      user = "akkoma";
      password = "secure_password_here";  # Ändern Sie dies!
    };
    
    # Akkoma Konfiguration
    akkoma = {
      # Secret für Akkoma (generieren Sie ein sicheres!)
      secret = "change_this_secret_key";
      
      # Admin Benutzername
      admin_user = "admin";
      
      # Admin E-Mail
      admin_email = "admin@example.com";
    };
  };
}
