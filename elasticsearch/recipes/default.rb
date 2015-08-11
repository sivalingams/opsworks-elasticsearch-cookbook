include_recipe 'deploy'

node[:deploy].each do |application, deploy|

  next unless deploy[:application_type] == 'rails' && node[:opsworks][:instance][:layers].include?('rails-app')

  if node[:deploy][application][:elasticsearch].present? && node[:deploy][application][:elasticsearch][:hosts].present?

    # Create elasticsearch.yml
    template "#{node[:deploy][application][:deploy_to]}/shared/config/elasticsearch.yml" do
      source "elasticsearch.yml.erb"
      mode "0660"
      owner node[:deploy][application][:user]
      group node[:deploy][application][:group]

      variables(
        :hosts => node[:deploy][application][:elasticsearch][:hosts]
      )
    end

    # Create Symlink
    node.normal[:deploy][application][:symlink_before_migrate].merge!({"config/elasticsearch.yml" => "config/elasticsearch.yml"})
  end

end
