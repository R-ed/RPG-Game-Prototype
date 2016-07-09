#====================================================================
# Layy Meta Engine
# v.1.1
# Auteur : MGC
#
# Il s'agit d'un script basique de cartes en vue 3D isométrique
# pour RPG Maker VX Ace. Inutile tout seul car très limité, il est
# conçu pour être intégré dans des scripts de combats tactiques (TBS).
#
# - Affichage de cartes au format .layymeta créées via l'éditeur
# associé "Layy Meta Engine" en version 1.0 - Revision 9
# - Rotation à 360° de la carte
# - Possibilité de colorisation des tiles (pour l'affichage de portées)
# - Gestion des passabilités en fonction de l'altitude
#
# IMPORTANT : SI VOUS RENCONTREZ DU LAG, VEUILLEZ VOUS ASSURER D'AVOIR
# DECOCHE "REDUCE SCREEN FLICKERING" (F1).
#
# ATTENTION : en révision 10 (1.0.10), les fichiers .layymeta doivent être présents
# dans le dossier "Data_LM" et non "Data". Vous devez déplacer manuellement
# ces fichiers s'ils avaient été créés en révision antérieure.
#
# Nécessite :
# - le fichier MGC_Layy_Meta_1_5.dll à la racine du projet
#
# Configuration :
# - LM_DEFAULT_ANGLE : angle de rotation de la carte par défaut, en degrés
# - LM_SCAN_STEP : méthode de rafraîchissement de l'écran :
#         - 1 : l'écran est entièrement redessiné en 1 frame. Déconseillé
#               car extrêmement gourmand en ressources.
#         - 2 : l'écran est redessiné en 2 frames (une ligne de l'écran sur
#               deux est dessinée pour chaque frame).
# - LM_SHARP_SCAN_DIST : à utiliser avec LM_SCAN_STEP = 2, définit une largeur
#   au centre de l'écran à l'intérieure de laquelle la paramétrage
#   LM_SCAN_STEP = 1 est appliqué.
# - LM_DEFAULT_WALKABLE_HEIGHT : différence d'altitude en pixels entre deux
#   tiles sous laquelle les personnages peuvent se déplacer en marchant
# - LM_DEFAULT_JUMPABLE_HEIGHT : lors d'un déplacement vers un tile de plus
#   haute altitude, si la différence d'altitude en pixels est comprise entre
#   la valeur de LM_DEFAULT_WALKABLE_HEIGHT et cette valeur, alors les
#   personnages peuvent effectuer le déplacement en sautant. Au delà le
#   déplacement n'est pas autorisé.
# - LM_DEFAULT_MAX_FALL_HEIGHT : lors d'un déplacement vers un tile de plus
#   basse altitude, si la différence d'altitude en pixels est comprise entre
#   la valeur de LM_DEFAULT_WALKABLE_HEIGHT et cette valeur, alors les
#   personnages peuvent effectuer le déplacement en tombant. Au delà le
#   déplacement n'est pas autorisé.
# - LM_OFFSET_SPRITES : décalage vertical des sprites des characters en pixels
#   pour corriger l'affichage quand les 'pieds' d'un personnage sont plus hauts
#   que le bas de son sprite.
# - LM_CAMERA_FOLLOW_JUMP : si activé (true), la caméra suit le personnage
#   avec le focus même pendant les sauts.
#
# Utilisation :
# Commandes utilisables comme commandes d'évènement avec Script... :
# - Layy_Meta.map_rotation_angle = nouvel angle
#   définit l'angle de rotation de la carte
# - Layy_Meta.rotate_by(angle, durée de transition)
#   effectue une rotation d'un certain angle (le signe de l'angle spécifie le sens)
#   la durée de transition est exprimée en frames
# - Layy_Meta.focus_on_character(instance de Game_CharacterBase, durée de transition)
#   la caméra suit le personnage ou événement
# - Layy_Meta.focus_on_coordinates(x, y, durée de transition)
#   la caméra se fixe sur des coordonnées (x, y) de la carte
#   la durée de transition est exprimée en frames
# - Layy_Meta.to_zoom(nouvelle valeur de zoom, durée de la transition)
#   la valeur de zoom est comprise entre 0.25 et 2.0
#   la durée de transition est exprimée en frames
#====================================================================
module Layy_Meta
  #--------------------------------------------------------------------------
  # * CONFIGURATION
  #--------------------------------------------------------------------------
  LM_DEFAULT_ANGLE = 45
  LM_SCAN_STEP = 2 # 1 : better looking, more lag / 2 : worse looking, less lag
  LM_SHARP_SCAN_DIST = 160 # in pixels
  LM_DEFAULT_WALKABLE_HEIGHT = 8 # in pixels
  LM_DEFAULT_JUMPABLE_HEIGHT = 24 # in pixels
  LM_DEFAULT_MAX_FALL_HEIGHT = 24 # in pixels
  LM_OFFSET_SPRITES = {'$Slime'=>8} # example : {'Actor5'=>-8,'!Chest'=>4}
  LM_CAMERA_FOLLOW_JUMP = false
  #--------------------------------------------------------------------------
  # * Constantes
  #--------------------------------------------------------------------------
  RENDER = Win32API.new("MGC_Layy_Meta_1_5", "renderView", "llll", "l")
  #--------------------------------------------------------------------------
  # * Renvoie true si le module Layy Meta est activé
  # return boolean
  #--------------------------------------------------------------------------
  def self.active
    return @active && $game_map.is_layy_meta? #[R12]
  end
  #--------------------------------------------------------------------------
  # * Mutateur de l'angle de rotation de la carte (angle en degrés)
  # param new_angle : integer
  #--------------------------------------------------------------------------
  def self.map_rotation_angle=(new_angle)
    @map_rotation_angle = new_angle % 360
    new_angle_rad = new_angle * Math::PI / 180
    @map_rotation_angle_cos = (4096 * Math.cos(new_angle_rad)).to_i
    @map_rotation_angle_sin = (4096 * Math.sin(new_angle_rad)).to_i
    call_update
  end
  #--------------------------------------------------------------------------
  # * Accesseur de l'angle de rotation de la carte (angle en degrés)
  # return integer ([0, 359])
  #--------------------------------------------------------------------------
  def self.map_rotation_angle
    return @map_rotation_angle
  end
  #--------------------------------------------------------------------------
  # * Accesseur du cosinus de l'angle de rotation de la carte, amplifié
  # d'un facteur 4096
  # return integer ([-4096, 4096])
  #--------------------------------------------------------------------------
  def self.cos_angle
    return @map_rotation_angle_cos
  end
  #--------------------------------------------------------------------------
  # * Accesseur du sinus de l'angle de rotation de la carte, amplifié
  # d'un facteur 4096
  # return integer ([-4096, 4096])
  #--------------------------------------------------------------------------
  def self.sin_angle
    return @map_rotation_angle_sin
  end
  #--------------------------------------------------------------------------
  # * Mutateur de l'origine horizontale du rendu dans le repère de la carte
  # param new_display_x : integer (en px * 8)
  #--------------------------------------------------------------------------
  def self.display_x=(new_display_x)
    @display_x = new_display_x
    @vars[0] = @display_x >> 3
    call_update
  end
  #--------------------------------------------------------------------------
  # * Accesseur de l'origine horizontale du rendu dans le repère de la carte
  # return integer (en px * 8)
  #--------------------------------------------------------------------------
  def self.display_x
    return @display_x
  end
  #--------------------------------------------------------------------------
  # * Mutateur de l'origine verticale du rendu dans le repère de la carte
  # param new_display_y : integer (en px * 8)
  #--------------------------------------------------------------------------
  def self.display_y=(new_display_y)
    @display_y = new_display_y
    @vars[1] = @display_y >> 3
    call_update
  end
  #--------------------------------------------------------------------------
  # * Accesseur de l'origine verticale du rendu dans le repère de la carte
  # return integer (en px * 8)
  #--------------------------------------------------------------------------
  def self.display_y
    return @display_y
  end
  #--------------------------------------------------------------------------
  # * Mutateur de l'origine horizontale du rendu dans le repère de l'écran
  # param new_offset_x : integer (en px * 8)
  #--------------------------------------------------------------------------
  def self.offset_x=(new_offset_x)
    @offset_x = new_offset_x
    @vars[3] = @offset_x >> 3
    @translation = true
    call_update
  end
  #--------------------------------------------------------------------------
  # * Accesseur de l'origine horizontale du rendu dans le repère de l'écran
  # return integer (en px * 8)
  #--------------------------------------------------------------------------
  def self.offset_x
    return @offset_x
  end
  #--------------------------------------------------------------------------
  # * Mutateur de l'origine verticale du rendu dans le repère de l'écran
  # param new_offset_y : integer (en px * 8)
  #--------------------------------------------------------------------------
  def self.offset_y=(new_offset_y)
    @offset_y = new_offset_y
    @vars[4] = @offset_y >> 3
    @translation = true
    call_update
  end
  #--------------------------------------------------------------------------
  # * Accesseur du décalage en altitude du rendu
  # return integer (en px)
  #--------------------------------------------------------------------------
  def self.offset_h
    return @offset_h
  end
  #--------------------------------------------------------------------------
  # * Mutateur du décalage en altitude du rendu
  # param new_offset_y : integer (en px * 8)
  #--------------------------------------------------------------------------
  def self.offset_h=(new_offset_h)
    unless new_offset_h == @offset_h
      @offset_h = new_offset_h
      @vars[6] = @offset_h
      call_update
    end
  end
  #--------------------------------------------------------------------------
  # * Accesseur de l'origine verticale du rendu dans le repère de l'écran
  # return integer (en px * 8)
  #--------------------------------------------------------------------------
  def self.offset_y
    return @offset_y
  end
  #--------------------------------------------------------------------------
  # * [R5] Mutateur de la valeur de zoom
  # param new_zoom : Float
  #--------------------------------------------------------------------------
  def self.zoom=(new_zoom)
    unless @zoom == new_zoom
      if new_zoom < 0.25 || new_zoom > 2.0 then return end
      @zoom = new_zoom
      @vars[7] = ((1.0 / @zoom) * 4096).to_i
      @zoom_incr = Math.log(@zoom) / Math.log(2)
      call_update
    end
  end
  #--------------------------------------------------------------------------
  # * [R5] Accesseur de la valeur de zoom
  # return Float
  #--------------------------------------------------------------------------
  def self.zoom
    return @zoom
  end
  #--------------------------------------------------------------------------
  # * [R5] Incrémentation de la valeur du zoom
  #--------------------------------------------------------------------------
  def self.incr_zoom(val = 0.02)
    new_zoom_incr = @zoom_incr + val
    new_zoom = 2 ** new_zoom_incr
    self.zoom = new_zoom
  end
  #--------------------------------------------------------------------------
  # * [R5] Pour aller progressivement vers une nouvelle valeur de zoom
  #--------------------------------------------------------------------------
  def self.to_zoom(new_zoom, duration)
    unless @zoom == new_zoom
      if new_zoom < 0.25 || new_zoom > 2.0 then return end
      if @translation
        @translation = false
        check_translation_end
      end
      target_zoom_incr = Math.log(new_zoom) / Math.log(2)
      zoom_step = (target_zoom_incr - @zoom_incr) / duration
      @zooming = true
      duration.times do |i|
        if duration == 0
          self.zoom = new_zoom
        else
          self.incr_zoom(zoom_step)
        end
        SceneManager.scene.update_for_lm_transition
      end
      @zooming = false
    end
  end
  #--------------------------------------------------------------------------
  # * [R5] Vérifie si le zoom est en cours
  # return boolean
  #--------------------------------------------------------------------------
  def self.zooming?
    return @zooming
  end
  #--------------------------------------------------------------------------
  # * Force le mode translation qui le repère de l'écran pour l'origine
  # du rendu
  #--------------------------------------------------------------------------
  def self.force_translation
    @translation = true
  end
  #--------------------------------------------------------------------------
  # * Renvoie true si le mode translation est activé
  # return boolean
  #--------------------------------------------------------------------------
  def self.translation?
    return @translation
  end
  #--------------------------------------------------------------------------
  # * Accesseur de la carte en vue isométrique
  # return Layy_Meta::Map
  #--------------------------------------------------------------------------
  def self.map
    return @map
  end
  #--------------------------------------------------------------------------
  # * Accesseur de l'attribut visible
  # return boolean
  #--------------------------------------------------------------------------
  def self.visible
    return @visible
  end
  #--------------------------------------------------------------------------
  # * Initialisation
  # param viewport : Viewport
  #--------------------------------------------------------------------------
  def self.show_lm(viewport)
    initialize_map
    # initialisation du sprite contenant le rendu isométrique de la carte
    unless @visible
      @sprite_lm = Sprite.new(viewport)
      @sprite_lm.bitmap = @render_lm
    end
    @visible = true
    @force_update = true
    call_update
  end
  #--------------------------------------------------------------------------
  # * Initialisation des données de la carte
  #--------------------------------------------------------------------------
  def self.initialize_map
    @active = true
    # initialisation de l'origine et de l'angle de rotation si changement
    # de carte
    if @map != $game_map.lm_map
      @map = $game_map.lm_map
      @display_x = 0
      @display_y = 0
      @offset_x = 0
      @offset_y = 0
      @offset_h = 0
      self.map_rotation_angle = Layy_Meta::LM_DEFAULT_ANGLE
    end
    # initialisation du sprite contenant le rendu isométrique de la carte
    if @render_lm
      @render_lm.dispose
      @render_lm_sprites.dispose
    end
    @render_lm = Bitmap.new(Graphics.width, Graphics.height)
    if @visible && @sprite_lm && !@sprite_lm.disposed?
      @sprite_lm.bitmap = @render_lm
    end
    @render_lm_sprites = Bitmap.new(Graphics.width, Graphics.height)
    @params = [@render_lm, @map.data, @map.width, @map.height,
    @map.textureset, @render_lm_sprites, 0, 0] # [R2] [R8]
    @translation = false
    @filter = Layy_Meta::LM_SCAN_STEP == 2
    @vars = [@display_x >> 3, @display_y >> 3, @filter ? 1 : 0,
    @offset_x >> 3, @offset_y >> 3, [], @offset_h, 4096,
    Layy_Meta::LM_SHARP_SCAN_DIST] # [R2]
    @zoom = 1.0 # [R5]
    @zoom_incr = Math.log(@zoom) / Math.log(2) # [R5]
    @old_display_x = @display_x
    @old_display_y = @display_y
    focus_on_character($game_player)
  end
  #--------------------------------------------------------------------------
  # * Accesseur du sprite contenant le rendu isométrique de la carte
  # return Sprite
  #--------------------------------------------------------------------------
  def self.sprite_lm
    return @sprite_lm
  end
  #--------------------------------------------------------------------------
  # * Dispose
  #--------------------------------------------------------------------------
  def self.dispose
    if @active #[R12]
      unless @sprite_lm.nil?
        @render_lm.dispose
        @sprite_lm.dispose
        @render_lm_sprites.dispose
      end
      @active = false
      @visible = false
    end
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def self.update
    if self.active #[R12]
      update_input
      check_translation_end
      update_animations # [R8]
      if @need_update
        if @filter && @force_update
          old_value = @vars[2]
          @vars[2] = 0
          @force_update = false
          Layy_Meta::RENDER.call(@params.__id__, @map_rotation_angle_cos,
          @map_rotation_angle_sin, @vars.__id__)
          @vars[2] = old_value
        else
          Layy_Meta::RENDER.call(@params.__id__, @map_rotation_angle_cos,
          @map_rotation_angle_sin, @vars.__id__)
        end
        if @filter
          @vars[2] = 3 - @vars[2]
          @filter_count -= 1
          @need_update = @filter_count == 1
        else
          @need_update = false
        end
      end
      @translation_old = @translation
      @translation = false
    end
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def self.update_input
    if Input.trigger?(:L)
      rotate_by(90, 15)
    elsif Input.trigger?(:R)
      rotate_by(-90, 15)
    end
  end
  #--------------------------------------------------------------------------
  # * Vérifie s'il s'agit de la fin du mode translation, et bascule
  # complètement dans le repère de la carte le cas échéant
  #--------------------------------------------------------------------------
  def self.check_translation_end(force = false)
    if force || @translation_old && !@translation
      dist_x = (2048 + (@offset_x * 3 * @map_rotation_angle_cos >> 1) +
      @offset_y * 3 * @map_rotation_angle_sin >> 13)
      dist_y = (2048 + @offset_y * 3 * @map_rotation_angle_cos -
      (@offset_x * 3 * @map_rotation_angle_sin >> 1) >> 13)
      unless @zoom == 1.0 # [R5]
        dist_x = (dist_x / @zoom).to_i
        dist_y = (dist_y / @zoom).to_i
      end
      @display_x += dist_x
      @vars[0] = @display_x >> 3
      @display_y += dist_y
      @vars[1] = @display_y >> 3
      @offset_x = 0
      @vars[3] = 0
      @offset_y = 0
      @vars[4] = 0
      call_update
    end
  end
  #--------------------------------------------------------------------------
  # * Demande le rafraîchissement du rendu isométrique
  #--------------------------------------------------------------------------
  def self.call_update
    if @filter
      @filter_count = 2
    end
    @need_update = true
  end
  #--------------------------------------------------------------------------
  # * Affecte les données des characters à afficher avec la carte isométrique
  # param characters : Array<Array[6]> (Sprite_Character.get_lm_data)
  #--------------------------------------------------------------------------
  def self.set_characters(characters)
    @vars[5] = characters
    call_update
  end
  #--------------------------------------------------------------------------
  # * Centre la caméra sur un character et le suit
  # param character : Game_CharacterBase
  # param duration : integer (>0)
  #--------------------------------------------------------------------------
  def self.focus_on_character(character, duration = 1)
    unless @focus_character == character
      @focus_character = character
      execute_focus_on_coordinates(character.real_x, character.real_y, duration)
    end
  end
  #--------------------------------------------------------------------------
  # * Centre la caméra sur un tile de la carte
  # param x : integer ([0, $game_map.width[)
  # param y : integer ([0, $game_map.height[)
  # param duration : integer (>0)
  #--------------------------------------------------------------------------
  def self.focus_on_coordinates(x, y, duration = 1)
    @focus_character = nil
    execute_focus_on_coordinates(x, y, duration)
  end
  #--------------------------------------------------------------------------
  # * Exécute le centrage de la caméra sur de coordonnées de la carte
  # param x : integer ([0, $game_map.width[)
  # param y : integer ([0, $game_map.height[)
  # param duration : integer (>0)
  #--------------------------------------------------------------------------
  def self.execute_focus_on_coordinates(x, y, duration = 1)
    display_x_target = (16 + x * 32).to_i - (Graphics.width >> 1) << 3
    display_y_target = (16 + y * 32).to_i - (Graphics.height >> 1) << 3
    display_h_target = $game_map.get_altitude(x.to_i, y.to_i)
    if @translation
      @translation = false
      check_translation_end
    end
    if duration > 1
      dx = display_x_target - @display_x
      if dx < 0
        coeff_x = -1
        dx = -dx
      else
        coeff_x = 1
      end
      dy = display_y_target - @display_y
      if dy < 0
        coeff_y = -1
        dy = -dy
      else
        coeff_y = 1
      end
      dh = display_h_target - @offset_h
      if dh < 0
        coeff_h = -1
        dh = -dh
      else
        coeff_h = 1
      end
      incr_x = dx.to_f / duration
      incr_y = dy.to_f / duration
      incr_h = dh.to_f / duration
      total_x = 0.0
      total_y = 0.0
      total_h = 0.0
      display_x_start = @display_x
      display_y_start = @display_y
      display_h_start = @offset_h
      duration.times do |i|
        if total_x + incr_x > dx
          incr_x = dx - total_x
        end
        if total_y + incr_y > dy
          incr_y = dy - total_y
        end
        if total_h + incr_h > dh
          incr_h = dh - total_h
        end
        total_x += incr_x
        total_y += incr_y
        total_h += incr_h
        self.display_x = display_x_start + (coeff_x * total_x).to_i
        self.display_y = display_y_start + (coeff_y * total_y).to_i
        self.offset_h = display_h_start + (coeff_h * total_h).to_i
        SceneManager.scene.update_for_lm_transition
      end
    end
    self.display_x = display_x_target
    self.display_y = display_y_target
    self.offset_h = display_h_target
  end
  #--------------------------------------------------------------------------
  # * Retourne le character actuellement suivi par la caméra
  # return Game_CharacterBase (ou nil s'il n'y en a pas)
  #--------------------------------------------------------------------------
  def self.focused_character
    return @focus_character
  end
  #--------------------------------------------------------------------------
  # * Effectue une rotation de la carte d'un certain angle
  # angle : integer (positif ou négatif)
  # param duration : integer (>0)
  #--------------------------------------------------------------------------
  def self.rotate_by(angle, duration)
    if @translation
      @translation = false
      check_translation_end
    end
    if angle < 0
      coeff = -1
      angle = -angle
    else
      coeff = 1
    end
    incr = angle.to_f / duration # [R12]
    total_rotation = 0
    duration.times do |i|
      if total_rotation + incr > angle
        incr = angle - total_rotation
      end
      total_rotation += incr
      self.map_rotation_angle += coeff * incr
      if i == duration - 1 # [R12]
        self.map_rotation_angle =  map_rotation_angle.round.to_i
      end
      SceneManager.scene.update_for_lm_transition
    end
  end
  #--------------------------------------------------------------------------
  # * [R8] Mise à jour des tiles animés
  #--------------------------------------------------------------------------
  def self.update_animations
    if Graphics.frame_count % 20 == 0
      if @map.refresh_tiles_animation
        call_update
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Vérifie si un effet est en cours [R13]
  #--------------------------------------------------------------------------
  def self.effect?
    return @active && (translation? || zooming?)
  end
end

#==============================================================================
# ** Layy_Meta::Map_Data
#------------------------------------------------------------------------------
#  Données d'une carte isométrique issue de l'éditeur
#==============================================================================
module Layy_Meta
  class Map_Data
    #--------------------------------------------------------------------------
    # * Public Instance Variables
    #--------------------------------------------------------------------------
    attr_accessor :data, :tileset_name, :map_name
    attr_accessor :used_tiles_map, :textureset_data, :textureset_data_tilesets # [R8]
    attr_reader :map_id, :width, :height
  end
end

#==============================================================================
# ** Layy_Meta::Map
#------------------------------------------------------------------------------
#  Carte isométrique manipulable, liée à Game_Map
#==============================================================================
module Layy_Meta
  class Map
    #--------------------------------------------------------------------------
    # * Public Instance Variables
    #--------------------------------------------------------------------------
    attr_accessor :data, :tileset_name, :map_name
    attr_reader :map_id, :width, :height
    attr_accessor :textureset # Bitmap [R8] [R13]
    #--------------------------------------------------------------------------
    # * Initialisation
    # param width : integer (largeur de la carte, donc égal à $game_map.width)
    # param height : integer (hauteur de la carte, donc égal à $game_map.height)
    # param name : String (nom du fichier de la carte isométrique)
    # param tileset_name : String (nom du tileset utilisé)
    # param map_data : Array[width * height]<Array[16]<integer>>
    #       - altitude en pixels [-256, +256]
    #       - id tile dessus
    #       - id tile paroi devant
    #       - id tile paroi gauche
    #       - id tile paroi droite
    #       - id tile paroi derrière
    #       - coloration en bleu [0, 255]
    #       - coloration en vert [0, 255]
    #       - coloration en rouge [0, 255]
    #       - côtés subissant la coloration [1, 31]
    #       - indicateur technique (down)
    #       - indicateur technique (right)
    #       - indicateur technique (up)
    #       - indicateur technique (left)
    #       - pente {0 (no slope), 1 (down), 2 (left), 3 (right), 4 (up)}
    #       - hauteur de pente en px
    # param textureset_data_tilesets : Array<String> liste des noms des tilesets utilisés
    # param textureset_data : Array<Array> données de création du textureset
    #--------------------------------------------------------------------------
    def initialize(width, height, name, tileset_name, map_data = nil,
      textureset_data_tilesets = nil, textureset_data = nil) # [R8]
      @width = width
      @height = height
      self.map_name = name
      self.data = Array.new(width * height)
      @tiles = Array.new(width * height)
      @animated_textures = [] # [R8]
      data.each_index {|index|
        data[index] = map_data[index]
        if data[index].size == 14 # [R2]
          data[index][14] = 0
          data[index][15] = 0
          data[index][16] = 0 # [R8]
          data[index][17] = 0 # [R8]
        elsif data[index].size == 16 # [R8]
          data[index][16] = 0
          data[index][17] = 0
        end
        @tiles[index] = Layy_Meta::Tile.new(data[index])
      }
      self.tileset_name = tileset_name
      # [R8] DEB
      if textureset_data_tilesets && textureset_data
        create_textureset_from_data(textureset_data_tilesets, textureset_data)
      else # compatibility
        @textureset = Cache.tileset(tileset_name)
      end
      # [R8] FIN
    end
    #--------------------------------------------------------------------------
    # * Retourne les données d'un tile par ses coordonées
    # param x : integer ([0, width[)
    # param y : integer ([0, height[)
    # return Array[10]<integer> (map_Data)
    #--------------------------------------------------------------------------
    def get_data(x, y)
      return data[get_index(x, y)]
    end
    #--------------------------------------------------------------------------
    # * Retourne l'index d'un tile par ses coordonées
    # param x : integer ([0, width[)
    # param y : integer ([0, height[)
    # return integer (> 0)
    #--------------------------------------------------------------------------
    def get_index(x, y)
      return x + y * width
    end
    #--------------------------------------------------------------------------
    # * Retourne l'abscisse d'un tile par son index
    # return integer ([0, width[)
    #--------------------------------------------------------------------------
    def get_x(index)
      return index - width * (index / width)
    end
    #--------------------------------------------------------------------------
    # * Retourne l'ordonnée d'un tile par son index
    # return integer ([0, height[)
    #--------------------------------------------------------------------------
    def get_y(index)
      return index / width
    end
    #--------------------------------------------------------------------------
    # * Retourne un tile lisible et manipulable
    # param x : integer ([0, width[)
    # param y : integer ([0, height[)
    # return Layy_Meta::Tile (nouvelle instance)
    #--------------------------------------------------------------------------
    def get_tile(x, y)
      return @tiles[get_index(x, y)]
    end
    #--------------------------------------------------------------------------
    # * [R8] Création du textureset
    # param textureset_data_tilesets : Array<String> liste des noms des tilesets utilisés
    # param textureset_data : Array<Array> données de création du textureset
    #--------------------------------------------------------------------------
    def create_textureset_from_data(textureset_data_tilesets, textureset_data)
      rect = Rect.new(0, 0, 32, 32)
      textureset_height = 1 + (textureset_data.size >> 3) << 5
      @textureset = Bitmap.new(256, textureset_height)
      textureset_data.each_index {|texture_id|
        t_dat = textureset_data[texture_id]
        if t_dat
          x_trg = texture_id - (texture_id >> 3 << 3) << 5
          y_trg = texture_id >> 3 << 5
          t_set_name = textureset_data_tilesets[t_dat[0]]
          src = Cache.tileset(t_set_name)
          case t_dat[1]
          when :normal
            rect.width = 32
            rect.height = 32
            rect.x = t_dat[2][0]
            rect.y = t_dat[2][1]
            textureset.blt(x_trg, y_trg, src, rect)
            if t_dat[3]
              @animated_textures << Layy_Meta::Animated_Tile.new(x_trg, y_trg,
              t_set_name, t_dat[3][0], t_dat[3][1], :normal, [rect.x, rect.y])
            end
          when :auto_VX
            rect.width = 16
            rect.height = 16
            autotile_data = t_dat[2]
            (0...4).each {|i|
              rect.y = autotile_data[i] >> 2 << 4
              rect.x = autotile_data[i] - (autotile_data[i] >> 2 << 2) << 4
              textureset.blt(x_trg + ((i & 1) << 4), y_trg + ((i & 2) << 3),
              src, rect)
            }
            if t_dat[3]
              @animated_textures << Layy_Meta::Animated_Tile.new(x_trg, y_trg,
              t_set_name, t_dat[3][0], t_dat[3][1], :auto_VX, autotile_data)
            end
          when :auto_XP
            rect.width = 16
            rect.height = 16
            autotile_data = t_dat[2]
            (0...4).each {|i|
              rect.y = autotile_data[i] / 6 << 4
              rect.x = autotile_data[i] - (autotile_data[i] / 6 * 6) << 4
              textureset.blt(x_trg + ((i & 1) << 4), y_trg + ((i & 2) << 3),
              src, rect)
            }
            if t_dat[3]
              @animated_textures << Layy_Meta::Animated_Tile.new(x_trg, y_trg,
              t_set_name, t_dat[3][0], t_dat[3][1], :auto_XP, autotile_data)
            end
          end
        end
      }
    end
    #--------------------------------------------------------------------------
    # * [R8] Met à jour les tiles animés
    # return Boolean (true si des mises à jour ont été effectuées)
    #--------------------------------------------------------------------------
    def refresh_tiles_animation
      need_refresh = false
      @animated_textures.each {|animated_tile|
        animated_tile.next(@textureset)
        need_refresh = true
      }
      return need_refresh
    end
  end
end

#==============================================================================
# ** Layy_Meta::Tile
#------------------------------------------------------------------------------
#  Tile isométrique manipulable
#==============================================================================
module Layy_Meta
  class Tile
    #--------------------------------------------------------------------------
    # * Public Instance Variables
    #--------------------------------------------------------------------------
    attr_reader :altitude, :tile_id_top, :tile_id_front, :tile_id_left,
    :tile_id_right, :tile_id_back, :tone, :previous_tone, :colored_faces
    #--------------------------------------------------------------------------
    # * Initialisation
    # param data : Array[10]<integer> (cf. Layy_Meta::Map)
    #--------------------------------------------------------------------------
    def initialize(data)
      @data = data
      @altitude = data[0]
      @tile_id_top = data[1]
      @tile_id_front = data[2]
      @tile_id_left = data[3]
      @tile_id_right = data[4]
      @tile_id_back = data[5]
      @tone = Tone.new(data[8], data[7], data[6])
      @colored_faces = data[9]
      @previous_tone = Tone.new(0, 0, 0)
      @tone_save = true
    end
    #--------------------------------------------------------------------------
    # * Change la coloration du tile
    # param new_tone : Tone
    # param colored_faces : integer ([1, 31])
    #         1 : dessus
    #         2 : devant (à angle = 0)
    #         4 : côté gauche (à angle = 0)
    #         8 : arrière (à angle = 0)
    #         16 : côté droit (à angle = 0)
    #--------------------------------------------------------------------------
    def set_tone(new_tone, colored_faces = 1, tone_save = true)
      @colored_faces = colored_faces
      unless @data[8] == new_tone.red.to_i && @data[7] == new_tone.green.to_i &&
        @data[6] == new_tone.blue.to_i && @data[9] == colored_faces
      then
        if @tone_save
          previous_tone.set(tone)
        end
        @tone_save = tone_save
        tone.set(new_tone)
        @data[8] = tone.red.to_i
        @data[7] = tone.green.to_i
        @data[6] = tone.blue.to_i
        @data[9] = colored_faces
        Layy_Meta.call_update
      end
    end
    #--------------------------------------------------------------------------
    # * Change la coloration du tile
    # param new_tone : Tone
    #--------------------------------------------------------------------------
    def add_tone(new_tone, colored_faces = 1, tone_save = true)
      unless new_tone.red.to_i == 0 && new_tone.green.to_i == 0 &&
        new_tone.blue.to_i == 0
      then
        if @tone_save
          previous_tone.set(tone)
        end
        @tone_save = tone_save
        tone.set(tone.red + new_tone.red.to_i, tone.green + new_tone.green.to_i,
        tone.blue + new_tone.blue.to_i)
        @data[8] = tone.red.to_i
        @data[7] = tone.green.to_i
        @data[6] = tone.blue.to_i
        Layy_Meta.call_update
      end
    end
    #--------------------------------------------------------------------------
    # * Change la coloration du tile
    # param new_tone : Tone
    #--------------------------------------------------------------------------
    def set_previous_tone
      unless previous_tone == tone
        tone.set(previous_tone)
        @data[8] = tone.red.to_i
        @data[7] = tone.green.to_i
        @data[6] = tone.blue.to_i
        Layy_Meta.call_update
      end
    end
    #--------------------------------------------------------------------------
    # * Sélectionne le tile
    #--------------------------------------------------------------------------
    def select
      new_val = @data[9] | 32
      unless @data[9] == new_val
        @data[9] = new_val
        Layy_Meta.call_update
      end
    end
    #--------------------------------------------------------------------------
    # * Désélectionne le tile
    #--------------------------------------------------------------------------
    def deselect
      new_val = @data[9] % 32
      unless @data[9] == new_val
        @data[9] = new_val
        Layy_Meta.call_update
      end
    end
    #--------------------------------------------------------------------------
    # * Change le tile du tileset utilisé pour le dessus du tile isométrique
    # param new_tile_id_top : integer
    #--------------------------------------------------------------------------
    def tile_id_top=(new_tile_id_top)
      @tile_id_top = new_tile_id_top
      unless @data[1] == new_tile_id_top
        @data[1] = new_tile_id_top
        Layy_Meta.call_update
      end
    end
    #--------------------------------------------------------------------------
    # * Change le tile du tileset utilisé pour la paroi de devant (angle = 0)
    # param tile_id_front : integer
    #--------------------------------------------------------------------------
    def tile_id_front=(new_tile_id_front)
      @tile_id_front = new_tile_id_front
      unless @data[2] == new_tile_id_front
        @data[2] = new_tile_id_front
        Layy_Meta.call_update
      end
    end
    #--------------------------------------------------------------------------
    # * Change le tile du tileset utilisé pour la paroi de gauche (angle = 0)
    # param tile_id_left : integer
    #--------------------------------------------------------------------------
    def tile_id_left=(new_tile_id_left)
      @tile_id_left = new_tile_id_left
      unless @data[3] == new_tile_id_left
        @data[3] = new_tile_id_left
        Layy_Meta.call_update
      end
    end
    #--------------------------------------------------------------------------
    # * Change le tile du tileset utilisé pour la paroi de droite (angle = 0)
    # param tile_id_right : integer
    #--------------------------------------------------------------------------
    def tile_id_right=(new_tile_id_right)
      @tile_id_right = new_tile_id_right
      unless @data[4] == new_tile_id_right
        @data[4] = new_tile_id_right
        Layy_Meta.call_update
      end
    end
    #--------------------------------------------------------------------------
    # * Change le tile du tileset utilisé pour la paroi de derrière (angle = 0)
    # param tile_id_back : integer
    #--------------------------------------------------------------------------
    def tile_id_back=(new_tile_id_back)
      @tile_id_back = new_tile_id_back
      unless @data[5] == new_tile_id_back
        @data[5] = new_tile_id_back
        Layy_Meta.call_update
      end
    end
  end
end

#====================================================================
# Layy Meta Editor
# v.1.0
# Author : MGC
#====================================================================
#==============================================================================
# ** [R8] Layy_Meta::Animated_Tile
#==============================================================================
module Layy_Meta
  class Animated_Tile
    #--------------------------------------------------------------------------
    # * Initialisation
    # param x_texture : Integer (x-coordinate in textureset, in px)
    # param y_texture : Integer (y-coordinate in textureset, in px)
    # param tileset_name : String
    # param nb_patterns : Integer
    # param offset : Integer (distance between two patterns)
    # param style : Symbol (:normal, :auto_XP, :auto_VX)
    # param params : Array[2]<Integer> (coordinates in tileset, in px)
    #             OR Array[4]<Integer> (coordinates in autosubset, in px)
    #--------------------------------------------------------------------------
    def initialize(x_texture, y_texture, tileset_name, nb_patterns, offset,
      style, params)
      @x_texture = x_texture
      @y_texture = y_texture
      @tileset_name = tileset_name
      @nb_patterns = nb_patterns
      @offset = offset << 5
      @style = style
      @params = params
      @rect = Rect.new(0, 0, 32, 32)
      if @style == :auto_XP || @style == :auto_VX
        @rect.width = 16
        @rect.height = 16
      end
      @current_pattern = 0
    end
    #--------------------------------------------------------------------------
    # * Remplace le motif dans le textureset par le motif d'animation suivant
    # param textureset : Bitmap
    #--------------------------------------------------------------------------
    def next(textureset)
      @current_pattern += 1
      @current_pattern %= @nb_patterns
      src = Cache.tileset(@tileset_name)
      case @style
      when :normal
        @rect.x = @params[0] + @current_pattern * @offset
        @rect.y = @params[1]
        textureset.blt(@x_texture, @y_texture, src, @rect)
      when :auto_VX
        (0...4).each {|i|
          @rect.y = @params[i] >> 2 << 4
          @rect.x = (@params[i] - (@params[i] >> 2 << 2) << 4) +
          @current_pattern * @offset
          textureset.blt(@x_texture + ((i & 1) << 4),
          @y_texture + ((i & 2) << 3), src, @rect)
        }
      when :auto_XP
        (0...4).each {|i|
          @rect.y = @params[i] / 6 << 4
          @rect.x = (@params[i] - (@params[i] / 6 * 6) << 4) +
          @current_pattern * @offset
          textureset.blt(@x_texture + ((i & 1) << 4),
          @y_texture + ((i & 2) << 3), src, @rect)
        }
      end
    end
  end
end

#==============================================================================
# ** DataManager [R13]
#==============================================================================
module DataManager
  #--------------------------------------------------------------------------
  # * Aliased methods (F12 compatibility)
  #--------------------------------------------------------------------------
  class << self
    unless @already_aliased_mgc_lm
      alias save_game_without_rescue_mgc_lm save_game_without_rescue
      @already_aliased_mgc_lm = true
    end
  end
  #--------------------------------------------------------------------------
  # * Execute Save (No Exception Processing)
  #--------------------------------------------------------------------------
  def self.save_game_without_rescue(index)
    textureset = $game_map.lm_map.textureset
    rc = save_game_without_rescue_mgc_lm(index)
    $game_map.lm_map.textureset = textureset
    return rc
  end
end

#==============================================================================
# ** Game_Map
#==============================================================================
class Game_Map
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :start_lm, :end_lm
  #--------------------------------------------------------------------------
  # * Aliased methods
  #--------------------------------------------------------------------------
  unless @already_aliased_mgc_lm
    alias setup_mgc_lm setup
    alias refresh_mgc_lm refresh
    alias check_passage_mgc_lm check_passage
    @already_aliased_mgc_lm = true
  end
  #--------------------------------------------------------------------------
  # * [EXISTING] Setup
  # param map_id : integer (identifiant des données de la carte à charger)
  #--------------------------------------------------------------------------
  def setup(map_id)
    @map_id = map_id
    @map = load_data(sprintf("Data/Map%03d.rvdata2", @map_id))
    if is_layy_meta?
      load_lm_map
      self.start_lm = true
    else
      self.end_lm = true
    end
    setup_mgc_lm(map_id)
  end
  #--------------------------------------------------------------------------
  # * [EXISTING] Refresh
  #--------------------------------------------------------------------------
  def refresh
    refresh_mgc_lm
    if is_layy_meta?
      unless @lm_map.textureset # [R13]
        load_lm_map
      end
      self.start_lm = true
    end
  end
  #--------------------------------------------------------------------------
  # * [NEW] Vérifie s'il s'agit d'une carte isométrique
  # return boolean
  #--------------------------------------------------------------------------
  def is_layy_meta?
    return @map.note[/\[layy_meta:\w+\]/]
  end
  #--------------------------------------------------------------------------
  # * [NEW] Charge la carte isométrique associée
  #--------------------------------------------------------------------------
  def load_lm_map
    @map.note[/\[layy_meta:(\w+)\]/]
    # [R10]
    File.open('Data_LM/' + $1 + '.layymeta', "rb") {|file|
      map_data = Marshal.load(file)
      @lm_map = Layy_Meta::Map.new(map_data.width, map_data.height,
      map_data.map_name, map_data.tileset_name, map_data.data,
      map_data.textureset_data_tilesets, map_data.textureset_data) # [R8]
    }
  end
  #--------------------------------------------------------------------------
  # * [NEW] Accesseur de la carte isométrique
  # return Layy_Meta::Map
  #--------------------------------------------------------------------------
  def lm_map
    return @lm_map
  end
  #--------------------------------------------------------------------------
  # * [NEW] Retourne un tile isométrique aux coordonnées données
  # param x : integer ([0, width[)
  # param y : integer ([0, height[)
  # return Layy_Meta::Tile (nouvelle instance)
  #--------------------------------------------------------------------------
  def tile(x, y)
    return @lm_map.get_tile(x.to_i, y.to_i)
  end
  #--------------------------------------------------------------------------
  # * [NEW] Retourne l'altitude aux coordonnées données
  # param x : integer ([0, width[)
  # param y : integer ([0, height[)
  # return integer (altitude en pixels)
  #--------------------------------------------------------------------------
  def get_altitude(x, y, d = nil)
    # [R2]
    data = @lm_map.get_data(x.round, y.round)
    if data[14] > 0 # slope
      if d
        slope_value = d >> 1
        if data[14] == slope_value # slope base
          return data[0]
        elsif data[14] == 5 - slope_value # slope max height
          return data[0] + data[15]
        else # slope side
          return data[0] + (data[15] >> 1)
        end
      else
        return data[0] + (data[15] >> 1)
      end
    else
      return data[0]
    end
  end
  #--------------------------------------------------------------------------
  # * [NEW] [R2] Retourne l'altitude aux coordonnées données
  # (pour gérer les pentes) 
  # param x : float ([0, width[)
  # param y : float ([0, height[)
  # return integer (altitude en pixels)
  #--------------------------------------------------------------------------
  def get_altitude_px(x, y)
    data = @lm_map.get_data(x.round, y.round)
    slope_value = data[14]
    if slope_value > 0 # slope
      case slope_value
      when 1
        tile_dist = y + 0.5 - y.round
      when 2
        tile_dist = x.round + 0.5 - x
      when 3
        tile_dist = x + 0.5 - x.round
      when 4
        tile_dist = y.round + 0.5 - y
      end
      return data[0] + (tile_dist * data[15]).to_i
    else
      return data[0]
    end
  end
  #--------------------------------------------------------------------------
  # * [EXISTING] Check Passage
  #     bit:  Inhibit passage check bit
  #--------------------------------------------------------------------------
  def check_passage(x, y, bit)
    unless Layy_Meta.active
      check_passage_mgc_lm(x, y, bit)
    else
      all_tiles(x, y).each do |tile_id|
        flag = tileset.flags[tile_id]
        next if flag & 0x10 != 0            # [☆]: No effect on passage
        next if flag & bit == 0             # [○] : Passable
        return false if flag & bit == bit   # [×] : Impassable
      end
      return true
    end
  end
end

#==============================================================================
# ** Spriteset_Map
#==============================================================================
class Spriteset_Map
  #--------------------------------------------------------------------------
  # * Aliased methods
  #--------------------------------------------------------------------------
  unless @already_aliased_mgc_lm
    alias dispose_tilemap_mgc_lm dispose_tilemap
    alias update_mgc_lm update
    alias update_characters_mgc_lm update_characters
    @already_aliased_mgc_lm = true
  end
  #--------------------------------------------------------------------------
  # * [NEW] Lance le rendu isométrique
  #--------------------------------------------------------------------------
  def start_lm
    unless Layy_Meta.visible
      Layy_Meta.show_lm(@viewport1)
    end
    @tilemap.visible = false
  end
  #--------------------------------------------------------------------------
  # * [NEW] Met fin au rendu isométrique
  #--------------------------------------------------------------------------
  def end_lm
    Layy_Meta.dispose # [R12]
    @tilemap.visible = true
  end
  #--------------------------------------------------------------------------
  # * [EXISTING] Free
  #--------------------------------------------------------------------------
  def dispose_tilemap
    dispose_tilemap_mgc_lm
    Layy_Meta.dispose # [R12]
  end
  #--------------------------------------------------------------------------
  # * [EXISTING] Update
  #--------------------------------------------------------------------------
  def update
    if $game_map.start_lm
      start_lm
      $game_map.start_lm = false
    elsif $game_map.end_lm
      end_lm
      $game_map.end_lm = false
    end
    update_mgc_lm
    Layy_Meta.update
  end
  #--------------------------------------------------------------------------
  # * [EXISTING] Update Character Sprite
  #--------------------------------------------------------------------------
  def update_characters
    update_characters_mgc_lm
    if Layy_Meta.active
      need_refresh = false
      visible_sprites = []
      @character_sprites.each {|sprite|
        unless sprite.character.character_name == '' &&
          sprite.character.tile_id == 0 || !sprite.visible # [R9] [D522]
          if sprite.lm_need_refresh
            need_refresh = true
            sprite.lm_need_refresh = false
          end
          if sprite.lm_visible
            sprite.visible = false
            visible_sprites << sprite.get_lm_data
          end
        end
      }
      if need_refresh
        visible_sprites.sort! {|a, b|
          a[2] - b[2] == 0 ? a[0] - b[0] : b[2] - a[2]
        }
        Layy_Meta.set_characters(visible_sprites)
      end
    end
  end
end

#==============================================================================
# ** Sprite_Character
#==============================================================================
class Sprite_Character < Sprite_Base
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :lm_visible, :lm_y_base, :lm_need_refresh
  #--------------------------------------------------------------------------
  # * Aliased methods
  #--------------------------------------------------------------------------
  unless @already_aliased_mgc_lm
    alias initialize_mgc_lm_aprite_character initialize
    alias dispose_mgc_lm_aprite_character dispose
    alias update_position_mgc_lm_aprite_character update_position
    alias set_tile_bitmap_mgc_lm_aprite_character set_tile_bitmap
    alias set_character_bitmap_mgc_lm_aprite_character set_character_bitmap
    alias update_src_rect_mgc_lm_aprite_character update_src_rect
    @already_aliased_mgc_lm = true
  end
  #--------------------------------------------------------------------------
  # * [EXISTING] Object Initialization
  # param viewport : Viewport
  # param character : Game_Character
  #--------------------------------------------------------------------------
  def initialize(viewport, character = nil)
    @lm_data = [0, 0, 0, 32, 32, 0]
    initialize_mgc_lm_aprite_character(viewport, character)
  end
  #--------------------------------------------------------------------------
  # * [EXISTING] Free
  #--------------------------------------------------------------------------
  def dispose
    end_lm
    dispose_mgc_lm_aprite_character
  end
  #--------------------------------------------------------------------------
  # * [NEW] Free Layy Meta data
  #--------------------------------------------------------------------------
  def end_lm
    if @lm_bitmap then @lm_bitmap.dispose end
  end
  #--------------------------------------------------------------------------
  # * [EXISTING] Update Position
  #--------------------------------------------------------------------------
  def update_position
    if Layy_Meta.active
      old_x = x
      old_y = y
      update_lm
      self.z = @character.screen_z
      move_animation(x - old_x, y - old_y)
    else
      update_position_mgc_lm_aprite_character
    end
  end
  #--------------------------------------------------------------------------
  # * [EXISTING] Set Tile Bitmap
  #--------------------------------------------------------------------------
  def set_tile_bitmap
    set_tile_bitmap_mgc_lm_aprite_character
    @cw = 32 # [R9] [D522]
    @ch = 32 # [R9] [D522]
    @lm_data[3] = 32
    @lm_data[4] = 32
    end_lm
    @lm_bitmap = Bitmap.new(32, 32)
    @lm_data[5] = @lm_bitmap
    self.lm_need_refresh = true
  end
  #--------------------------------------------------------------------------
  # * [EXISTING] Set Character Bitmap
  #--------------------------------------------------------------------------
  def set_character_bitmap
    set_character_bitmap_mgc_lm_aprite_character
    @lm_data[3] = @cw
    @lm_data[4] = @ch
    end_lm
    @lm_bitmap = Bitmap.new(@cw, @ch)
    @lm_data[5] = @lm_bitmap
    self.lm_need_refresh = true
  end
  #--------------------------------------------------------------------------
  # * [EXISTING] Update Transfer Origin Rectangle
  #--------------------------------------------------------------------------
  def update_src_rect
    if Layy_Meta.active
      sx_old = src_rect.x
      sy_old = src_rect.y
      if @tile_id == 0
        index = character.character_index
        pattern = character.pattern < 3 ? character.pattern : 1
        sx = (index % 4 * 3 + pattern) * @cw
        unless character.direction_fix
          current_direction = character.direction - 2 >> 1
          directions_list = [0, 1, 3, 2]
          current_direction = directions_list[(directions_list.index(
          current_direction) + ((Layy_Meta.map_rotation_angle + 45) % 360) /
          90) % 4]
          sy = current_direction * @ch
        else
          sy = (character.direction - 2 >> 1) * @ch
        end
        sy += (index >> 2 << 2) * @ch
        self.src_rect.set(sx, sy, @cw, @ch)
      end
      if src_rect.x != sx_old || src_rect.y != sy_old || lm_need_refresh
        @lm_bitmap.clear
        @lm_bitmap.blt(0, 0, bitmap, src_rect) 
        self.lm_need_refresh = true
      end
    else
      update_src_rect_mgc_lm_aprite_character
    end
  end
  #--------------------------------------------------------------------------
  # * [NEW] Mise à jour de la position dans le référentiel isométrique
  #--------------------------------------------------------------------------
  def update_lm
    x_old = x
    y_old = y
    lm_y_h0 = character.lm_y_h0 - (Layy_Meta.offset_y >> 3) + Layy_Meta.offset_h
    lm_y = character.lm_y - (Layy_Meta.offset_y >> 3) + Layy_Meta.offset_h
    lm_x = character.lm_x - (Layy_Meta.offset_x >> 3)
    self.lm_y_base = [lm_y_h0 + 256, 0].max
    self.y = lm_y
    self.x = lm_x
    x_lm = x - (@lm_data[3] >> 1)
    if x + (@cw >> 1) < 0 || x - (@cw >> 1) >= Graphics.width ||
      y < 0 || y - @ch >= Graphics.height
    then
      self.lm_visible = false
    else
      self.lm_visible = true
    end
    self.lm_need_refresh = lm_need_refresh || x != x_old || y != y_old
  end
  #--------------------------------------------------------------------------
  # * [NEW] Retourne les données du sprite pour le rendu isométrique
  # return Array[6]
  #         - x : integer
  #         - y : integer
  #         - y en projection sur le plan à l'altitude 0 : integer (positif)
  #         - width : integer (positif)
  #         - height : integer (positif)
  #         - bitmap : Bitmap
  #--------------------------------------------------------------------------
  def get_lm_data
    @lm_data[0] = x - (@lm_data[3] >> 1)
    unless Layy_Meta.zoom == 1.0 # [R5]
      @lm_data[0] += (@lm_data[3] * (1.0 - Layy_Meta.zoom)).to_i >> 1
    end
    if Layy_Meta::LM_OFFSET_SPRITES.has_key?(character.character_name)
      offset_y = Layy_Meta::LM_OFFSET_SPRITES[character.character_name]
    else
      offset_y = 0
    end
    @lm_data[1] = y + offset_y
    @lm_data[2] = lm_y_base + [offset_y, 0].max
    return @lm_data
  end
end

#==============================================================================
# ** Game_CharacterBase
#==============================================================================
class Game_CharacterBase
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :lm_altitude, :lm_walkable_height, :lm_jumpable_height,
  :lm_max_fall_height
  attr_reader :lm_x, :lm_y, :lm_y_h0
  #--------------------------------------------------------------------------
  # * Aliased methods
  #--------------------------------------------------------------------------
  unless @already_aliased_mgc_lm
    alias init_public_members_mgc_lm init_public_members
    alias moving_mgc_lm? moving?
    alias passable_mgc_lm? passable?
    alias screen_y_mgc_lm screen_y
    alias update_mgc_lm update
    alias jump_height_mgc_lm jump_height
    alias move_straight_mgc_lm move_straight
    alias moveto_mgc_lm moveto
    @already_aliased_mgc_lm = true
  end
  #--------------------------------------------------------------------------
  # * [EXISTING] Initialize Public Member Variables
  #--------------------------------------------------------------------------
  def init_public_members
    init_public_members_mgc_lm
    self.lm_altitude = 0
    self.lm_walkable_height = Layy_Meta::LM_DEFAULT_WALKABLE_HEIGHT
    self.lm_jumpable_height = Layy_Meta::LM_DEFAULT_JUMPABLE_HEIGHT
    self.lm_max_fall_height = Layy_Meta::LM_DEFAULT_MAX_FALL_HEIGHT
    @lm_x = 0
    @lm_y = 0
    @lm_y_h0 = 0
  end
  #--------------------------------------------------------------------------
  # * [EXISTING] Determine if Moving
  #--------------------------------------------------------------------------
  def moving?
    unless Layy_Meta.active
      return moving_mgc_lm?
    else
      return moving_mgc_lm? || @lm_falling
    end
  end
  #--------------------------------------------------------------------------
  # * [EXISTING] Determine if Passable
  #     d : Direction (2,4,6,8)
  #--------------------------------------------------------------------------
  def passable?(x, y, d)
    unless Layy_Meta.active
      return passable_mgc_lm?(x, y, d)
    else
      x2 = $game_map.round_x_with_direction(x, d)
      y2 = $game_map.round_y_with_direction(y, d)
      return false unless $game_map.valid?(x2, y2)
      return true if @through || debug_through?
      return false unless map_passable?(x, y, d)
      return false unless map_passable?(x2, y2, reverse_dir(d))
      return false if collide_with_characters?(x2, y2)
      lm_altitude_start = $game_map.get_altitude(x, y, 10 - d) # [R2]
      lm_altitude_end = $game_map.get_altitude(x2, y2, d) # [R2]
      return false if lm_altitude_end - lm_altitude_start > lm_walkable_height
      return false if lm_altitude_start - lm_altitude_end > lm_max_fall_height
      return true
    end
  end
  #--------------------------------------------------------------------------
  # * [NEW] Determine if Passable for jump
  #     d : Direction (2,4,6,8)
  #--------------------------------------------------------------------------
  def jumpable?(x, y, d)
    if Layy_Meta.active
      x2 = $game_map.round_x_with_direction(x, d)
      y2 = $game_map.round_y_with_direction(y, d)
      return false unless $game_map.valid?(x2, y2)
      return true if @through || debug_through?
      return false unless map_passable?(x, y, d)
      return false unless map_passable?(x2, y2, reverse_dir(d))
      return false if collide_with_characters?(x2, y2)
      lm_altitude_start = $game_map.get_altitude(x, y, 10 - d) # [R2]
      lm_altitude_end = $game_map.get_altitude(x2, y2, d) # [R2]
      return false if lm_altitude_end - lm_altitude_start > lm_jumpable_height
      return false if lm_altitude_start - lm_altitude_end > lm_max_fall_height
      return true
    end
  end
  #--------------------------------------------------------------------------
  # * [EXISTING] Get Screen Y-Coordinates
  #--------------------------------------------------------------------------
  def screen_y
    unless Layy_Meta.active
      return screen_y_mgc_lm
    else
      return $game_map.adjust_y(@real_y) * 32 + 32 - shift_y
    end
  end
  #--------------------------------------------------------------------------
  # * [EXISTING] Frame Update
  #--------------------------------------------------------------------------
  def update
    unless Layy_Meta.active
      update_mgc_lm
    else
      update_lm_altitude
      if self == Layy_Meta.focused_character && moving?
        Layy_Meta.force_translation
      end
      update_mgc_lm
      update_lm_position
    end
  end
  #--------------------------------------------------------------------------
  # * [EXISTING] Calculate Jump Height
  #--------------------------------------------------------------------------
  def jump_height
    unless Layy_Meta.active
      return jump_height_mgc_lm
    else
      unless @lm_altitude_end
        @lm_altitude_end = 0
      end
      if @lm_altitude_end >= @lm_altitude_start
        if @jump_count > @jump_peak
          return @lm_altitude_start +
          @jump_count * (@jump_peak - (@jump_count >> 1)) * (@jump_peak *
          @jump_peak + (@lm_altitude_end - @lm_altitude_start << 1)) /
          (@jump_peak * @jump_peak)
        else
          return @lm_altitude_end + @jump_count * (@jump_peak -
          (@jump_count >> 1))
        end
      else
        return @lm_altitude_start + @jump_count * (@jump_peak -
        (@jump_count >> 1))
      end
    end
  end
  #--------------------------------------------------------------------------
  # * [NEW] Mise à jour de l'altitude
  # [revision 1 - mod]
  #--------------------------------------------------------------------------
  def update_lm_altitude
    if jumping?
      self.lm_altitude = jump_height
    else
      @lm_altitude_target = $game_map.get_altitude_px(real_x, real_y) # [R2]
      if lm_altitude > @lm_altitude_target
        unless @lm_falling
          @lm_falling = true
          @lm_altitude_init = lm_altitude
          @lm_fall_duration = 0
        end
        @lm_fall_duration += 1
        self.lm_altitude = [@lm_altitude_init -
        @lm_fall_duration * @lm_fall_duration, @lm_altitude_target].max
      else
        self.lm_altitude = @lm_altitude_target
        @lm_falling = false
        @in_jump = false
      end
    end
  end
  #--------------------------------------------------------------------------
  # * [EXISTING] Move Straight
  #     d:        Direction (2,4,6,8)
  #     turn_ok : Allows change of direction on the spot
  #--------------------------------------------------------------------------
  def move_straight(d, turn_ok = true)
    if Layy_Meta.active
      @move_succeed = passable?(@x, @y, d)
      unless @move_succeed
        @move_succeed = jumpable?(@x, @y, d)
        if @move_succeed
          set_direction(d)
          jump($game_map.round_x_with_direction(@x, d) - x,
          $game_map.round_y_with_direction(@y, d) - y)
          increase_steps
          return
        end
      end
    end
    move_straight_mgc_lm(d, turn_ok)
  end
  #--------------------------------------------------------------------------
  # * [NEW] Mise à jour de la position dans le référentiel isométrique
  # [revision 1 - mod]
  #--------------------------------------------------------------------------
  def update_lm_position
    ox = Graphics.width >> 1
    oy = Graphics.height >> 1
    x_screen = (real_x * 32).to_i + 16 - (Layy_Meta.display_x >> 3)
    y_screen = (real_y * 32).to_i + 16 - (Layy_Meta.display_y >> 3)
    y_lm = ((oy << 10) + ((y_screen - oy) * Layy_Meta.cos_angle +
    (x_screen - ox) * Layy_Meta.sin_angle) / 6 >> 10)
    x_lm = ((ox << 10) + ((x_screen - ox) * Layy_Meta.cos_angle -
    (y_screen - oy) * Layy_Meta.sin_angle) / 3 >> 10)
    unless Layy_Meta.zoom == 1.0 # [R5]
      x_lm = ox + ((x_lm - ox) * Layy_Meta.zoom).to_i
      y_lm = oy + ((y_lm - oy) * Layy_Meta.zoom).to_i
    end
    @lm_y_h0 = y_lm
    if Layy_Meta.zoom == 1.0 # [R5]
      @lm_y = y_lm - lm_altitude
    else
      @lm_y = y_lm - (lm_altitude * Layy_Meta.zoom).to_i
    end
    @lm_x = x_lm
    if self == Layy_Meta.focused_character && 
      (Layy_Meta.translation? || Layy_Meta.zooming?) # [R5]
    then
      x_lm = lm_x - (Layy_Meta.offset_x >> 3)
      if (x_lm - ox).abs > 1
        Layy_Meta.offset_x += x_lm - ox << 3
      end
      y_lm = lm_y_h0 - (Layy_Meta.offset_y >> 3)
      if (y_lm - oy).abs > 1
        Layy_Meta.offset_y += y_lm - oy << 3
      end
      if @in_jump && !Layy_Meta::LM_CAMERA_FOLLOW_JUMP
        lm_h = [@lm_altitude_end, lm_altitude].min # [R5]
        Layy_Meta.offset_h = (lm_h * Layy_Meta.zoom).to_i
      else
        Layy_Meta.offset_h = (lm_altitude * Layy_Meta.zoom).to_i # [R5]
      end
    end
  end
  #--------------------------------------------------------------------------
  # * [NEW] Mise à jour pendant la rotation/translation
  #--------------------------------------------------------------------------
  def update_for_lm_transition
    update
  end
  #--------------------------------------------------------------------------
  # * [EXISTING] Move to Designated Position
  #--------------------------------------------------------------------------
  def moveto(x, y)
    moveto_mgc_lm(x, y)
    if $game_map.is_layy_meta?
      unless Layy_Meta.map == $game_map.lm_map
        Layy_Meta.initialize_map
      end
      self.lm_altitude = $game_map.get_altitude(real_x, real_y)
      if self == Layy_Meta.focused_character
        Layy_Meta.force_translation
      end
      update_lm_position
    end
  end
end

#==============================================================================
# ** Game_Character
#==============================================================================
class Game_Character < Game_CharacterBase
  #--------------------------------------------------------------------------
  # * Aliased methods
  #--------------------------------------------------------------------------
  unless @already_aliased_mgc_lm
    alias jump_mgc_lm jump
    @already_aliased_mgc_lm = true
  end
  #--------------------------------------------------------------------------
  # * [EXISTING] Jump
  #     x_plus : x-coordinate plus value
  #     y_plus : y-coordinate plus value
  # [revision 1 - mod]
  #--------------------------------------------------------------------------
  def jump(x_plus, y_plus)
    if Layy_Meta.active
      return unless $game_map.valid?(x + x_plus, y + y_plus)
      @lm_altitude_start = $game_map.get_altitude(x, y)
      @in_jump = true
    end
    jump_mgc_lm(x_plus, y_plus)
    if Layy_Meta.active
      @lm_altitude_end = $game_map.get_altitude(x, y)
    end
  end
end

#==============================================================================
# ** Game_Player
#==============================================================================
class Game_Player < Game_Character
  #--------------------------------------------------------------------------
  # * Aliased methods
  #--------------------------------------------------------------------------
  unless @already_aliased_mgc_lm
    alias update_scroll_mgc_lm update_scroll
    alias move_straight_mgc_lm_game_player move_straight
    @already_aliased_mgc_lm = true
  end
  #--------------------------------------------------------------------------
  # * [EXISTING] Scroll Processing
  #--------------------------------------------------------------------------
  def update_scroll(last_real_x, last_real_y)
    unless Layy_Meta.active
      update_scroll_mgc_lm(last_real_x, last_real_y)
    end
  end
  #--------------------------------------------------------------------------
  # * [NEW] Mise à jour pendant la rotation/translation
  #--------------------------------------------------------------------------
  def update_for_lm_transition
    super
    @followers.update
  end
  #--------------------------------------------------------------------------
  # * [EXISTING] Move Straight
  # [revision 1 - mod]
  #--------------------------------------------------------------------------
  def move_straight(d, turn_ok = true)
    unless Layy_Meta.active
      move_straight_mgc_lm_game_player(d, turn_ok)
    else
      @followers.add_move(d) if passable?(@x, @y, d) || jumpable?(@x, @y, d)
      super(d, turn_ok)
    end
  end
  #--------------------------------------------------------------------------
  # * [NEW] Associe le personnage qui suit
  # [revision 1 - new]
  #--------------------------------------------------------------------------
  def following_character=(following_character)
    @following_character = following_character
  end
end

#==============================================================================
# ** Game_Follower
#==============================================================================
class Game_Follower < Game_Character
  #--------------------------------------------------------------------------
  # * Aliased methods
  # [revision 1 - new]
  #--------------------------------------------------------------------------
  unless @already_aliased_mgc_lm_follower
    alias initialize_mgc_lm_follower initialize
    alias update_mgc_lm_follower update
    @already_aliased_mgc_lm_follower = true
  end
  #--------------------------------------------------------------------------
  # * [NEW] Object Initialization
  # [revision 1 - new]
  #--------------------------------------------------------------------------
  def initialize(member_index, preceding_character)
    initialize_mgc_lm_follower(member_index, preceding_character)
    @moves = []
    preceding_character.following_character = self
  end
  #--------------------------------------------------------------------------
  # * [NEW] Associe le personnage qui suit
  # [revision 1 - new]
  #--------------------------------------------------------------------------
  def following_character=(following_character)
    @following_character = following_character
  end
  #--------------------------------------------------------------------------
  # * [EXISTING] Move Straight
  #--------------------------------------------------------------------------
  def move_straight(d, turn_ok = true)
    unless Layy_Meta.active
      super(d, turn_ok)
    else
      # will jump if possible
      @through = false
      super(d, turn_ok)
      @through = true
      unless moving?
        super(d, turn_ok)
      end
    end
  end
  #--------------------------------------------------------------------------
  # * [NEW] Ajoute un mouvement à effectuer
  # [revision 1 - new]
  #--------------------------------------------------------------------------
  def add_move(d)
    @moves << d
  end
  #--------------------------------------------------------------------------
  # * [NEW] Vide la pile de mouvements à effectuer
  # [revision 1 - new]
  #--------------------------------------------------------------------------
  def clear_moves
    @moves.clear
  end
  #--------------------------------------------------------------------------
  # * [EXISTING] Frame Update
  # [revision 1 - new]
  #--------------------------------------------------------------------------
  def update
    update_mgc_lm_follower
    if Layy_Meta.active && @moves.size > 0
      execute_next_move
    end
  end
  #--------------------------------------------------------------------------
  # * [NEW] Continue les déplacements prévus
  # [revision 1 - new]
  #--------------------------------------------------------------------------
  def execute_next_move
    unless moving?
      dir = @moves[0]
      new_x = $game_map.round_x_with_direction(x, dir)
      new_y = $game_map.round_y_with_direction(y, dir)
      unless new_x == @preceding_character.x && new_y == @preceding_character.y
        move_straight(dir)
        if moving?
          @moves.shift
          if @following_character
            @following_character.add_move(dir)
          end
        end
      end
    end
  end
end

#==============================================================================
# ** Game_Followers
#==============================================================================
class Game_Followers
  #--------------------------------------------------------------------------
  # * Aliased methods
  # [revision 1 - new]
  #--------------------------------------------------------------------------
  unless @already_aliased_mgc_lm
    alias synchronize_mgc_lm synchronize
    alias gather_mgc_lm gather
    @already_aliased_mgc_lm = true
  end
  #--------------------------------------------------------------------------
  # * [NEW] Ajoute un mouvement à effectuer
  # [revision 1 - new]
  #--------------------------------------------------------------------------
  def add_move(d)
    @data[0].add_move(d)
  end
  #--------------------------------------------------------------------------
  # * [EXISTING] Synchronize
  # [revision 1 - new]
  #--------------------------------------------------------------------------
  def synchronize(x, y, d)
    synchronize_mgc_lm(x, y, d)
    each do |follower|
      follower.clear_moves
    end
  end
  #--------------------------------------------------------------------------
  # * [EXISTING] Gather
  # [revision 1 - new]
  #--------------------------------------------------------------------------
  def gather
    gather_mgc_lm
    each do |follower|
      follower.clear_moves
    end
  end
end

#==============================================================================
# ** Scene_Map
#==============================================================================
class Scene_Map < Scene_Base
  #--------------------------------------------------------------------------
  # * Aliased methods
  #--------------------------------------------------------------------------
  unless @already_aliased_mgc_lm
    alias update_transfer_player_mgc_lm update_transfer_player
    alias update_encounter_mgc_lm update_encounter
    alias update_for_fade_mgc_lm update_for_fade
    alias update_call_menu_mgc_lm update_call_menu # [R13]
    @already_aliased_mgc_lm = true
  end
  #--------------------------------------------------------------------------
  # * [NEW] Mise à jour pendant la rotation/translation
  #--------------------------------------------------------------------------
  def update_for_lm_transition
    update_basic
    $game_map.update(false)
    $game_player.update_for_lm_transition
    @spriteset.update
  end
  #--------------------------------------------------------------------------
  # * [EXISTING] Update Frame (for Fade In)
  #--------------------------------------------------------------------------
  def update_for_fade
    if Layy_Meta.active
      $game_player.update_lm_position
      $game_player.followers.each {|follower| follower.update_lm_position}
      if Layy_Meta.offset_x != 0 || Layy_Meta.offset_y != 0
        Layy_Meta.check_translation_end(true)
      end
    end
    update_for_fade_mgc_lm
  end
  #--------------------------------------------------------------------------
  # * [EXISTING] Update Player Transfer
  #--------------------------------------------------------------------------
  def update_transfer_player
    if !Layy_Meta.active
      update_transfer_player_mgc_lm
    elsif $game_player.transfer?
      Layy_Meta.check_translation_end(true)
      $game_player.update_lm_position
      $game_player.followers.each {|follower| follower.update_lm_position}
      update_transfer_player_mgc_lm
    end
  end
  #--------------------------------------------------------------------------
  # * [EXISTING] Update Encounter
  #--------------------------------------------------------------------------
  def update_encounter
    if !Layy_Meta.active
      update_encounter_mgc_lm
    elsif $game_player.encounter
      Layy_Meta.check_translation_end(true)
      $game_player.update_lm_position
      $game_player.followers.each {|follower| follower.update_lm_position}
      SceneManager.call(Scene_Battle)
      update_encounter_mgc_lm
    end
  end
  #--------------------------------------------------------------------------
  # * Determine if Menu is Called due to Cancel Button [R13]
  #--------------------------------------------------------------------------
  def update_call_menu
    unless Layy_Meta.effect?
      update_call_menu_mgc_lm
    end
  end
end

#==============================================================================
# ** Input
#==============================================================================
module Input
  #--------------------------------------------------------------------------
  # * Aliased methods (F12 compatibility)
  #--------------------------------------------------------------------------
  class << self
    unless @already_aliased_mgc_lm
      alias dir4_mgc_lm dir4
      alias dir8_mgc_lm dir8
      @already_aliased_mgc_lm = true
    end
  end
  #--------------------------------------------------------------------------
  # * Dir4
  #--------------------------------------------------------------------------
  Left = [6, 2, 8, 4]
  def self.dir4
    unless Layy_Meta.active
      return dir4_mgc_lm
    end
    input_value = dir4_mgc_lm
    unless input_value == 0
      case Layy_Meta.map_rotation_angle
      when 46...136
        camera_direction = 6
      when 136...226
        camera_direction = 2
      when 226...316
        camera_direction = 4
      else
        camera_direction = 8
      end
      case camera_direction
      when 2
        input_value = 10 - input_value
      when 4
        input_value = 10 - Left[(input_value >> 1) - 1]
      when 6
        input_value = Left[(input_value >> 1) - 1]
      when 8
        input_value = input_value
      end
    end
    return input_value
  end
  #--------------------------------------------------------------------------
  # * Dir8
  #--------------------------------------------------------------------------
  Dir8_Index = [0, 5, 4, 3, 6, 0, 2, 7, 0, 1]
  Dir8_Left = [8, 9, 6, 3, 2, 1, 4, 7]
  def self.dir8
    unless Layy_Meta.active
      return dir8_mgc_lm
    end
    input_value = dir8_mgc_lm
    unless input_value == 0
      offset = ((Layy_Meta.map_rotation_angle + 23) / 45) % 8
      input_value = Dir8_Left[(Dir8_Index[input_value] + offset) % 8]
    end
    return input_value
  end
end