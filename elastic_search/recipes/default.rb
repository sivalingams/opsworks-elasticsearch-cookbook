include_recipe 'deploy'

node[:deploy].each do |application, deploy|

  next unless deploy[:application_type] == 'rails' && node[:opsworks][:instance][:layers].include?('rails-app')

  template "#{node[:deploy][application][:deploy_to]}/shared/config/elasticsearch.yml" do
    source "elasticsearch.yml.erb"
    mode "0660"
    owner node[:deploy][application][:user]
    group node[:deploy][application][:group]

    variables(
      :hosts => node[:deploy][application][:elasticsearch][:hosts]
    )

    only_if do
      node[:deploy][application][:elasticsearch].present? && node[:deploy][application][:elasticsearch][:hosts].present?
    end
  end

end
