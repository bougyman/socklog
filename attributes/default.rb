
default.socklog.runas = "log"
default.socklog.log_user = "log"
default.socklog.log_group = "adm"
default.socklog.inet.logs = ["main"]
default.socklog.unix.logs = %w{main auth cron daemon debug ftp kern local mail news syslog user}
default.socklog.unix.main.exclude_patterns = []
default.socklog.inet.main.exclude_patterns = []
default.socklog.ucspi_tcp.port = "10116"
