class ProductSearchService < SearchService

  def quick_search
    build('name', 'tag_line')
    Product.where(where_clause, where_args).order(updated_at: :desc)
  end
  
  def search_in_category(category_id)
    build('name', 'tag_line')
    category = Category.find(category_id)
    category.products.where(where_clause, where_args)
  end

end
