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
  command "socklog-conf inet #{node.socklog.runas} #{node.socklog.log_user}"
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
  owner  node.socklog.log_user
  group  node.socklog.log_group
  notifies :run, "execute[restart_inet_log]"
end

socklog_log "inet-unix" do
  log_name "main"
  exclude_patterns node.socklog.inet.main.exclude_patterns
  var_log_link "/var/log/inet-messages"
end

link "socklog-inet" do
  target_file File.join(node[:runit][:service_dir], "socklog-inet")
  to "/etc/sv/socklog-inet"
end
