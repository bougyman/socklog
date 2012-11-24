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

execute "rotate_inet_log" do
  command "sv a #{File.join(node[:runit][:service_dir], "socklog-inet", "log")}"
  action :nothing
end

execute "restart_inet_log" do
  command "sv t #{File.join(node[:runit][:service_dir], "socklog-inet", "log")}"
  action :nothing
end

directory "/var/log/socklog-inet" do
  owner node.socklog.log_user
  group node.socklog.log_group
  mode 02750
  notifies :run, "execute[restart_inet_log]"
  notifies :run, "execute[rotate_inet_log]"
end

socklog_log "inet-unix" do
  log_name "main"
  type "inet"
  exclude_patterns node.socklog.inet.main.exclude_patterns
  var_log_link "/var/log/inet-messages"
end

link "socklog-inet" do
  target_file File.join(node[:runit][:service_dir], "socklog-inet")
  to "/etc/sv/socklog-inet"
end
