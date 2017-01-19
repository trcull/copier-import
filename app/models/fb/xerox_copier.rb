class Fb::XeroxCopier < ActiveRecord::Base

   belongs_to :fb_client
   belongs_to :user
   
   # attr_accessible :serial_number,
        # :make,
        # :model,
        # :grouping,
        # :mono_base,
        # :mono_overage,
        # :color_0_base,
        # :color_0_overage,
        # :mono_color_1_base,
        # :mono_color_1_overage,
        # :color_level_2_base,
        # :color_level_2_overage,
        # :color_level_3_base,
        # :color_level_3_overage,
        # :fb_client_id, 
        # :base_rate,
        # :tax_name,
        # :tax_rate,
        # :sales_tracking_code
#    
   def self.fb_xerox_copier_path
     '/fb/xerox_import'
   end
end
