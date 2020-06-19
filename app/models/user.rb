class User < ApplicationRecord
  before_create :check_and_create_account
  before_create :set_default_plan

  belongs_to  :plan, optional: true
  belongs_to  :account, optional: true
  has_many    :campaigns, dependent: :destroy
  has_many    :templates, dependent: :destroy
  has_many    :blacklist_members, dependent: :destroy
  has_many    :listings, dependent: :destroy
  has_many    :invitations, dependent: :destroy
  has_many    :payment_notifications, dependent: :destroy
  belongs_to  :plan, optional: true

  has_secure_password
  validates_uniqueness_of :email
  validates_presence_of   :email, :firstname, :lastname
  
  validates :password, length: { in: 6..20 }, on: :create
  validate :password_requirements_are_met, on: :create
  
  validates_presence_of :plan_id, on: :update

  def self.find_or_create_from_auth_hash(auth)
    where(provider: auth[:provider], uid: auth[:uid]).first_or_initialize.tap do |user|
      user.provider   = auth[:provider]
      user.uid        = auth[:uid]
      user.firstname  = auth[:first_name]
      user.lastname   = auth[:last_name]
      user.email      = auth[:email]
      user.activated_at = Time.now
      user.save!(validate:false)
    end
  end

  def update_token
    token = ::JsonWebToken.encode(user_id: self.id)
    self.update_column(:token,token)    
  end

  def allow?
    self.today_invitations.count < self.plan.invitations_per_day_limit
  end

  def total_invitations
    CampaignMember.where(campaign_id: self.campaigns.where(campaign_type:'connect').map(&:id))
  end

  def total_accepted_invitations
    self.total_invitations.where(status:true)
  end

  def today_invitations
    self.total_invitations.where("created_at >= ?", Time.zone.now.beginning_of_day)
  end

  def today_accepted_invitations
    self.today_invitations.where(status:true)
  end

  def monthly_invitations
    self.total_invitations.where(created_at:Time.now.beginning_of_month..Time.now.end_of_month)
  end

  def monthly_accepted_invitations
    self.monthly_invitations.where(status:true)
  end

  def visit_allow?
    self.today_visits.count < self.plan.profiles_visit_per_day_limit
  end

  def total_visits
    CampaignMember.where(campaign_id: self.campaigns.where(campaign_type:'visit').map(&:id))
  end

  def today_visits
    self.total_visits.where("created_at >= ?", Time.zone.now.beginning_of_day)
  end

  def monthly_visits
    self.total_visits.where(created_at:Time.now.beginning_of_month..Time.now.end_of_month)
  end  

  def message_allow?
    self.today_messages.count < self.send_messages_per_day_limit
  end

  def total_messages
    CampaignMember.where(campaign_id: self.campaigns.where(campaign_type:'message').map(&:id))
  end

  def today_messages
    self.total_messages.where("created_at >= ?", Time.zone.now.beginning_of_day)
  end

  def monthly_messsages
    self.total_messages.where(created_at:Time.now.beginning_of_month..Time.now.end_of_month)
  end 

  private

    def set_default_plan
      self.plan_id = Plan.find_by_name('basic').try(:id)
    end


    def check_and_create_account
      account = Account.find_by(name: self.company)
      if account.nil?
        account = Account.new(name: self.company)
        account.save
      end
      update_user_account(account)
    end

    def update_user_account account
      self.account_id = account.id
    end

    def password_requirements_are_met
      rules = {
        " must contain at least one lowercase letter"  => /[a-z]+/,
        " must contain at least one uppercase letter"  => /[A-Z]+/,
        " must contain at least one digit"             => /\d+/,
        " must contain at least one special character" => /[^A-Za-z0-9]+/
      }

      rules.each do |message, regex|
        errors.add( :password, message ) unless password && password.match( regex )
      end
    end
end
