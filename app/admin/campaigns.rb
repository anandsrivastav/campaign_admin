ActiveAdmin.register Campaign do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :withdramConnectionAtDay, :maxConnectionPageSentPerDay, :url, :status, :user_id, :template_id, :description, :run_at, :end_at, :custom_message, :campaign_type, :is_include_premium_profile, :is_include_without_avatar_profile, :is_skip_premium_profile, :is_skip_without_avatar_profile, :is_only_premium, :max_limit, :limit, :uuid
  #
  # or
  #
  # permit_params do
  #   permitted = [:withdramConnectionAtDay, :maxConnectionPageSentPerDay, :url, :status, :user_id, :template_id, :description, :run_at, :end_at, :custom_message, :campaign_type, :is_include_premium_profile, :is_include_without_avatar_profile, :is_skip_premium_profile, :is_skip_without_avatar_profile, :is_only_premium, :max_limit, :limit, :uuid]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  
end
