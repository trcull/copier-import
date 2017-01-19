require 'spec_helper'

describe Fb::FbProject do
  describe "expenses_subtotal" do
    it "is assignable" do
      fv_project = create(:fb_project)
      fv_project.expenses_subtotal = 10.0
    end
  end

  describe "percent_of_budget" do
    it "doesn't explode if the budget isn't set" do
      subject.budget_dollars_billed = 0
      subject.current_total_billed = 100
      subject.percent_of_budget.should eq 0
    end

    it "doesn't explode if there are no billed hours" do
      subject.budget_dollars_billed = 100
      subject.current_total_billed = nil
      subject.percent_of_budget.should eq 0
    end

    it "calculates the right percentage" do
      subject.budget_dollars_billed = 100
      subject.current_total_billed = 50
      subject.percent_of_budget.should eq 0.5
    end

  end
end
