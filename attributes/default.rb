
default.socklog.runas = "nobody"
default.socklog.log_user = "daemon"
default.socklog.log_group = "adm"
default.socklog.inet.logs = %w{main}
default.socklog.unix.logs = %w{main auth cron daemon debug ftp kern local mail news syslog user}
default.socklog.ucspi_tcp.port = "10116"
