require "spec_helper"

describe User do
  subject {create(:user)}
  
  it "doesn't explode" do
    create(:user)
  end
  
  describe "recent_activity" do
    it "doesn't explode" do
      subject.recent_activity
    end
  end
  
  describe "is_suppressed?" do
    before do
      @user = create(:user)
    end
    
    it "says true if suppressed for that template" do
      SuppressedUserMessage.create!(user_id: @user.id, message_key: 'test')
      @user.is_suppressed?('test').should eq true
    end
    
    it "says true if suppressed for all templates" do
      SuppressedUserMessage.create!(user_id: @user.id, message_key: 'all')
      @user.is_suppressed?('test').should eq true
    end
    
    it "says false if suppressed for a different template" do
      SuppressedUserMessage.create!(user_id: @user.id, message_key: 'test')
      @user.is_suppressed?('other').should eq false
    end
    
    it "says false if not suppressed for anything" do
      @user.is_suppressed?('test').should eq false
    end
  end
  
  describe "has_received?" do
    before do
       @user = create(:user)
    end
    
    it "doesn't explode" do
      @user.has_received?("a_key").should eq false
    end  

    it "says yes at the right time" do
      @user.mark_received!("a_key")
      @user.has_received?("a_key").should eq true
    end  

    it "says no if it's been too long" do
      event = @user.mark_received!("a_key")
      event.created_at = 30.days.ago
      event.save!
      @user.has_received?("a_key", 29.days.ago).should eq false
      @user.has_received?("a_key", 31.days.ago).should eq true
    end  

  end
  
  describe "generate_token" do
    it "doesn't explode" do
      @user = create(:user)
      token = @user.generate_token
      token.should_not be_nil
      token.token.should_not be_nil
      token.expires_at.should_not be_nil
      token.expires_at.should be > DateTime.now    
    end
  end
  
  describe "should_pay?" do
    context "they have RF sales" do
      before do
          @user = create(:user)
          @stat = DailyOrganizationStat.create( organization_id: @user.current_organization.id, 
                  as_of_date: DateTime.now.at_beginning_of_day,
                  rf_sales_dollars_to_date: 1000
                  )
          @free = Plan.where(group: Plan::GROUP_FREE_PLAN).first
          @basic = Plan.where(name: 'Basic').first
          @user.plans.clear
      end
      
      it "says yes if they are still on a free plan and have more than ten sales in the last 30 days" do
        @user.plans << @free
        @stat.all_sales_count_this_month = 12
        @stat.save!
        @user.should_pay?.should eq true
      end

      it "says no if they are still on a free plan and have more than ten sales in the last 30 days" do
        @user.plans << @free
        @stat.all_sales_count_this_month = 2
        @stat.save!
        @user.should_pay?.should eq false
      end
      
      it "says yes if they have more orders than plan points" do  
        @user.plans << @basic
        @stat.all_sales_count_this_month = @basic.points + 1
        @stat.save!
        @user.should_pay?.should eq true
      end

      it "says no if they have fewer orders than plan points" do  
        @user.plans << @basic
        @stat.all_sales_count_this_month = @basic.points - 1
        @stat.save!
        @user.should_pay?.should eq false
      end

      it "says no if they have less than 3x plan price in sales" do
        @user.plans << @basic
        @stat.rf_sales_dollars_to_date = @basic.price * 2
        @stat.save!
        @user.should_pay?.should eq false
      end
    end
  end
  
  
  it "can accept new roles" do
    u = create(:user)
    r = create(:role)
    p = create(:permission)
    r.permissions << p
    r.save!
    u.can?(p.name).should eq false

    u.roles << r
    u.save!
    u.can?(p.name).should eq true
  end
  
  it "can accept new plans" do
    u = create(:user)
    p = create(:plan)
    u.plans << p
    u.save!
  end
  
  it "adds the default role on creation" do
    u = User.new
    u.email = "foo@bar.com"
    u.password = "bar12345678"
    u.password_confirmation = u.password
    u.new_organization_name = "Pollen"
    u.new_store_url = "mystore.com"
    u.new_store_type = Organization::STORE_TYPE_MANUAL
    u.save!
    u.roles.length.should eq 1
  end

  it "adds a new organization on creation" do
    u = User.new
    u.email = "foo@bar.com"
    u.password = "bar12345678"
    u.password_confirmation = u.password
    u.new_organization_name = "Pollen"
    u.new_store_url = "mystore.com"
    u.new_store_type = Organization::STORE_TYPE_MANUAL
    u.save!
    u.organizations.length.should eq 1
    u.organizations.first.name.should eq 'Pollen'
    u.organizations.first.store_url.should eq "mystore.com"
  end

  it "strips http from store url if present" do
    u = User.new
    u.email = "foo@bar.com"
    u.password = "bar12345678"
    u.password_confirmation = u.password
    u.new_organization_name = "Pollen"
    u.new_store_url = "http://mystore.com"
    u.new_store_type = Organization::STORE_TYPE_MANUAL
    u.save!
    u.organizations.first.store_url.should eq "mystore.com"
  end


end