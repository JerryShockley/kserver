require 'core_ext/string'

module ProductEnumerations
  extend Enumerize
  
  
  enumerize :category, in: [:cheeks, :eyes, :face, :lips]
  enumerize :role, in: [:basic_shadow, :bb_cream, :blush, :bronzer, :concealer, :contour, :crease_shadow, :foundation, 
                        :gloss, :highlight_shadow, :liner_bottom, :liner_top, :lipstick, :mascara, :pencil, :powder, 
                        :primer]
  
  FACE_ROLES ||= %w(BB\ Cream Bronzer Concealer Contour Foundation Powder Primer )
  EYE_ROLES ||= %w(Basic\ Shadow Crease\ Shadow Highlight\ Shadow Liner\ Bottom Liner\ Top Mascara Concealer)
  LIP_ROLES ||= %w(Gloss Lipstick Pencil)
  CHEEK_ROLES ||= %w(Blush Contour)

  
  ROLES_HASH ||= {
            face: FACE_ROLES.map { |e| e.snakecase.to_sym},
            eyes: EYE_ROLES.map { |e| e.snakecase.to_sym},
            lips: LIP_ROLES.map { |e| e.snakecase.to_sym},
            cheeks: CHEEK_ROLES.map { |e| e.snakecase.to_sym}
          }
      
  SIZE ||= {
            face: FACE_ROLES.size - 1,
            eyes: EYE_ROLES.size - 1,
            lips: LIP_ROLES.size - 1,
            cheeks: CHEEK_ROLES.size - 1 
          }
  
end