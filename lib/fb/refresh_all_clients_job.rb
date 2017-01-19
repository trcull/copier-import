module Fb
  class RefreshAllClientsJob < AbstractJob
    def self.enqueue(user_id)
      Fb::RefreshAllClientsJob.new.delay(priority: PRIORITY_DEFAULT).perform(user_id)
    end
    
    def perform(user_id)
      Rails.logger.info "refreshing all clients for user #{user_id}"
      #get all clients from Freshbooks
      user = User.find(user_id)

      if (Fb::RfApi.has_authorized?(user))
        Rails.logger.info "got user with freshbooks credentials #{user.inspect}"
        api = Fb::RfApi.new(user.account_for('fb'))
        clients = api.fb_clients

        #enqueue an update for each one 
        clients.each do |client|
          fb_client = find_fb_client(client, user.id)
          fb_client.update_attributes(:name => client["organization"])
          Rails.logger.info "updated client #{client['client_id']} for user #{user.id}"
        end
      else
        Rails.logger.error("User #{user.id} does not have freshbooks credentials set, so can't update their information")
      end
      
    end

    def find_fb_client(client, user_id) 
      fb_client_id = client['client_id']
      fb_client = FbClient.where(fb_id: fb_client_id, user_id: user_id).first
      if (fb_client.nil?)
        fb_client = FbClient.create({:user_id => user_id, :name => client['organization'], :fb_id => fb_client_id})
      end
      fb_client
    end

    
  end
end
