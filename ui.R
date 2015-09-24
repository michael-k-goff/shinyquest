library("shiny")

shinyUI(
  pageWithSidebar(
    headerPanel("Shiny Quest")
    ,
    sidebarPanel(
      tags$head(
        tags$style(type='text/css'
                   # sidebarPanel appearance
                   , ".row-fluid .span4 {width: 0px; height: 0px;}"
                   , ".row-fluid .well {padding: 0px; border: 0px;}"
                   , ".row-fluid .span4 {background-color: rgb(0, 0, 0);}"
                   # button appearance
                   , ".btn {padding: 15px; font-size: 120%;}"
        )
      ),
      conditionalPanel( # Storing game variables as hidden inputs
        condition = "false",
        numericInput("Exp","VAR",value=0),
        numericInput("HP","VAR",value=10),
        numericInput("MaxHP","VAR",value=10),
        numericInput("WorldNum","VAR",value=1),
        numericInput("MaxWorld","VAR",value=1),
        numericInput("NumExplore","VAR",value=0),
        numericInput("Level","VAR",value=1),
        numericInput("Gold","VAR",value=0),
        numericInput("Stamina","VAR",value=3),
        numericInput("Defense","VAR",value=3),
        numericInput("Agility","VAR",value=3),
        numericInput("Strength","VAR",value=3),
        numericInput("Attack","VAR",value=3),
        numericInput("Weapon","VAR",value=0),
        numericInput("Armor","VAR",value=0),
        numericInput("EnemyHP","VAR",value=0) # If <= 0, not in battle
      ),
      textOutput("level"),
      textOutput("hp"),
      br(),
      textOutput("str"),
      textOutput("def"),
      br(),
      textOutput("gold"),
      textOutput("exp"),
      br(),
      sliderInput('difficulty', 'Difficulty',value = 5, min = 0, max = 10, step = 1,),
      h3("Instructions"),
      "Weclome to Shiny Quest, an epic adventure to ... waste some time.",
      br(),br(),
      "Your goal: to explore the many game worlds.",
      br(),br(),
      "To advance to the next world, you must fight 10 consecutive battles (done by clicking 'Explore') without dying, which happens when you run out of hit points (HP).",
      br(),br(),
      "When in battle, simply click Fight until you win. If things get dicey, run away.",
      br(),br(),
      "If you are low on HP, rest to fully restore them. Keep in mind that resting resets your exploration progress.",
      br(),br(),
      "Boost your stats to improve your fighting. A higher Attack means you do more damage. A higher Defense means you take less damage.",
      br(),br(),
      "When you win fights, you earn Gold. Use them to upgrade your weapon and armor to improve stats. If you lose a fight, you lose all your Gold, so be careful out there.",
      br(),br(),
      "You also earn experience points (Exp) when you win fights. Once you have enough Exp, you gain a level, which grants you more HP, Attack, and Defense.",
      br(),br(),
      "Monsters get tougher in the later worlds. Don't be afraid to go back if you need to.",
      br(),br(),
      "The game difficulty can be adjusted dynamically. The default value is 5. Put it up to 10, if you dare.",
      br(),br(),
      "The game ends when you lose interest."
    )
    ,
    mainPanel(    
      h1(textOutput("location")),
      htmlOutput("message"),
      conditionalPanel(condition = "input.EnemyHP > 0",
        actionButton("fight","Fight"),
        actionButton("run","Run")),
      conditionalPanel(condition = "input.EnemyHP <= 0",
        actionButton("explore","Explore"),
        actionButton("rest","Rest"),
        br(),
        uiOutput("weaponButton"),
        uiOutput("armorButton"),
        br(),
        conditionalPanel(condition = "input.WorldNum < input.MaxWorld",
          actionButton("worldup","Next World")
        ),
        conditionalPanel(condition = "input.WorldNum > 1",
          actionButton("worlddown","Previous World")
        )
      )
    ) 
  )
)
