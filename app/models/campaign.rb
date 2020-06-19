class Campaign < ApplicationRecord
  belongs_to  :user
  has_many    :campaign_messages, dependent: :destroy
  has_many    :campaign_members, dependent: :destroy
  belongs_to  :template, optional: true
  has_many    :invitations, dependent: :destroy
  has_many    :campaign_logs, dependent: :destroy
  has_many    :tags, dependent: :destroy

  has_one :job
  
  validates_presence_of :url
  validate :linkedin_url

  accepts_nested_attributes_for :campaign_messages, :tags, allow_destroy: true

  def pending
    self.campaign_members.where(status:false)
  end

  def accepted
    self.campaign_members.where(status:true)
  end

  def linkedin_scrapping(current_user, cookie, page_number)
    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument("--headless")
    driver = Selenium::WebDriver.for :chrome, options: options
    driver.get('https://www.linkedin.com')
    driver.manage().window().maximize();
    driver.manage.add_cookie(name: 'li_at', value:cookie, path: '/', domain: '.www.linkedin.com')    
    linkedin_profiles = []
    block_profiles   = current_user.blacklist_members.map(&:profile_url)

    driver.navigate.to "#{self.url}&page=#{page_number}"
    
    driver.execute_script("window.scrollTo({top:document.documentElement.scrollHeight,behavior: 'smooth'})")
    random_wait
    profiles_li_list = driver.find_elements(xpath: "//li[@class='search-result search-result__occluded-item ember-view']")
    last_page_number = driver.find_element(class:'artdeco-pagination__pages').find_elements(tag_name: 'li').last.text rescue nil
    Rails.logger.info "going to scrap the page #{page_number}"
    profiles_li_list.each_with_index do |li, index|
      profile_url  = li.find_elements(tag_name: 'a')[1].attribute('href') rescue nil
      full_name    = li.find_element(class: 'actor-name').text rescue nil
      title        = li.find_element(class: 'subline-level-1').text  rescue nil
      location     = li.find_element(class: 'subline-level-2').text rescue nil
      image_url    = li.find_element(class: 'ivm-view-attr__img--centered').property('src') rescue nil 
      summary      = li.find_element(class: 'search-result__snippets-black').text rescue nil
      is_premium   = li.find_elements(class: "premium-icon")[0].present? ? true : false
      Rails.logger.info "premium=#{only_premium?(is_premium)}"
      linkedin_profiles << { profile_url:profile_url, full_name:full_name, title: title, location: location, image_url: image_url, summary: summary, is_premium: is_premium } if full_name.present? && only_premium?(is_premium) && !block_profiles.include?(profile_url)
    end
    Rails.logger.info "linkedin_profiles=#{linkedin_profiles}"
    driver.close()
    return { profiles:linkedin_profiles,last_page_number:last_page_number,url:url }
  end

  def linkedin_connect_request(cookie, current_user, leads)
    current_user.update_column(:linkedin_cookie,cookie)
    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument("--headless")
    driver = Selenium::WebDriver.for :chrome, options: options
    driver.get('https://www.linkedin.com')
    driver.manage().window().maximize();
    driver.manage.add_cookie(name: 'li_at', value:cookie, path: '/', domain: '.www.linkedin.com')     
    leads.each do |lead|
      if current_user.allow?
        message = dynamic_message(self.description, lead["full_name"], lead["location"])
        driver.navigate.to lead["profile_url"]
        driver.execute_script("window.scrollTo({top:document.documentElement.scrollHeight,behavior: 'smooth'})")
        random_wait
        connect_btn = driver.find_elements(xpath: "//button[starts-with(@aria-label,'Connect')]")  
        unless connect_btn.empty?
          connect_btn[0].click #two possibilities
          random_wait
          if driver.find_elements(id:'custom-message').empty?
            driver.find_element(xpath: "//button[@aria-label='Add a note']").click
            random_wait
            driver.find_element(id:'custom-message').send_keys message     
            random_wait
            #two possibilities
            driver.find_element(xpath: "//button[@aria-label='Done']").click  rescue nil
            random_wait
            driver.find_element(xpath: "//button[@aria-label='Send invitation']").click rescue nil
            random_wait
            driver.find_elements(xpath: "//button[@data-control-name='colleague.heathrow_promo_question_no']") rescue nil
          else  
            driver.find_element(id:'custom-message').send_keys message
            random_wait
            driver.find_element(xpath:"//button[@aria-label='Send invitation']").click
          end        
        create_member(lead)
        end
      end
    random_wait
    end
    driver.close();
  end

  def linkedin_auto_connect_request(current_user, cookie)
    current_user.update_column(:linkedin_cookie,cookie)
    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument("--headless")
    driver = Selenium::WebDriver.for :chrome, options: options
    driver.get('https://www.linkedin.com')
    driver.manage().window().maximize();
    begin
      
      self.campaign_logs.create(log: "<span> >>>> Start processing</span>")      
      driver.manage.add_cookie(name: 'li_at', value:cookie, path: '/', domain: '.www.linkedin.com')          
      lead = {}
      for page in 1..10
        driver.navigate.to "#{self.url}&page=#{page}"

        if driver.current_url.include?("session_redirect")
        self.campaign_logs.create(log: "<span> Error fetching link <a target='_blank' href=#{self.url}>#url</a> code 401</span>")
        break
        end
      
        self.campaign_logs.create(log: "<span> Search page #<a target='_blank' href=#{self.url}&page=#{page}>#{page}</a></span>")
        
        random_wait
        
        driver.execute_script("window.scrollTo({top:document.documentElement.scrollHeight,behavior: 'smooth'})")
        random_wait
        profiles_li_list = driver.find_elements(xpath: "//li[@class='search-result search-result__occluded-item ember-view']")
        profile_urls = []
        profiles_li_list.each do |li|
          random_wait          
          is_premium = li.find_elements(tag_name: "li-icon")[0].present? ? true : false
          random_wait
          profile_urls << li.find_elements(tag_name: 'a')[1].attribute('href') if only_premium?(is_premium)
        end
        profile_urls = profile_urls.compact

        block_profiles   = current_user.blacklist_members.map(&:profile_url)
        profile_urls -= block_profiles
      
        if profile_urls.empty? || !current_user.allow?
          self.campaign_logs.create(log:"<span> Either daily limit ended or no profiles found for given #<a target='_blank' href=#{self.url}&page=#{page}>link</a></span>")
          break 
        end
      
        profile_urls.each_with_index do |profile_url, index|              
          if current_user.allow? && !profile_url.include?(self.url) #LinkedIn Member

            public_identifier = profile_url.split('/').last
            campaign_member =  CampaignMember.where(public_identifier:public_identifier, campaign_id:self.id).first
            self.campaign_logs.create(log: "<span> Already invitation sent to <a target='_blank' href=#{campaign_member.profile_url}>#{campaign_member.full_name}</a></span>") if campaign_member.present?

            if campaign_member.nil?
              driver.navigate.to profile_url
              random_wait
              lead["title"]        = driver.find_element(xpath: "//h2[@class='mt1 t-18 t-black t-normal break-words']").text rescue nil
              lead["image_url"]    = driver.find_elements(xpath: "//div[@class='pv-top-card__photo-wrapper ml0']/div/img")[0].property('src')rescue nil 
              lead["profile_url"]  = profile_url 
              lead["full_name"]    = driver.find_elements(xpath: "//li[@class='inline t-24 t-black t-normal break-words']")[0].text rescue nil
              lead["location"]     = driver.find_elements(xpath: "//li[@class='t-16 t-black t-normal inline-block']")[0].text rescue nil
              message              = dynamic_message(self.description, lead["full_name"] , lead["location"] ) rescue nil
              driver.execute_script("window.scrollTo({top:document.documentElement.scrollHeight,behavior: 'smooth'})")
              random_wait
              connect_btn = driver.find_elements(xpath: "//button[starts-with(@aria-label,'Connect')]") 
              unless connect_btn.empty? 
                connect_btn[0].click #two possibilities
                random_wait
                if driver.find_elements(id:'custom-message').empty?
                driver.find_element(xpath: "//button[@aria-label='Add a note']").click
                random_wait
                driver.find_element(id:'custom-message').send_keys message     
                random_wait
                #two possibilities
                driver.find_element(xpath: "//button[@aria-label='Done']").click  rescue nil
                random_wait
                driver.find_element(xpath: "//button[@aria-label='Send invitation']").click rescue nil
                driver.find_elements(xpath: "//button[@data-control-name='colleague.heathrow_promo_question_no']") rescue nil
                else  
                  driver.find_element(id:'custom-message').send_keys message
                  random_wait
                  driver.find_element(xpath:"//button[@aria-label='Send invitation']").click
                end
                create_member(lead)
              end
            end
          end           
          random_wait
        end
      end
      driver.close();
    rescue Exception => e
      self.campaign_logs.create(log:"<span> Error #{e.exception}</span>")
      UserMailer.exception_notifier(self,e.exception).deliver_now
      driver.close() if driver    
    end  
  end
  
  def linkedin_invitation_status(current_user, cookie)   
    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument("--headless")
    driver = Selenium::WebDriver.for :chrome, options: options
    driver.get('https://www.linkedin.com')
    driver.manage().window().maximize();
    driver.manage.add_cookie(name: 'li_at', value:cookie, path: '/', domain: '.www.linkedin.com')    
    begin
      self.campaign_members.where(status:false).each do |member|
        driver.navigate.to member.profile_url
        driver.execute_script("window.scrollTo({top:document.documentElement.scrollHeight,behavior: 'smooth'})")
        sleep random_wait
        driver.find_elements(xpath: "//div[@class='pv-s-profile-actions__overflow ember-view']")[0].click
        sleep random_wait
        more_values = driver.find_elements(xpath: "//span[@class='display-flex t-normal pv-s-profile-actions__label']").map(&:text)
        if more_values.include? 'Remove Connection'
          member.update_column(:status,true)
          member.update_column(:accepted_at, Time.now)
          sleep random_wait
          member.campaign_members_messages.each do |campaign_members_message|
            sending_date = member.accepted_at + campaign_members_message.campaign_message.number_of_days.days
            campaign_members_message.update_column(:sending_date, sending_date)
          end
        end
      end
      driver.close() if driver   
    rescue Exception => e
      UserMailer.exception_notifier(self,e.exception).deliver_now
      driver.close() if driver
    end
  end

  def send_followup_messages(current_user, cookie)
    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument("--headless")
    driver = Selenium::WebDriver.for :chrome, options: options
    driver.get('https://www.linkedin.com')
    driver.manage().window().maximize();
    driver.manage.add_cookie(name: 'li_at', value:cookie, path: '/', domain: '.www.linkedin.com')    
    follow_up_messages = CampaignMembersMessage.where("sending_date >= ? AND sending_date < ?", Time.zone.now.beginning_of_day, Time.zone.now.end_of_day)
    begin
      if follow_up_messages.present?
        follow_up_messages.each do |campaign_members_message|
          driver.navigate.to campaign_members_message.campaign_member.profile_url
          
          driver.execute_script("window.scrollTo({top:document.documentElement.scrollHeight,behavior: 'smooth'})")
          sleep random_wait
          full_name    = driver.find_elements(xpath: "//li[@class='inline t-24 t-black t-normal break-words']")[0].text rescue nil
          location     = driver.find_elements(xpath: "//li[@class='t-16 t-black t-normal inline-block']")[0].text rescue nil          
          message = dynamic_message(campaign_members_message.campaign_message.description, full_name, location)
          driver.find_element(xpath: "//span/a").click          
          sleep random_wait
          driver.find_element(class: 'msg-form__msg-content-container--scrollable').find_element(tag_name:'p').send_keys message
          sleep random_wait
          driver.find_elements(xpath: "//button[@class='msg-form__send-button artdeco-button artdeco-button--1']")[0].click
        end
      end
      driver.close() if driver 
    rescue Exception => e
      UserMailer.exception_notifier(self,e.exception).deliver_now
      driver.close() if driver
    end
  end

  def linkedin_visit_profiles(current_user,cookie)
    lead = {}
    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument("--headless")
    driver = Selenium::WebDriver.for :chrome, options: options
    driver.get('https://www.linkedin.com')
    driver.manage().window().maximize();
    begin
      self.campaign_logs.create(log: "<span> >>>> Start processing</span>")
      driver.manage.add_cookie(name: 'li_at', value:cookie, path: '/', domain: '.www.linkedin.com')    
      
      for page in 1..10
        driver.navigate.to "#{self.url}&page=#{page}"              
        
        random_wait      
        
        if driver.current_url.include?("session_redirect")
          self.campaign_logs.create(log: "<span> Error fetching link <a target='_blank' href=#{self.url}>#url</a> code 401</span>")
          break
        end
        
        self.campaign_logs.create(log: "<span> Search page #<a target='_blank' href=#{self.url}&page=#{page}>#{page}</a></span>")
        driver.execute_script("window.scrollTo({top:document.documentElement.scrollHeight,behavior: 'smooth'})")
        random_wait
        profiles_li_list = driver.find_elements(xpath: "//li[@class='search-result search-result__occluded-item ember-view']")
        profile_urls = []
        profiles_li_list.each do |li|
          random_wait          
          is_premium = li.find_elements(tag_name: "li-icon")[0].present? ? true : false
          random_wait
          profile_urls << li.find_elements(tag_name: 'a')[1].attribute('href') if only_premium?(is_premium)
        end
        profile_urls = profile_urls.compact
        block_profiles   = current_user.blacklist_members.map(&:profile_url)
        profile_urls -= block_profiles

        Rails.logger.info "profile urls=#{profile_urls}"

        if profile_urls.empty? || !current_user.visit_allow?
          self.campaign_logs.create(log:"<span> Either daily limit ended or no profiles found for given #<a target='_blank' href=#{self.url}&page=#{page}>link</a></span>")
          break 
        end
        
        profile_urls.each_with_index do |profile_url, index|
          if current_user.visit_allow? && !profile_url.include?(self.url) #LinkedIn Member
            public_identifier = profile_url.split('/').last
            Rails.logger.info "#{public_identifier}"
            campaign_member =  CampaignMember.where(public_identifier:public_identifier, campaign_id:self.id).first
            self.campaign_logs.create(log: "Already visited profile of <a target='_blank' href=#{campaign_member.profile_url}>#{campaign_member.full_name}</a>") if campaign_member.present?
            if campaign_member.nil?
              driver.navigate.to profile_url
              random_wait
              lead["title"]        = driver.find_element(xpath: "//h2[@class='mt1 t-18 t-black t-normal break-words']").text rescue nil
              lead["image_url"]    = driver.find_elements(xpath: "//div[@class='pv-top-card__photo-wrapper ml0']/div/img")[0].property('src') rescue nil 
              lead["profile_url"]  = profile_url 
              lead["full_name"]    = driver.find_elements(xpath: "//li[@class='inline t-24 t-black t-normal break-words']")[0].text rescue nil
              lead["location"]     = driver.find_elements(xpath: "//li[@class='t-16 t-black t-normal inline-block']")[0].text rescue nil        
              create_member(lead)  if lead["full_name"].present?
            end
          end
        random_wait
        end
      end
      driver.close() if driver
    rescue Exception => e
      self.campaign_logs.create(log:"<span> Error #{e.exception}</span>")
      UserMailer.exception_notifier(self,e.exception).deliver_now
      driver.close() if driver
    end
  end

  def linkedin_send_message(current_user, cookie)
    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument("--headless")
    driver = Selenium::WebDriver.for :chrome, options: options
    driver.get('https://www.linkedin.com')
    driver.manage().window().maximize();
    lead = {}
    begin
      self.campaign_logs.create(log: "<span> >>>> Start processing</span>")      
      driver.manage.add_cookie(name: 'li_at', value:cookie, path: '/', domain: '.www.linkedin.com')           
      for page in 1..10
        driver.navigate.to "#{self.url}&page=#{page}"
        
        if driver.current_url.include?("session_redirect")
          self.campaign_logs.create(log: "Error fetching <a target='_blank' href=#{self.url}>#link</a> code 401")
          break
        end      
        
        random_wait
        driver.execute_script("window.scrollTo({top:document.documentElement.scrollHeight,behavior: 'smooth'})")
        random_wait
        profiles_li_list = driver.find_elements(xpath: "//li[@class='search-result search-result__occluded-item ember-view']")
        profile_urls = []
        profiles_li_list.each do |li|
          random_wait          
          is_premium = li.find_elements(tag_name: "li-icon")[0].present? ? true : false
          random_wait
          profile_urls << li.find_elements(tag_name: 'a')[1].attribute('href') if only_premium?(is_premium)
        end
        profile_urls = profile_urls.compact

        block_profiles   = current_user.blacklist_members.map(&:profile_url)
        profile_urls -= block_profiles 
        
        if profile_urls.empty? || !current_user.allow?
          self.campaign_logs.create(log:"<span> Either daily limit ended or no profiles found for given #<a target='_blank' href=#{self.url}&page=#{page}>link</a></span>")
          break
        end 
        
        profile_urls.each_with_index do |profile_url, index|
          if current_user.message_allow? && !profile_url.include?(self.url) #LinkedIn Member
            public_identifier =   profile_url.split('/').last
            campaign_member   =  CampaignMember.where(public_identifier:public_identifier, campaign_id:self.id).first
            self.campaign_logs.create(log: "Already sent message to <a target='_blank' href=#{campaign_member.profile_url}>#{campaign_member.full_name}</a>") if campaign_member.present?            
            if campaign_member.nil?
              driver.navigate.to profile_url
              random_wait
              lead["title"]        = driver.find_element(xpath: "//h2[@class='mt1 t-18 t-black t-normal break-words']").text rescue nil
              lead["image_url"]    = driver.find_elements(xpath: "//div[@class='pv-top-card__photo-wrapper ml0']/div/img")[0].property('src')rescue nil 
              lead["profile_url"]  = profile_url 
              lead["full_name"]    = driver.find_elements(xpath: "//li[@class='inline t-24 t-black t-normal break-words']")[0].text rescue nil
              lead["location"]     = driver.find_elements(xpath: "//li[@class='t-16 t-black t-normal inline-block']")[0].text rescue nil
              message              = dynamic_message(self.description, lead["full_name"], lead["location"]) rescue nil
              random_wait
              driver.execute_script("window.scrollTo({top:document.documentElement.scrollHeight,behavior: 'smooth'})")
              message_btn = driver.find_element(xpath: "//span/a").text rescue nil
              if message_btn == 'Message'
                random_wait
                driver.find_element(xpath: "//span/a").click
                random_wait
                driver.find_elements(class: 'msg-form__msg-content-container--scrollable')[-1].find_element(tag_name:'p').send_keys message
                random_wait
                driver.find_elements(xpath: "//button[@data-control-name='send']")[-1].click
                create_member(lead)
            end
          end
        end
      random_wait
      end
    end
    driver.close() if driver
    rescue Exception => e
      self.campaign_logs.create(log:"Error #{e.exception}")
      UserMailer.exception_notifier(self,e.exception).deliver_now
      driver.close() if driver
    end
  end

  def random_wait
    sleep Random.new.rand(4..8)
  end

  def dynamic_message(message, fullname, location)
    firstname = fullname.split(' ').first
    message.gsub("{fullname | fallback:'ENTER FALLBACK HERE'}", fullname).gsub("{location | fallback:'ENTER FALLBACK HERE'}", location).gsub("{firstname | fallback:'ENTER FALLBACK HERE'}", firstname) rescue ""
  end

  def create_member(lead)
    public_identifier = lead["profile_url"].split('/').last
    campaign_member = self.campaign_members.where(public_identifier: public_identifier).first_or_create!(full_name:lead["full_name"],profile_url:lead["profile_url"],title:lead["title"],location:lead["location"],image_url:lead["image_url"],summary:lead["summary"], is_premium: lead["is_premium"])
  end

  def only_premium?(is_premium)
    self.is_only_premium ? is_premium : true
  end


  private

  def linkedin_url
    regex = /(ftp|http|https):\/\/?(?:www\.)?linkedin.com\/search\/results\/people(\w+:{0,1}\w*@)?(\S+)(:([0-9])+)?(\/|\/([\w#!:.?+=&%@!\-\/]))?/
    errors.add(:url,'is not valid') if self.url.match(regex).nil?
  end


end
