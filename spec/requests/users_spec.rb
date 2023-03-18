require 'rails_helper'

RSpec.describe "Users" do

  describe "User model" do
    it "has admin field" do
      expect(User.column_names.include?("admin")).to be true
    end
  end

  describe "GET /index" do
    pending "add some examples (or delete) #{__FILE__}"
  end
end
