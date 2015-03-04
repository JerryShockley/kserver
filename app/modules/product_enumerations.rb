module ProductEnumerations
  extend Enumerize
  
  
  enumerize :category, in: [:cheeks, :eyes, :face, :lips]
  enumerize :role, in: [:basic_shadow, :bb_cream, :blush, :bronzer, :concealer, :contour, :crease_shadow, :foundation, 
                        :gloss, :highlight_shadow, :liner_bottom, :liner_top, :lipstick, :mascara, :pencil, :powder, 
                        :primer]
  
  FACE_ROLES = %w(BB\ Cream Bronzer Concealer Contour Foundation Powder Primer )
  EYE_ROLES = %w(Basic\ Shadow Crease\ Shadow Highlight\ Shadow Liner\ Bottom Liner\ Top Mascara)
  LIP_ROLES = %w(Gloss Lipstick Pencil)
  CHEEK_ROLES = %w(Blush Contour)
  
  
end