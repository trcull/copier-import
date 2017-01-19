require 'spec_helper'

describe Fb::XeroxCopier do
  subject {
    create(:xerox_copier)
  }
  describe "attributes" do
    it "can mass assign" do
      attrs = {
        :serial_number=>'fake',
        :make=>'stuff',
        :model=>'stuff',
        :grouping=>'stuff',
        :mono_base=>2,
        :mono_overage=>1.1,
        :color_0_base=>2,
        :color_0_overage=>1.1,
        :mono_color_1_base=>2,
        :mono_color_1_overage=>1.1,
        :color_level_2_base=>2,
        :color_level_2_overage=>1.1,
        :color_level_3_base=>2,
        :color_level_3_overage=>1.1,
        :base_rate=>230.45
        }
      change_me = subject
      change_me.update_attributes(attrs)
      attrs.each_pair do |key, value|
        change_me.send(key).should eq value
      end
    end

  end
end
