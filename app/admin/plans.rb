ActiveAdmin.register Plan do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :name, :description, :invitations_per_day_limit, :emails_per_day_limit, :profiles_visit_limit, :send_message_limit, :connections_limit, :total_profiles_visit_limit, :total_send_messages_limit, :total_connections_limit, :total_follow_up_messages_limit, :profiles_visit_per_day_limit, :send_messages_per_day_limit, :follow_up_messages_per_day_limit, :total_invitations_limit, :total_emails_limit, :price, :uuid
  #
  # or
  #
  # permit_params do
  #   permitted = [:name, :description, :invitations_per_day_limit, :emails_per_day_limit, :profiles_visit_limit, :send_message_limit, :connections_limit, :total_profiles_visit_limit, :total_send_messages_limit, :total_connections_limit, :total_follow_up_messages_limit, :profiles_visit_per_day_limit, :send_messages_per_day_limit, :follow_up_messages_per_day_limit, :total_invitations_limit, :total_emails_limit, :price, :uuid]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  
end
