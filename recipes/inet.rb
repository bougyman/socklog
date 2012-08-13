#
# Cookbook Name:: socklog
# Recipe:: inet
#
# Copyright 2012, Kevin Berry
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

execute "socklog-conf inet" do
  command "socklog-conf inet #{runas} #{loguser}"
  creates "/etc/sv/socklog-inet" # Don't bother if it already exists
  action :run
end

link "socklog-inet" do
  target_file File.join(node[:runit][:service_dir], "socklog-inet")
  to "/etc/sv/socklog-inet"
end
