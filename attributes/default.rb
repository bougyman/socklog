
default.socklog.runas = "nobody"
default.socklog.log_user = "daemon"
default.socklog.log_group = "adm"
default.socklog.inet.logs.main = true
%w{main auth cron daemon debug ftp kern local mail news syslog user}.each do |log|
  default.socklog.unix.logs[log] = true
end
default.socklog.ucspi_tcp.port = "10116"
