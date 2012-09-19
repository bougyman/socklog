#
# Cookbook Name:: socklog
# Recipe:: ucspi-tcp
#
# Copyright 2012, Kevin Berry
#
# See LICENSE at the top-level directory.
#

include_recipe "socklog::default"

package "ipvsd" do
  action :install
end

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

execute "socklog-conf ucspi-tcp" do
  command "socklog-conf ucspi-tcp #{runas} #{loguser}"
  creates "/etc/sv/socklog-ucspi-tcp" # Don't bother if it already exists
  action :run
end

link "socklog-ucspi-tcp" do
  target_file File.join(node[:runit][:service_dir], "socklog-ucspi-tcp")
  to "/etc/sv/socklog-ucspi-tcp"
end
