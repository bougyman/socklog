action :create do
  ruby_block "add_log" do
    block do
      node.socklog[new_resource.type]['logs'] << new_resource.name
      node.save
    end
    not_if node.socklog[new_resource.type]['logs'].include? new_resource.name
    notifies :create, "template[/etc/sv/socklog-#{new_resource.type}/log/run]"
  end
end

action :delete do
  ruby_block "remove_log" do
    block do
      node.socklog[new_resource.type]['logs'].delete new_resource.name
      node.save
    end
    only_if node.socklog[new_resource.type]['logs'].include? new_resource.name
    notifies :create, "template[/etc/sv/socklog-#{new_resource.type}/log/run]"
  end
end
