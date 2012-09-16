#
# Cookbook Name:: socklog
# Recipe:: notify
#
# Copyright 2012, Tj Vanderpoel
#
# See LICENSE at the top-level directory.
#

include_recipe "socklog::default"

case node[:platform]
when "debian","ubuntu"
  runas = "nobody"
  loguser = "log"
when "arch"
  runas = "root"
  loguser = "daemon"
else
  runas = "nobody"
  loguser = "daemon"
end

execute "socklog-conf notify" do
  command "socklog-conf notify #{runas} #{loguser}"
  creates "/etc/sv/socklog-notify" # Don't bother if it already exists
  action :run
end

link "socklog-notify" do
  target_file File.join(node[:runit][:service_dir], "socklog-notify")
  to "/etc/sv/socklog-notify"
end
