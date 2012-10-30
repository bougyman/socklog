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
  programs = new_resource.programs || []
  log_name = new_resource.log_name || new_resource.name
  if( (new_resource.programs.nil? || new_resource.programs == []) && 
      (new_resource.include_patterns.nil? || new_resource.include_patterns == []) && 
      new_resource.facility.nil? )
    programs << log_name
  end

  directory ::File.join(node[:runit][:sv_dir], "socklog-#{new_resource.type}", "log", "main", log_name) do
    action :create
    owner node.socklog.log_user
    group node.socklog.log_group
    mode 0775
    not_if { ::File.directory?(::File.join(node[:runit][:sv_dir], "socklog-#{new_resource.type}", "log", "main", log_name)) }
  end

  parse_template new_resource.type

  if new_resource.exclude_programs_from_main
    new_resource.exclude_programs_from_main.each do |program|
      ruby_block "exclude_#{log_name}_#{program}_from_#{new_resource.type}_main" do
        block do
          node.socklog[new_resource.type]["main"]["exclude_patterns"] << "*.*: *:*:* #{program}[*"
        end
        not_if { node.socklog[new_resource.type]["main"]["exclude_patterns"].include? "*.*: *:*:* #{program}[*" }
        notifies :create, "socklog_log[unix-main]"
      end
    end
  end

  ruby_block "add_#{log_name}_log" do
    block do
      node.socklog[new_resource.type]['logs'] << log_name
      node.save
    end
    not_if { node.socklog[new_resource.type]['logs'].include? log_name }
    notifies :create, "template[#{::File.join(node[:runit][:sv_dir], "socklog-#{new_resource.type}", "log", "run")}]"
  end

  template ::File.join(node[:runit][:sv_dir], "socklog-#{new_resource.type}", "log", "main", log_name, "config") do
    owner node.socklog.log_user
    group node.socklog.log_group
    source "config.erb"
    cookbook "socklog"
    mode "640"
    notifies :run, "execute[restart_#{new_resource.type}_log]"
    variables({:log => new_resource, :programs => programs})
  end

  if new_resource.var_log_link
    file new_resource.var_log_link do
      action :delete
      backup 1
      not_if { ::File.symlink?(new_resource.var_log_link) }
      only_if { ::File.exists?(new_resource.var_log_link) }
    end

    link new_resource.var_log_link do
      to ::File.join(node[:runit][:sv_dir], "socklog-#{new_resource.type}" , "log", "main", log_name, "current")
    end
  end
end

action :delete do
  log_name = new_resource.log_name || new_resource.name

  parse_template new_resource.type

  ruby_block "remove_log" do
    block do
      node.socklog[new_resource.type]['logs'].delete log_name
      node.save
    end
    only_if { node.socklog[new_resource.type]['logs'].include? log_name }
    notifies :create, "template[/etc/sv/socklog-#{new_resource.type}/log/run]"
  end
end
