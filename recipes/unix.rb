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
  mode 042750
end

execute "hup_main_log" do
  command "sv hup #{node.runit.sv_dir}/socklog-unix/log"
  action :nothing
end

execute "rotate_main_log" do
  command "sv a #{node.runit.sv_dir}/socklog-unix/log"
  action :nothing
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

node.socklog.unix.logs.each do |logdir|
  directory "/var/log/socklog/#{logdir}" do
    owner node.socklog.log_user
    group node.socklog.log_group
    mode 042750
    notifies :run, "execute[rotate_main_log]"
  end

  next if logdir == "main"
  file "/var/log/#{logdir}" do
    action :delete
    backup 1
    not_if { File.directory?("/var/log/#{logdir}") || (File.exists?("/var/log/#{logdir}") && File.symlink?("/var/log/#{logdir}")) }
  end

  link "/var/log/#{logdir}" do
    to "/var/log/socklog/#{logdir}/current"
    not_if { File.directory?("/var/log/#{logdir}") || (File.exists?("/var/log/#{logdir}") && File.symlink?("/var/log/#{logdir}")) }
  end
end
