require 'rails_helper'

RSpec.describe "User" do
  describe "User model" do
    it "has admin field" do
      expect(User.column_names.include?("admin")).to be true
    end
  end
end
