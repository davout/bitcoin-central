require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
  test "admin menu options should be for admins" do
    assert display_menu?(accounts(:admin), :admin => true)
    assert !display_menu?(accounts(:trader1), :admin => true)
  end

  test "merchant menu options should be for merchants and admins" do
    assert display_menu?(accounts(:admin), :merchant => true)
    assert display_menu?(accounts(:merchant), :merchant=> true)
    assert !display_menu?(accounts(:trader1), :merchant=> true)
  end

  test "logged-in menu options should not be available publicly" do
    assert display_menu?(accounts(:trader1), :logged_in => true)
    assert !display_menu?(nil, :logged_in => true)
  end

  test "public menu options should be public" do
    assert display_menu?(accounts(:admin), {})
    assert display_menu?(accounts(:merchant), {})
    assert display_menu?(accounts(:trader1), {})
    assert display_menu?(nil, {})
  end
end
