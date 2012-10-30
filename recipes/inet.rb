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

link "/var/log/inet-messages" do
  to File.join(node[:runit][:sv_dir], "socklog-inet", "log", "main", "main", "current")
end

template File.join(node[:runit][:sv_dir], "socklog-inet", "log", "main", "main", "config") do
  source "config-inet.erb"
  variables { :new_resource => OpenStruct.new(
                                              :exclude_patterns => node.socklog.inet.main.exclude_patterns,
                                              :size => node.socklog.inet.main.size || 100000000,
                                              :num_files_max => node.socklog.inet.main.num_file_max || 10,
                                              :num_files_min => node.socklog.inet.main.num_file_min || 5,
                                              :rotate_seconds => node.socklog.inet.main.rotate_seconds || 604800,
                                            )
            }
end

link "socklog-inet" do
  target_file File.join(node[:runit][:service_dir], "socklog-inet")
  to "/etc/sv/socklog-inet"
end
