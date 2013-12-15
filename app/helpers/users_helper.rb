module UsersHelper
  def my_page?
    current_user == @user
  end

  def looking_for
    if current_user.orientation == "Bisexual"
      "everyone"
    elsif current_user.orientation == "Straight"
      current_user.gender == "M" ? "women" : "men"
    else
      current_user.gender == "F" ? "women" : "men"
    end
  end

  def filter_index
    if current_user.orientation == "Straight"
      current_user.gender == "M" ? search_gen = "F" : search_gen = "M"
      people = User.where(gender: search_gen, orientation: ["Straight",
         "Bisexual"])
    elsif current_user.orientation == "Gay"
      current_user.gender == "F" ? search_gen = "F" : search_gen = "M"
      people = User.where(gender: search_gen, orientation: ["Gay", "Bisexual"])
    elsif current_user.orientation == "Bisexual"
      current_user.gender == "M" ? search_gens = ["M","F"] : search_gens =
       ["F","M"]
      people = User.where(gender: search_gens[0], orientation: ["Gay",
       "Bisexual"]) + User.where(gender: search_gens[1], orientation:
       ["Straight", "Bisexual"])
    end

    people.where("age >= :min_age AND age <= :max_age",
    {min_age: current_user.profile.min_age,
     max_age: current_user.profile.max_age}) - [current_user]
  end

  def match(other_user)
    match_numerator, match_denominator, friend_numerator,
      friend_denominator = 0, 0, 0, 0

    current_user.responses.each do |response|
      other_users_response =
       other_user.responses.find_by_question_id(response.question)

      next if other_users_response == nil

      if response.ok_answers.include?(other_users_response.answer)
        match_numerator += response.importance
      end

      if response.answer == other_users_response.answer
        friend_numerator += response.importance
      end

      match_denominator += response.importance
      friend_denominator += response.importance
    end

    match = 0 if match_denominator == 0
    friend = 0 if friend_denominator == 0
    match = (match_numerator * 100) / match_denominator
    friend = (friend_numerator * 100) / friend_denominator

    {match: match, friend: friend}
  end
end
