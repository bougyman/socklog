#
# Cookbook Name:: socklog
# Recipe:: default
#
# Copyright 2012, Kevin Berry
#
# See LICENSE at the top level directory
#
package "socklog" do
  action :install
end

case node[:platform]
when "debian","ubuntu"
  node.socklog.runas = "nobody"
  node.socklog.loguser = "log"
when "arch"
  node.socklog.runas = "root"
  node.socklog.loguser = "daemon"
end

if ["debian","ubuntu"].include? node[:platform]
  package "socklog-run" do
    action :install
  end
else
  execute "socklog-conf unix" do
    command "socklog-conf unix #{node.socklog.runas} #{node.socklog.loguser}"
    creates "/etc/sv/socklog-unix" # Don't bother if it already exists
    action :run
  end

  link "socklog-unix" do
    target_file File.join(node[:runit][:service_dir], "socklog")
    to "/etc/sv/socklog-unix"
  end
end

template "/etc/sv/socklog-unix/log/run" do
  source "unix/run.erb"
  mode   "640"
  owner  node.socklog.loguser
end
