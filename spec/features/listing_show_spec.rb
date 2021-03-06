require 'rails_helper'

RSpec.describe "Listing show" do

  let!(:listing) { Listing.create({title: "Bacon Maple Crunch",
                                   description: "see title",
                                   price: 8.00,
                                   quantity_available: 2,
                                   people_per_unit: 2,
                                   private_bathroom: true,
                                   start_date: "08/01/2015",
                                   end_date: "08/30/2015",
                                   user_id: 2,
                                   country: 'USA',
                                   state: 'Colorado',
                                   city: 'Denver',
                                   zipcode: '80206',
                                   street_address: '1510 Blake St',
                                   status: 0})}


  it "displays listing title" do
    listing.pictures.create(avatar: "default-img.jpg")
    visit root_path
    click_on("Browse All Listings")
    expect(current_path).to eq(listings_path)
    click_on("Bacon Maple Crunch")
    expect(current_path).to eq(listing_path(listing))
    expect(page).to have_content("Bacon Maple Crunch")
  end

  it "displays listing description" do
    listing.pictures.create(avatar: 'default-image.jpg')
    visit listing_path(listing)
    expect(page).to have_content("see title")
  end

  it "display listings price" do
    listing.pictures.create(avatar: 'default-image.jpg')
    visit listing_path(listing)
    expect(page).to have_content("8.00")
  end

  it "displays a custom picture" do
    listing.pictures.create(avatar: "default_image.jpg")
    visit listing_path(listing)
    expect(page).to have_css("img")
  end

  it "has a link to add listing to cart", js: true do
    listing.pictures.create(avatar: "default_image.jpg")
    visit listing_path(listing)
    expect(page).to have_button("Add to Itinerary")

    fill_in('listing[start_date]', with: "08/20/2015")
    fill_in('listing[end_date]', with: "08/20/2015")

    click_link_or_button("Add to Itinerary")

    expect(page).to have_content(listing.title)
    expect(page).to have_selector("#flash_notice")
  end

  context "when a user clicks an listing from a previous booking thats been retired" do
    it "notes if listing is retired", js:true do
      user = create(:user)
      listing.pictures.create(avatar: "default_image.jpg")
      visit listing_path(listing)

      fill_in('listing[start_date]', with: "08/20/2015")
      fill_in('listing[end_date]', with: "08/20/2015")

      click_link_or_button("Add to Itinerary")
      visit cart_path

      click_link_or_button("Sign in to book itinerary")
      fill_in("session[email_address]", with: "sadsal@example.com")
      fill_in("session[password]", with: "password")
      first(:css, "#small_submit_button").click
      click_link_or_button("Book Itinerary")
      a = page.driver.browser.switch_to.alert
      a.accept

      listing.update_attributes(status: 1)

      visit user_bookings_path(slug: user.username)
      click_link_or_button("#{listing.title}")
      expect(page).to have_content("#{listing.title} has been retired from the listings")
      expect(page).not_to have_content("Add to Cart")
    end
  end

end
