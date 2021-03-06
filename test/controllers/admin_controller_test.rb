require 'test_helper'

class AdminControllerTest < ActionController::TestCase
  setup do
    sign_in users(:josh)
  end

  test "can request a MAL scrape" do
    fake_request({
      [:get, "http://myanimelist.net/anime/11757/"] => "mal_anime_11757_metadata",
      [:get, %r|http://cdn.myanimelist.net/images/.*|] => "blank_png"
    })
    Sidekiq::Testing.fake! do
      get :find_or_create_by_mal, mal_id: 11757, media: 'anime'
    end
    assert_instance_of Anime, assigns(:thing)
    assert_redirected_to assigns(:thing)
  end

  test "is invisible when not an admin" do
    sign_in users(:vikhyat)
    assert_raise ActionController::RoutingError do
      get :index
    end
  end

  test "can see stats" do
    get :stats, format: :json
    assert_response :success
    assert_includes JSON.parse(@response.body), "registrations"
  end
end
