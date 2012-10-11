#
# Cookbook Name:: socklog
# Recipe:: notify
#
# Copyright 2012, Tj Vanderpoel
#
# See LICENSE at the top-level directory.
#

include_recipe "socklog::default"

execute "socklog-conf notify" do
  command "socklog-conf notify #{node.socklog.runas} #{node.socklog.log_user}"
  creates "/etc/sv/socklog-notify" # Don't bother if it already exists
  action :run
end

link "socklog-notify" do
  target_file File.join(node[:runit][:service_dir], "socklog-notify")
  to "/etc/sv/socklog-notify"
end
