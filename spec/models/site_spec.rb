require 'spec_helper'

describe Site do
  it "shouldn't explode" do
    create(:site)
  end
end
