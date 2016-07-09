  #=============================================================#
  #                        AI SETTINGS                          #
  #=============================================================#
module GTBS
  #-------------------------------------------------------------
  # Enemy Think Time 
  #-------------------------------------------------------------
  # This is more of a wait so it looks like the enemy is thinking about who they 
  # are going to attack.  Default is 5
  ENEMY_THINK_TIME = 1
  
  #-------------------------------------------------------------
  # To make it look more like they are considering actions, do you want to display
  # the area that they can attack etc as the action is considered?
  #-------------------------------------------------------------
  Show_En_Think_Areas = false
  
  #-------------------------------------------------------------
  # Hide Enemy Move Ranges
  #-------------------------------------------------------------
  HIDE_EN_MOVE = false
  
  #----------------------------------------------------------------------------
  # DEFAULT_VIEW_RANGE - 16 is default
  #----------------------------------------------------------------------------
  # When AI character is "approaching", "running away" or just moving away from or toward 
  # the enemy targets it checks every target with THIS(RUN_VIEW_RANGE). This allows
  # for a more realistic retreat/approach.  If you dont want to use this option then
  # set the value to 99.  (This would mean unless the distance is greater than 99 they 
  # would be set to approach/escape using the standard method.
  #----------------------------------------------------------------------------
  DEFAULT_VIEW_RANGE = 16
  
  #-------------------------------------------------------------
  # Ignore View Range when Out Numbered
  #-------------------------------------------------------------
  IGNORE_VIEW_OUTNUMBERED = false
  
  #-------------------------------------------------------------
  # Allow AI to wander when there are no visible units
  #-------------------------------------------------------------
  ALLOW_AI_WANDER = true
  
  #-------------------------------------------------------------
  # HEAL THRESH % - Sets percent of health remaining for AI to attempt heal
  #-------------------------------------------------------------
  # Default is 33 which would be %33 of hp, while 50 would be %50 of hp.  Play around
  # with the numbers until you find what you want.  The AI will not attempt to heal
  # any character until this threshhold has been met.
  HEAL_THRESH = 50
end
  
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# GTBS Tactics - Defines how an enemy/neutral AI will react given the params
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
module GTBS_Tactics

  All_AI_Tactics = {}
  class Tactic
    attr_accessor :position, :hp_damage, :hp_heal, :mp_damage, :counter, :state, :death_like, :mp_save,
                  :team, :team_rate, :more_targets,
                  :predictable, :force_approach
    #============================================
    #  Default value used for Default Ai_Tactics
    #============================================
    #  @name = name                #name is used to set monster's ai_level
    #  @position = 100                #is the battler looking for safe position?
    #  @hp_damage = 100         # looking for hp_damage
    #  @hp_heal = 100                 # looking for hp_damage
    #  @mp_damage = 0             # looking for mp damage
    #  @counter = 0                  # take care of target's counter, 0-100(0 is ignore, 100 is run if you cannot kill)
    #  @state = 20                         # adding/removing state value
    #  @mp_save = 50              # easily use mp?
    #  @death_like = 1.0             # is the the battler looking for death count
    #  @team = false                   # is the unit looking for team mate
    #  @team_rate = 0.0             #amplify damage/heal rate on allies
    #  @predictable = 9              #more the value is, more the choice will be determinist. (against random choice)
    #============================================
    
    #Initialize a tactic with the parameters of the default tactic (Agressive)
    def initialize(name = 'default')   #name is used to set monster's ai_level
      @position = 50             #is the battler looking for safe position?
      @hp_damage = 100            # looking for hp_damage
      @hp_heal = 100              # looking for healing opportunites
      @mp_damage = 0              # looking for mp damage
      @counter = 100              # consider target's counter
      @state = 20                 # adding/removing state value
      @mp_save = 50               # economic mp usage 
      @death_like = 1.0           # is the the battler looking for death count
      @team = false               # is the unit looking for team mate
      @team_rate =1.0             # amplify damage/heal rate on allies
      @predictable = 5            # more the value is, more the choice will be determinist. (against random choice)
      @force_approach = true      # This should cause enemies to never retreat when they
                                  # can deliver a hit be it a guaranteed miss or not.
      @name = name
      
      All_AI_Tactics[name] = self
    end
    def show_test
      p *[ "AI_Tactic = #{@name}",
           "position = #{@position} %",
           "hp_damage = #{@hp_damage} %",
           "hp_heal = #{@hp_heal} %",
           "mp_damage = #{@mp_damage} %",
           "counter = #{@counter} %",
           "state = x#{@state}",
           "mp_save = #{@mp_save} %",
           "death_like = x#{@death_like}",
           "team = #{@team}",
           "predictable = #{@predictable} / 10"
           
           ]
    end
  end
  Default = Tactic.new
  
  #===================================================================================
  #* Configuration des tactiques personnalisées
  #===================================================================================
  
  #Agressive tactic
  Attack = Tactic.new('attack')
    Attack.hp_damage = 300
    
    #Attack.show_test
    
  #Defensive tactic
  Defend = Tactic.new('defend')
    Defend.position = 200
    Defend.hp_damage = 75
    Defend.mp_damage = 75
    Defend.counter = 250
    
    #Defend.show_test
    
  #Assassin wants to kill
  Assassin = Tactic.new('assassin')
    Assassin.position = 0
    Assassin.hp_damage = 150
    Assassin.counter = 50
    Assassin.death_like = 5.0  #Assassin wants to kill people
    
  #Healer
  Healer = Tactic.new('healer')
    Healer.hp_heal = 200    #like to heal allies
    Healer.state = 50            #like to buff/debuff
    Healer.position = 150    #looking for a safe position, he's not a warrior
    Healer.team = true
    
  #berseker
  Berseker = Tactic.new('berseker')
    Berseker.counter = 0                 #don't care of counter
    Berseker.position = 0                #or dangerous position
    Berseker.hp_damage = 350    #berseker wants to make damage
    Berseker.death_like = 2.5         # and kill enemies
    
  #Team
  Team = Tactic.new('team')
    Team.hp_heal = 150
    Team.state = 30
    Team.position = 60
    Team.team = true
    Team.team_rate = 3.0
    
  Poisener = Tactic.new('poisener') #reduce HP dmg like and raise state apply
    Poisener.state = 200
    Poisener.hp_damage = 20 
    Poisener.predictable = 10
    Poisener.counter = 10
    
  # Warrior
  Warrior = Tactic.new('warrior')
    Warrior.position = 50
    Warrior.hp_damage = 130
    Warrior.hp_heal = 70
    Warrior.mp_damage = 0
    Warrior.counter = 70
    Warrior.state = 20
    Warrior.mp_save = 20
    Warrior.death_like = 2.0
    Warrior.team = false
    Warrior.team_rate =1.0
    Warrior.predictable = 5
    
  # Concerned
  Concerned = Tactic.new('concerned')
    Concerned.position = 60
    Concerned.hp_damage = 100
    Concerned.hp_heal = 100
    Concerned.mp_damage = 0
    Concerned.counter = 100
    Concerned.state = 20
    Concerned.mp_save = 50
    Concerned.death_like = 1.0
    Concerned.team = false
    Concerned.team_rate =1.0
    Concerned.predictable = 5
 
  # Enthusiastic - Wants to get out and kill some enemies
  Enthusiastic = Tactic.new('enthusiastic')
    Enthusiastic.position = 50
    Enthusiastic.hp_damage = 140
    Enthusiastic.hp_heal = 70
    Enthusiastic.mp_damage = 0
    Enthusiastic.counter = 60
    Enthusiastic.state = 20
    Enthusiastic.mp_save = 10
    Enthusiastic.death_like = 2.2
    Enthusiastic.team = false
    Enthusiastic.team_rate =1.0
    Enthusiastic.predictable = 4
 
  # Aisley - Selfless (high desire to heal party, less to heal self)
  Selfless = Tactic.new('selfless')
    Selfless.position = 50
    Selfless.hp_damage = 130
    Selfless.hp_heal = 90
    Selfless.mp_damage = 0
    Selfless.counter = 70
    Selfless.state = 20
    Selfless.mp_save = 20
    Selfless.death_like = 2.0
    Selfless.team = false
    Selfless.team_rate = 3.0
    Selfless.predictable = 6
 
  # Kurt - Careful
  Careful = Tactic.new('careful')
    Careful.position = 50
    Careful.hp_damage = 130
    Careful.hp_heal = 70
    Careful.mp_damage = 0
    Careful.counter = 120
    Careful.state = 40
    Careful.mp_save = 20
    Careful.death_like = 2.0
    Careful.team = true
    Careful.team_rate =1.0
    Careful.predictable = 5
end
