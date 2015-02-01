module LooksHelper
  def full_name(product)
    fn = []
    fn << product.brand unless product.brand.blank?
    fn << product.line unless product.line.blank?
    fn << product.name unless product.name.blank?
    fn.join(" ")
  end
  
  def full_shade(product)
    fn = []
    fn << product.shade_name unless product.shade_name.blank?
    fn << product.shade_code
    fn.join(" ")
  end

  def random_product_img_filename
    ["product/img_1.png", "product/img_2.png", "product/img_3.png", 
     "product/img_5.jpg", "product/img_6.jpg", "product/img_7.jpg", "product/img_8.jpg", "product/img_9.jpg", 
     "product/img_10.jpg"][Random.rand(9)]
  end

  def physical_attributes(user)
    return {} if user.nil? || user.profile.nil?
    profile = user.profile
    vals = {}
    vals[:age] = profile.age unless profile.age.blank?
    vals[:eyes] = profile.eye_color unless profile.eye_color.blank?
    vals[:hair] = profile.hair_color unless profile.hair_color.blank?
    vals
  end
  
  def non_skin_physical_attribute_count(user)
    return 0 if user.nil? || user.profile.nil?
    profile = user.profile
    cnt=0
    cnt += 1 unless profile.age.blank?
    cnt += 1 unless profile.hair_color.blank?
    cnt += 1 unless profile.hair_color.blank?
    cnt
  end
  
  def product_role_count
    @set.default_product_apps.size
  end
  
  def total_product_cost
    cost = @set.default_product_apps.map {|app| app.product.price_cents}
    cost.inject(0, :+)/100.0
  end
  
  def number_to_aligned_currency(num, digit_count)

    ret_str = number_to_currency(num)
    
    # byebug
    return ret_str if significand_digit_count(ret_str) > digit_count 

    0.upto(digit_count - significand_digit_count(ret_str)) do |i|
      ret_str = ret_str.insert(1, " ")
    end
    ret_str
  end


  private
  
  def significand_digit_count(num_str)
    idx = num_str.index(".") - 1
  end



end
