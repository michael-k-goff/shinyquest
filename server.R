library("shiny")

shinyServer(
  function(input, output,clientData,session){
    output$location <- renderText(paste("World",input$WorldNum))
    output$hp <- renderText(paste("HP: ",input$HP,"/", input$MaxHP))
    output$agi <- renderText(paste("Agility: ",input$Agility))
    output$str <- renderText(paste("Attack: (",input$Strength,") ",input$Attack,sep=""))
    output$def <- renderText(paste("Defense: (",input$Stamina,") ",input$Defense,sep=""))
    output$gold <- renderText(paste("Gold: ",input$Gold))
    output$exp <- renderText(paste("Experience: ",input$Exp))
    output$level <- renderText(paste("Level: ",input$Level))
    output$message <- renderText("Happily Exploring")
    output$armorButton <- renderUI({
      actionButton("uparmor", label = "Upgrade Armor: 10 G")
    })
    output$weaponButton <- renderUI({
      actionButton("upweapon", label = "Upgrade Weapon: 10 G")
    })

    observeEvent(input$fight, { # Processing the Fight command
      # Calculate the player damage
      max_dmg <- 2+input$Attack / 3
      dmg <- sample(floor(max_dmg/2):floor(max_dmg),1)
      new_enemy_hp <- input$EnemyHP - dmg
      updateNumericInput(session,"EnemyHP",value=new_enemy_hp)
      report <- c("You did ",dmg," damage.<br>")
      
      if (new_enemy_hp <= 0) { # Process victory, if appropriate
        exp_gain <- input$WorldNum*input$WorldNum - 2*input$WorldNum + 2
        gold_gain <- input$WorldNum
        new_exp <- input$Exp + exp_gain
        updateNumericInput(session,"Exp",value=new_exp)
        updateNumericInput(session,"Gold",value=input$Gold + gold_gain)
        report <- c(report,c("You won!<br>Gained ",exp_gain, " EXP.<br>Gained ", gold_gain, " Gold.<br>"))
        new_explore <- input$NumExplore+1
        updateNumericInput(session,"NumExplore",value = new_explore)
        if (new_explore >= 10 && input$MaxWorld == input$WorldNum) {
          updateNumericInput(session,"MaxWorld",value=input$MaxWorld + 1)
        }
        
        if (new_exp >= 2*(input$Level+1)^3 - 9) { # Level gain, if appropriate
          nl <- input$Level + 1
          updateNumericInput(session,"Level",value=input$Level + 1)
          hp_gain <- sample(nl:floor(1.5*nl),1)
          updateNumericInput(session,"MaxHP",value=input$MaxHP + hp_gain)
          updateNumericInput(session,"HP",value=input$HP + hp_gain)
          str_gain <- sample(floor(0.5*nl):floor(nl),1)
          updateNumericInput(session,"Strength",value=input$Strength + str_gain)
          updateNumericInput(session,"Attack",value=input$Attack + str_gain)
          def_gain <- sample(floor(0.5*nl):floor(nl),1)
          updateNumericInput(session,"Stamina",value=input$Defense + def_gain)
          updateNumericInput(session,"Defense",value=input$Stamina + def_gain)
          report <- c(report,c("Gained a Level!<br>HP up by ",hp_gain,".<br>Strength up by ",str_gain,".<br>Stamina up by ",def_gain,"."))
        }
      }
      else { # The enemy survived and here attacks
        max_dmg <- (2+input$WorldNum*input$WorldNum - input$Defense / 6)*(5+input$difficulty)/10
        if (max_dmg < 0) {max_dmg = 0}
        enemy_dmg <- sample(floor(max_dmg/2):floor(max_dmg),1)
        new_hp <- input$HP - enemy_dmg
        updateNumericInput(session,"HP",value=new_hp)
        report <- c(report, c("Monster attacked for ",enemy_dmg," damage."))
        
        if (new_hp <= 0) { # Process player death, if that occurs
          report <- c(report,c("You lost."))
          updateNumericInput(session,"EnemyHP",value=0)
          updateNumericInput(session,"HP",value=input$MaxHP)
          updateNumericInput(session,"Gold",value=0)
          updateNumericInput(session,"NumExplore",value = 0)
        }
      }
      
      output$message <- renderText(paste(report,collapse="",sep=""))
    })
    observeEvent(input$explore, {
      enemyHP = floor((3+3*input$WorldNum*input$WorldNum)*(5+input$difficulty)/10)
      updateNumericInput(session,"EnemyHP",value = enemyHP)
      output$message <- renderText("You have encountered a monster.")
    })
    observeEvent(input$run,{
      updateNumericInput(session,"EnemyHP",value = 0)
      output$message <- renderText("Phew.  Just escaped.")
    })
    observeEvent(input$rest,{
      updateNumericInput(session,"HP",value = input$MaxHP)
      updateNumericInput(session,"NumExplore",value = 0)
      output$message <- renderText("All rested up.")
    })
    observeEvent(input$upweapon,{
      wpn_level <- input$Weapon
      cost <- 10*(wpn_level + 1)
      if (input$Gold >= cost) {
        updateNumericInput(session,"Weapon",value = wpn_level+1)
        output$weaponButton <- renderUI({
          actionButton("upweapon", label = paste("Upgrade Weapon: ",10*(wpn_level+2), " G"))
        })
        updateNumericInput(session,"Gold",value = input$Gold - cost)
        updateNumericInput(session,"Attack",value = input$Attack + wpn_level + 1)
        output$message <- renderText("Shiny new weapon.")
      }
      else {
        output$message <- renderText("Not enough gold.")
      }
    })
    observeEvent(input$uparmor,{
      wpn_level <- input$Armor
      cost <- 10*(wpn_level + 1)
      if (input$Gold >= cost) {
        updateNumericInput(session,"Armor",value = wpn_level+1)
        output$armorButton <- renderUI({
          actionButton("uparmor", label = paste("Upgrade Armor: ",10*(wpn_level+2), " G"))
        })
        updateNumericInput(session,"Gold",value = input$Gold - cost)
        updateNumericInput(session,"Defense",value = input$Defense + wpn_level + 1)
        output$message <- renderText("Shiny new armor.")
      }
      else {
        output$message <- renderText("Not enough gold.")
      }
    })
    observeEvent(input$worlddown, {
      updateNumericInput(session,"WorldNum",value=input$WorldNum-1)
    })
    observeEvent(input$worldup, {
      updateNumericInput(session,"WorldNum",value=input$WorldNum+1)
    })
  }
)
