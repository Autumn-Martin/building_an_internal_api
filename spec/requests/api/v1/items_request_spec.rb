require 'rails_helper'

describe "Items API" do
  it "sends a list of items" do
    create_list(:item, 3) #create list method is given to us by FactoryBot -> create 3 items

    get '/api/v1/items' #sends get request to api/v1/items endpoint

    expect(response).to be_successful
  end
end
