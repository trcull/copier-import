class Fb::FbProject < ActiveRecord::Base

   belongs_to :user
   #attr_accessible :budget_dollars_billed, :user_id, :name, :fb_id
   
   def percent_of_budget
     if budget_dollars_billed.nil? || budget_dollars_billed == 0
       rv = 0
     elsif current_total_billed.nil? 
       rv = 0
     else
       rv = current_total_billed / budget_dollars_billed
     end
     rv
   end
end
