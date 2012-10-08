
default.socklog.runas = "nobody"
default.socklog.loguser = "daemon"
default.socklog.inet.logs = %w{main auth cron daemon debug ftp kern local mail news syslog user}
default.socklog.unix.logs = %w{main auth cron daemon debug ftp kern local mail news syslog user}

default.socklog.ucspi_tcp.port = "10116"
