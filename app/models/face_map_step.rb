# == Schema Information
#
# Table name: face_map_steps
#
#  id          :integer          not null, primary key
#  number      :integer
#  description :text
#  face_map_id :integer
#  created_at  :datetime
#  updated_at  :datetime
#

class FaceMapStep < ActiveRecord::Base
  include Comparable
  
  belongs_to :face_map
  
  MARKUP_REGEX = /<[^>]*>/
  
  def markup_list
    description.scan(MARKUP_REGEX)
  end
  
  def has_markup?
    description =~ MARKUP_REGEX ? true : false
  end

  # Returns the a string composted of the step number followed by the unmerged description when the translator 
  # parameter is nil (e.g. '1. Apply the <role name>'), otherwise it returns the step number followed by the 
  # merged description (e.g. 1. Apply the Very Cool Product). Note the former contains the raw markup and the
  # later contains the corresponding product name the role name refers to.
  
  def to_s(translator=nil)
    "#{number}. #{translator.nil? ? description : merge_products(translator)}"
  end


  def <=>(other)
  self.number <=> other.number
  end
  
  
  def merge_products(translator)
    return description unless has_markup?
    markup_list.each_with_object(description.dup) do |markup, merged| 
      merged.gsub!(markup, "<span class='mu-product-name'>#{translate_markup(markup, translator)}</span>")    
    end
  end
  
  def ordered_product_role_array
    markup_list.map {|markup| markup_to_parameter_array(markup)}
  end

  

  private  
  
  # Returns the product name correlating to the category, role and optional subrole markup text.
  # Returns the original markup text if no corresponding product is found for the markup text.

  def translate_markup(markup, translator)
    params = markup_to_parameter_array(markup)
    val = translator.selected_product_app_markup_name(*params)
    val.nil? ? "(" + markup + " => Product not found)" : val
  end

  # Accepts a markup string containing 2-3 parameters separated by colons (e.g. "foo:way cool:another param") and 
  # returns an array of 2-3 strings. The values returned are all downcased, excess spaces between words removed, and 
  # beginning and trailing spaces are removed for each string parameter (e.g. ["category", "role", "optional subrole"])
  
  def markup_to_parameter_array(str)
    str.downcase.slice(1,str.size-2).strip.gsub(/[\s]+/, " ").split(/:/).map {|s| s.strip}
  end



  
end
