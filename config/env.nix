let
  PORTS = {
    API = "5150";
    DOCS = "4000";
    ARCH = "5173";
    ADMIN = "8000";
    GRAPH = "4211";
    POSTGRES = "54322";
    NODE_MODULES_INSPECTOR = "7800";
  };

  URLS = {
    BASE = "https://robertbabaev.tech";
    LOCALHOST = "http://localhost:";
  };

  FLAGS = {
    SQLITE = "false";
    SUPABASE = "false"; # requires docker
  };
in {
  env = rec {
    SQLITE = "${FLAGS.SQLITE}";
    SUPABASE = "${FLAGS.SUPABASE}";

    ZELLIJ_AUTO_EXIT = "true";
    ZELLIJ_AUTO_ATTACH = "true";

    # DATABASE_URI = "postgresql://postgres:postgres@127.0.0.1:${PORTS.POSTGRES}/postgres";
    # PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS = "true";
    # PLAYWRIGHT_NODEJS_PATH = "${pkgs.nodejs_22}/bin/node";

    BASE_URL = URLS.BASE;
    SUPABASE_STUDIO_URL = "${URLS.LOCALHOST}54323";
    APP_LOCAL_URL = "${URLS.LOCALHOST}${PORTS.APP}";
    API_LOCAL_URL = "${URLS.LOCALHOST}${PORTS.API}";
    DOCS_LOCAL_URL = "${URLS.LOCALHOST}${PORTS.DOCS}";
    ADMIN_LOCAL_URL = "${URLS.LOCALHOST}${PORTS.ADMIN}";
    GRAPH_LOCAL_URL = "${URLS.LOCALHOST}${PORTS.GRAPH}";
    ARCHITECTURE_LOCAL_URL = "${URLS.LOCALHOST}${PORTS.ARCH}";

    # PG_COLOR = "always";
    # S3_ACCESS_KEY_ID=""
    # S3_BUCKET="staging"
    # S3_REGION="us-east-1"
    # S3_SECRET_ACCESS_KEY=""
    # S3_ENDPOINT="https://[ID].supabase.co/storage/v1/s3"

    CORS_WHITELIST_ORIGINS = "${URLS.LOCALHOST}${PORTS.APP},${URLS.LOCALHOST}${PORTS.API},${URLS.BASE}";
    CSRF_WHITELIST_ORIGINS = "${URLS.LOCALHOST}${PORTS.APP},${URLS.LOCALHOST}${PORTS.API},${URLS.BASE}";
  };
}
