require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
  test "admin menu options should be for admins" do
    assert display_menu?(users(:admin), :admin => true)
    assert !display_menu?(users(:trader1), :admin => true)
  end

  test "merchant menu options should be for merchants and admins" do
    assert display_menu?(users(:admin), :merchant => true)
    assert display_menu?(users(:merchant), :merchant=> true)
    assert !display_menu?(users(:trader1), :merchant=> true)
  end

  test "logged-in menu options should not be available publicly" do
    assert display_menu?(users(:trader1), :logged_in => true)
    assert !display_menu?(nil, :logged_in => true)
  end

  test "public menu options should be public" do
    assert display_menu?(users(:admin), {})
    assert display_menu?(users(:merchant), {})
    assert display_menu?(users(:trader1), {})
    assert display_menu?(nil, {})
  end
end
