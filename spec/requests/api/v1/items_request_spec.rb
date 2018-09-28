require 'rails_helper'

describe "Items API" do
  it "sends a list of items" do
    create_list(:item, 3) #create list method is given to us by FactoryBot -> create 3 items

    get '/api/v1/items' #sends get request to api/v1/items endpoint

    expect(response).to be_successful

    items = JSON.parse(response.body)

    expect(items.count).to eq(3)
  end

  it "can get one item by its id" do
    #expect newly created item id to match the response item id when we request it 
    id = create(:item).id

    get "/api/v1/items/#{id}" # send request to API endpoint

    item = JSON.parse(response.body)

    expect(response).to be_successful
    expect(item["id"]).to eq(id)
  end
end
