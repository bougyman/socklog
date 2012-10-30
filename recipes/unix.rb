include_recipe "socklog"
require "ostruct"

if ["debian","ubuntu"].include? node[:platform]
  package "socklog-run" do
    action :install
  end
  # We don't like debian's name for this service, prefer just socklog
  file File.join(node[:runit][:service_dir], "socklog-unix") do
    action :delete
  end
else
  execute "socklog-conf unix" do
    command "socklog-conf unix #{node.socklog.runas} #{node.socklog.log_user}"
    creates "/etc/sv/socklog-unix" # Don't bother if it already exists
    action :run
  end
end

file "/var/log/messages" do
  action :delete
  backups 1
  not_if { File.symlink?("/var/log/messages") }
end

link "/var/log/messages" do
  to File.join(node[:runit][:sv_dir], "socklog-unix", "log", "main", "main", "current")
end

template File.join(node[:runit][:sv_dir], "socklog-unix", "log", "main", "main", "config") do
  source "config.erb"
  variables { :new_resource => OpenStruct.new(
                                              :exclude_patterns => node.socklog.unix.main.exclude_patterns,
                                              :size => node.socklog.unix.main.size || 100000000,
                                              :num_files_max => node.socklog.unix.main.num_file_max || 10,
                                              :num_files_min => node.socklog.unix.main.num_file_min || 5,
                                              :rotate_seconds => node.socklog.unix.main.rotate_seconds || 604800,
                                            )
            }
end

link "socklog-unix" do
  target_file File.join(node[:runit][:service_dir], "socklog")
  to "/etc/sv/socklog-unix"
end


