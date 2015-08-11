include_recipe 'deploy'

node[:deploy].each do |application, deploy|

  next unless deploy[:application_type] == 'rails' && node[:opsworks][:instance][:layers].include?('rails-app')

  elasticsearch_hosts = []
  if node[:opsworks][:layers][:search].present?
    node[:opsworks][:layers][:search][:instances].each do |instance_name, instance_config|
      elasticsearch_hosts << "#{instance_config[:private_dns_name]}:9200"
    end
  end

  template "#{node[:deploy][application][:deploy_to]}/shared/config/elasticsearch.yml" do
    source "elasticsearch.yml.erb"
    mode "0660"
    owner node[:deploy][application][:user]
    group node[:deploy][application][:group]

    variables(
      :hosts => elasticsearch_hosts
    )
  end

end
