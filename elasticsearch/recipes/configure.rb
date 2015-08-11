include_recipe 'deploy'

node[:deploy].each do |application, deploy|

  next unless deploy[:application_type] == 'rails' && node[:opsworks][:instance][:layers].include?('rails-app')

  template "#{node[:deploy][application][:deploy_to]}/shared/config/elasticsearch.yml" do
    # cookbook 'rails'
    source "elasticsearch.yml.erb"
    mode "0660"
    group deploy[:group]
    owner deploy[:user]
    variables(:database => deploy[:database], :environment => deploy[:rails_env])

    # notifies :run, "execute[restart Rails app #{application}]"

    only_if do
      node[:deploy][application][:elasticsearch].present? &&
        node[:deploy][application][:elasticsearch][:hosts].present? &&
        File.directory?("#{node[:deploy][application][:deploy_to]}/shared/config/")
    end
  end

end
