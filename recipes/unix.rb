include_recipe "socklog"

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

directory "/var/log/socklog" do
  owner node.socklog.log_user
  group node.socklog.log_group
end

Dir["/var/log/socklog/*"].each do |dir|
  next unless File.directory? dir
  directory dir do
    owner node.socklog.log_user
    group node.socklog.log_group
    mode 2750
  end
end

socklog_log "unix-main" do
  var_log_link "/var/log/messages"
  exclude_patterns node.socklog.unix.main.exclude_patterns
  log_name "main"
end

link "socklog-unix" do
  target_file File.join(node[:runit][:service_dir], "socklog")
  to "/etc/sv/socklog-unix"
end


