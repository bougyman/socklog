#
# Cookbook Name:: socklog
# Recipe:: default
#
# Copyright 2012, Kevin Berry
#
# See LICENSE at the top level directory
#

case node[:platform]
when "debian","ubuntu"
  package "socklog" do
    action :install
  end
  node.set["socklog"]["runas"] = "nobody"
  node.set["socklog"]["log_user"] = "log"
when "arch"
  begin
    include_recipe "pacman"
    pacman_aur "socklog-dietlibc" do
      action [:build, :install]
    end
  rescue
    package "socklog" do
      action :install
    end
  end
  node.set['socklog']['runas'] = "root"
  node.set['socklog']['log_user'] = "daemon"
else
  package "socklog" do
    action :install
  end
end

