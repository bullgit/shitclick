$(document).ready ->
  app.init()
  window.app = app; # Enable Console Debugging

app =
  save_interval: ""
  game:
    shit_amount: 0
    spc: 1
    sps: 0
    autoclick_interval: ""
    upgrades:
      0:
        name: "Powershit"
        desc: "Lorem Ipsum Dolor Sit Amet ..."
        effect: "Increase shit per click"
        level: 0
        cost: 5000
        sps: 0
      1:
        name: "Upgrade 1"
        desc: "Lorem Ipsum Dolor Sit Amet ..."
        effect: "+0.2 Shit per second"
        level: 0
        cost: 20
        sps: 0.2
      2:
        name: "Upgrade 2"
        desc: "Lorem Ipsum Dolor Sit Amet ..."
        effect: "+1 Shit per second"
        level: 0
        cost: 90
        sps: 1
      3:
        name: "Upgrade 3"
        desc: "Lorem Ipsum Dolor Sit Amet ..."
        effect: "+3 Shit per second"
        level: 0
        cost: 250
        sps: 3
      4:
        name: "Upgrade 4"
        desc: "Lorem Ipsum Dolor Sit Amet ..."
        effect: "+10 Shit per second"
        level: 0
        cost: 900
        sps: 10
      5:
        name: "Upgrade 5"
        desc: "Lorem Ipsum Dolor Sit Amet ..."
        effect: "+30 Shit per second"
        level: 0
        cost: 2500
        sps: 30
      6:
        name: "Upgrade 6"
        desc: "Lorem Ipsum Dolor Sit Amet ..."
        effect: "+100 Shit per second"
        level: 0
        cost: 8000
        sps: 100
      7:
        name: "Upgrade 7"
        desc: "Lorem Ipsum Dolor Sit Amet ..."
        effect: "+1,000 Shit per second"
        level: 0
        cost: 70000
        sps: 1000

  init: ->
    @bind_events()
    @load_upgrades()
    @load_game()
    @autosave()

  bind_events: ->
    $(document).on "click", ".btn-shit", (e) ->
      app.add_shit(app.game.spc)
      app.show_amount_added(e, app.game.spc)

    $(document).on "click", ".btn-upgrades", (e) ->
      app.toggle_upgrades()

    $(document).on "click", ".btn-buy-upgrade", (e) ->
      app.buy_upgrade $(this).data "upgrade"

  save_game: ->
    localStorage["shitclick_savegame"] = btoa(JSON.stringify(@game))

  load_game: ->
    savegame = localStorage["shitclick_savegame"] or ""
    if savegame != ""
      savegame = JSON.parse(atob(savegame))
      @game = savegame
      if app.game.sps > 0
        @game.autoclick_interval = setInterval (->
          app.add_shit(app.game.sps / 10)
        ), 100
      @refresh_shit()
      @load_upgrades()
      console.log "SHITCLICK: Existing game loaded!"
    else
      console.log "SHITCLICK: No existing game found!"

  autosave: ->
    @save_interval = setInterval (->
      app.save_game()
      console.log "SHITCLICK: Game saved!"
    ), 5000

  toggle_upgrades: ->
    $(".upgrades").stop()
    $(".btn-upgrades").toggleClass("active")
    if $(".upgrades").data("open") is "no"
      $(".upgrades").animate
        top: "0%"
      $(".upgrades").data("open", "yes")
    else
      $(".upgrades").animate
        top: "150%"
      $(".upgrades").data("open", "no")

  add_shit: (amount) ->
    @game.shit_amount += amount
    @check_prices()
    @refresh_shit()

  check_prices: ->
    $.each @game.upgrades, (key, value) ->
      if app.game.shit_amount >= app.get_price(value)
        $(".upgrade-"+key+" .btn-buy-upgrade").removeClass("disabled")
      else
        $(".upgrade-"+key+" .btn-buy-upgrade").addClass("disabled")

  get_price: (upgrade) ->
    result = upgrade.cost
    i = 0
    while i < upgrade.level
      result += result * 0.3
      i++
    Math.round(result)

  refresh_shit: ->
    shit = @format_number(@game.shit_amount)
    $(".shit-amount").html(shit)
    $(".sps").html(@format_number(@game.sps) + " Shit / Second")
    window.document.title = shit + " // Shitclick!"

  format_number: (n) ->
    n = Math.round(n * 10) / 10
    n = n.toString()
    n_arr = n.split(".")
    t = n_arr[0].split("").reverse().join("")
    if t.length > 3
      if n_arr[1]
        d = "." + n_arr[1]
      else
        d = ""
      
      i = 0
      new_t = ""
      while i < t.length
        new_t += t[i]
        if (i + 1) % 3 is 0
          new_t += ","
        i++
      new_t = new_t.split("").reverse().join("")
      if new_t[0] is ","
        new_t = new_t.substring(1)
      final = new_t + d
    else
      n

  show_amount_added: (e, amount) ->
    info = $("<span class='amount-added-info'>+"+amount+"</span>")
    info.css "top", e.pageY - 50 + "px"
    info.css "left", e.pageX + "px"
    $("body").append info
    info.animate
      top: "-=100px"
      opacity: 0
    , 500, ->
      $(this).remove()

  buy_upgrade: (upgrade) ->
    if @game.shit_amount >= @get_price(@game.upgrades[upgrade])
      @game.shit_amount -= @get_price(@game.upgrades[upgrade])
      @game.upgrades[upgrade].level++
      @load_upgrades()
      @refresh_shit()
      @use_upgrade(upgrade)

  use_upgrade: (upgrade) ->
    switch upgrade
      when 0
        @game.spc *= 2
      else
        @game.sps += @game.upgrades[upgrade].sps
        clearInterval(@game.autoclick_interval)
        @game.autoclick_interval = setInterval (->
          app.add_shit(app.game.sps / 10)
        ), 100
    @refresh_shit()

  load_upgrades: ->
    $(".upgrades").html("")
    $.each @game.upgrades, (key, value) ->
      $(".upgrades").append "<div class='upgrade upgrade-"+key+"' data-upgrade='"+key+"'>" +
          "<h3>"+value.name+"<span>"+value.level+"</span></h3>" +
          "<p class='info'><strong>"+app.format_number(app.get_price(value))+"</strong> — "+value.desc+"</p>" +
          "<div class='btn-buy-upgrade' data-upgrade='"+key+"'>Buy</div>" +
          # "<div class='btn-sell-upgrade' data-upgrade='"+key+"'>Sell</div>" +
          "<p class='effect'>"+value.effect+"</p>" +
        "</div>"
    @check_prices()