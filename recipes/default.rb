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
  node.socklog.log_user = "log"
when "arch"
  node.socklog.runas = "root"
  node.socklog.log_user = "daemon"
end

