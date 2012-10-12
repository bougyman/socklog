def parse_template(log_type)
  execute "restart_#{log_type}_log" do
    command "sv t #{::File.join(node[:runit][:sv_dir], "socklog-#{log_type}", "log")}"
    action :nothing
  end

  template ::File.join(node[:runit][:sv_dir], "socklog-#{log_type}", "log", "run") do
    source "#{log_type}/run.erb"
    cookbook "socklog"
    mode   "770"
    owner  node.socklog.log_user
    group  node.socklog.log_group
    action :nothing
    notifies :run, "execute[restart_#{log_type}_log]"
  end
end

action :create do
  directory ::File.join(node[:runit][:sv_dir], "socklog-#{new_resource.type}", "log", "main", new_resource.name) do
    action :create
    owner node.socklog.log_user
    group node.socklog.log_group
    mode 0775
    not_if { ::File.directory?(::File.join(node[:runit][:sv_dir], "socklog-#{new_resource.type}", "log", "main", new_resource.name)) }
  end

  parse_template new_resource.type

  ruby_block "add_log" do
    block do
      node.set['socklog'][new_resource.type]['logs'][new_resource.name] = true
      node.save
    end
    not_if { node.socklog[new_resource.type]['logs'][new_resource.name] }
    notifies :create, "template[#{::File.join(node[:runit][:sv_dir], "socklog-#{new_resource.type}", "log", "run")}]", :immediately
  end

  template ::File.join(node[:runit][:sv_dir], "socklog-#{new_resource.type}", "log", "main", new_resource.name, "config") do
    owner node.socklog.log_user
    group node.socklog.log_group
    source "config.erb"
    cookbook "socklog"
    mode "640"
    notifies :run, "execute[restart_#{new_resource.type}_log]"
    variables({:log => new_resource})
  end

  if new_resource.var_log_link
    file new_resource.var_log_link do
      action :delete
      backup 1
      not_if { ::File.symlink?(new_resource.var_log_link) }
      only_if { ::File.exists?(new_resource.var_log_link) }
    end

    link new_resource.var_log_link do
      to ::File.join(node[:runit][:sv_dir], "socklog-#{new_resource.type}" , "log", "main", new_resource.name, "current")
    end
  end
end

action :delete do

  parse_template new_resource.type

  ruby_block "remove_log" do
    block do
      node.socklog[new_resource.type]['logs'][new_resource.name].delete
      node.save
    end
    only_if { node.socklog[new_resource.type]['logs'][new_resource.name] }
    notifies :create, "template[/etc/sv/socklog-#{new_resource.type}/log/run]"
  end
end
