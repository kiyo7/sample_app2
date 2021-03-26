module SessionsHelper
  
  # 渡されたユーザーでログインする
  def log_in(user)
    session[:user_id] = user.id
  end
  
  # ユーザーのセッションを永続的にする
  def remember(user) # rememberメソッドにuser(ログイン時にユーザーが送ったメールとパスと同一の、DBにいるユーザー)を引数として渡す
    user.remember # ログイン時のユーザーと同一のDBのユーザーに、記憶トークンを生成して記憶ダイジェストにハッシュ化したハッシュ値を持たせて保存
    cookies.permanent.signed[:user_id] = user.id  # ログイン時のユーザーidを、有効期限(20年)と署名付きの暗号化したユーザーidとしてcookiesに保存
    cookies.permanent[:remember_token] = user.remember_token # ログイン時の記憶トークンを、有効期限（20年）を設定して新たなremember_tokenに保存。Userモデルにて、ログインユーザーと同一ならtrueを返す
  end
  
  # 記憶トークンcookieに対応するユーザーを返す
  def current_user
    if (user_id = session[:user_id]) 
      @current_user ||= User.find_by(id: user_id)
    elsif (user_id = cookies.signed[:user_id])
      user = User.find_by(id: user_id)
      if user && user.authenticated?(cookies[:remember_token])
        log_in user
        @current_user = user
      end
    end
  end
  
  # 渡されたユーザーがカレントユーザーであればtrueを返す
  def current_user?(user)
    user && user == current_user
  end
  
  # ユーザーがログインしていればtrue、その他ならfalseを返す
  def logged_in?
    !current_user.nil?
  end
  
  # 永続的セッションを破棄する
  def forget(user)
    user.forget #user.rbのforget起動
    cookies.delete(:user_id) #user_idの削除
    cookies.delete(:remember_token) #remember_tokenの削除
  end
  
   # 現在のユーザーをログアウトする
  def log_out
    forget(current_user)
    session.delete(:user_id)
    @current_user = nil
  end
  
  # 記憶したURL（もしくはデフォルト値）にリダイレクト
  def redirect_back_or(default)
    redirect_to(session[:forwarding_url] || default)
    session.delete(:forwarding_url)
  end
  
  # アクセスしようとしたURLを覚えておく
  def store_location
    session[:forwarding_url] = request.original_url if request.get?
  end
end