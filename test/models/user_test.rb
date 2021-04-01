require 'test_helper'

class UserTest < ActiveSupport::TestCase

  def setup
    @user = User.new(name: "Example User", email: "user@example.com",
                     password: "foobar", password_confirmation: "foobar") #テスト用に一つユーザーを定義
  end

  test "should be valid" do
    assert @user.valid? #新規で作ったオブジェクトが有効であるか
  end
  
  test "name should be present" do
     @user.name = "     "
     assert_not @user.valid? #１つ↑で定義した空欄がバリデートに引っ掛かればOK
   end
   
  test "email shoould be present" do
    @user.email = "     "
    assert_not @user.valid? #１つ↑で定義した空欄がバリデートに引っ掛かればOK
  end
  
  test "name should not be too long" do
    @user.name = "a" * 51 #aを５１文字作って５０文字以上制限のバリデートに引っ掛けるようにする
    assert_not @user.valid?
  end
  
  test "email should not be too long" do
    @user.email = "a" * 244 + "@example.com" #ドメインを含めて２５６文字に設定。２５５文字制限のバリデートに引っ掛ける
    assert_not @user.valid?
  end
  
  test "email validation should accept valid addresses" do
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org
                         first.last@foo.jp alice+bob@baz.cn] #有効なメールアドレスを定義→変数に代入　valid:有効
    valid_addresses.each do |valid_address| #each文で@user.emailに一つずつ代入していく
      @user.email = valid_address
      assert @user.valid?, "#{valid_address.inspect} should be valid" #assertの第2引数にエラーメッセージを渡す　式展開を使ってどのアドレスが引っかかったかを標示する
    end
  end
  
  test "email validation should reject invalid addresses" do
    invalid_addresses = %w[user@example,com foo@bar..com user_at_foo.org user.name@example. 
                           foo@bar_baz.com foo@bar+baz.com] #無効なアドレスを定義する 　　#invalid:無効
    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address #eachで１つずつ代入
      assert_not @user.valid?, "#{invalid_address.inspect} should be invalid" #無効なアドレスが引っ掛かればOK
    end
  end
  
  test "email addresses should be unique" do
    duplicate_user = @user.dup #dupデータの複製的なやつ
    @user.save
    assert_not duplicate_user.valid? #複製＝同じ名前、メールのユーザー　同じのは存在してはいけない
  end
  
  test "email addresses should be saved as lower-case" do
    mixed_case_email = "Foo@ExAMPle.CoM"
    @user.email = mixed_case_email
    @user.save
    assert_equal mixed_case_email.downcase, @user.reload.email #ここで小文字に変換したものとsaveした時のbeforeの小文字と比較
  end
  
  test "password should be present (nonblank)" do
    @user.password = @user.password_confirmation =" " * 6 #空欄はアウト
    assert_not @user.valid?
end
  
  test "password should have a minimum length" do
    @user.password = @user.password_confirmation = "a" * 5 #最小文字数の設定５文字で引っ掛かるようにする
    assert_not @user.valid?
  end
  
  test "authenticated? should return false for a user with nil digest" do
    assert_not @user.authenticated?(:remember, '')
  end
  
  test "associated microposts should be destroyed" do
    @user.save
    @user.microposts.create!(content: "Lorem ipsum")
    assert_difference 'Micropost.count', -1 do
      @user.destroy
    end
  end
end