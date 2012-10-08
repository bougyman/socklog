#
# Cookbook Name:: socklog
# Recipe:: ucspi-tcp
#
# Copyright 2012, Kevin Berry
#
# See LICENSE at the top-level directory.
#

include_recipe "socklog::default"

package "ipsvd" do
  action :install
end

execute "socklog-conf ucspi-tcp" do
  command "socklog-conf ucspi-tcp #{node.socklog.runas} #{node.socklog.loguser}"
  creates "/etc/sv/socklog-ucspi-tcp" # Don't bother if it already exists
  action :run
end

link "socklog-ucspi-tcp" do
  target_file File.join(node[:runit][:service_dir], "socklog-ucspi-tcp")
  to "/etc/sv/socklog-ucspi-tcp"
end
