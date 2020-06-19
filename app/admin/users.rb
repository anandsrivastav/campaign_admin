ActiveAdmin.register User do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :email, :password_digest, :account_id, :firstname, :lastname, :company, :hunter_api_key, :aeroleads_api_key, :prospect_api_key, :anymail_api_key, :plan_id, :provider, :uid, :linkedin_cookie, :token, :activated_at, :avatar_file_name, :avatar_content_type, :avatar_file_size, :avatar_updated_at, :linkedin_session_id, :uuid
  #
  # or
  #
  # permit_params do
  #   permitted = [:email, :password_digest, :account_id, :firstname, :lastname, :company, :hunter_api_key, :aeroleads_api_key, :prospect_api_key, :anymail_api_key, :plan_id, :provider, :uid, :linkedin_cookie, :token, :activated_at, :avatar_file_name, :avatar_content_type, :avatar_file_size, :avatar_updated_at, :linkedin_session_id, :uuid]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  
end
