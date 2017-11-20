class FindMovies
  attr_accessor :initial_scope

  def initialize(initial_scope)
    @initial_scope = initial_scope  
  end

  def call(params)
    scoped = @initial_scope
    if params[:recommendation] == 'Recommended'
      scoped = recommended(scoped, params[:current_user])
    elsif params[:recommendation] == 'Not recommended'
      scoped = not_recommended(scoped, params[:current_user])
    end
    scoped = search(scoped, params[:search]) unless params[:search] == ''
    scoped = search_by_genres(scoped, params[:genres]) unless params[:genres] == ''
    count = scoped.count
    scoped = paginate(scoped, params[:page], params[:sort])
    scoped.reverse_order! if params[:order] == "1"
    [scoped, message(params), count]
  end

  private

  def recommended(scoped, current_user)
    Movie.where(id: current_user.votes.where(value: 1).pluck(:movie_id))
  end

  def not_recommended(scoped, current_user)
    Movie.where(id: current_user.votes.where(value: -1).pluck(:movie_id))
  end

  def paginate(scoped, page, sort)
    sort == 'Date' ? scoped.order(:release_date ).page(page).per(10) : scoped.order(vote_average: :desc).page(page).per(10)
  end

  def search(scoped, query)
    query ? scoped.where('title ILIKE ?', "%#{query}%") : scoped
  end

  def search_by_genres(scoped, genres)
    genres ? scoped.where("genres @> ARRAY[?]::varchar[]", genres) : scoped
  end

  def message(params)
    message = params.except(:current_user, :page).values.delete_if(&:empty?).join(', ').downcase.sub('1', 'reversed  ').remove('0')[0...-2]
    message = 'all movies' if message.blank?
    message
  end
end