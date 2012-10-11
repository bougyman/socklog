#
# Cookbook Name:: socklog
# Recipe:: inet
#
# Copyright 2012, Kevin Berry
#
# See LICENSE at the top-level directory.
#

include_recipe "socklog::default"

execute "socklog-conf inet" do
  command "socklog-conf inet #{node.socklog.runas} #{node.socklog.loguser}"
  creates "/etc/sv/socklog-inet" # Don't bother if it already exists
  action :run
end

execute "restart_inet_log" do
  command "sv t #{File.join(node[:runit][:service_dir], "socklog-inet", "log")}"
  action :nothing
end

template "/etc/sv/socklog-inet/log/run" do
  source "inet/run.erb"
  mode   "750"
  owner  node.socklog.loguser
  notifies :run, "execute[restart_inet_log]"
end

link "socklog-inet" do
  target_file File.join(node[:runit][:service_dir], "socklog-inet")
  to "/etc/sv/socklog-inet"
end
