require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
  test "admin menu options should be for admins" do
    assert display_menu?(Factory.build(:admin), :admin => true)
    assert !display_menu?(Factory.build(:user), :admin => true)
  end

  test "merchant menu options should be for merchants and admins" do
    assert display_menu?(Factory.build(:admin), :merchant => true)
    assert display_menu?(Factory.build(:user, :merchant => true), :merchant => true)
    assert !display_menu?(Factory.build(:user), :merchant=> true)
  end

  test "logged-in menu options should not be available publicly" do
    assert display_menu?(Factory.build(:user), :logged_in => true)
    assert !display_menu?(nil, :logged_in => true)
  end

  test "public menu options should be public" do
    assert display_menu?(Factory.build(:admin), {})
    assert display_menu?(Factory.build(:user, :merchant => true), {})
    assert display_menu?(Factory.build(:user), {})
    assert display_menu?(nil, {})
  end

  test "locale switch link should work as expected" do
    assert_equal "https://fr.domain.tld/path.extension?query=string&x=y",
      locale_switch_link("fr", "https://en.domain.tld/path.extension?query=string&x=y")
  end
end
