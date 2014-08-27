$(document).ready ->
  app.init()
  window.app = app; # Enable Console Debugging

app =
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
        cost: 2500
        sps: 0
      1:
        name: "Upgrade 1"
        desc: "Lorem Ipsum Dolor Sit Amet ..."
        effect: "+0.2 Shit per second"
        level: 0
        cost: 10
        sps: 0.2
      2:
        name: "Upgrade 2"
        desc: "Lorem Ipsum Dolor Sit Amet ..."
        effect: "+1 Shit per second"
        level: 0
        cost: 45
        sps: 1
      3:
        name: "Upgrade 3"
        desc: "Lorem Ipsum Dolor Sit Amet ..."
        effect: "+3 Shit per second"
        level: 0
        cost: 100
        sps: 3
      4:
        name: "Upgrade 4"
        desc: "Lorem Ipsum Dolor Sit Amet ..."
        effect: "+10 Shit per second"
        level: 0
        cost: 800
        sps: 10
      5:
        name: "Upgrade 5"
        desc: "Lorem Ipsum Dolor Sit Amet ..."
        effect: "+30 Shit per second"
        level: 0
        cost: 1500
        sps: 30
      6:
        name: "Upgrade 6"
        desc: "Lorem Ipsum Dolor Sit Amet ..."
        effect: "+100 Shit per second"
        level: 0
        cost: 5000
        sps: 100

  init: ->
    @bind_events()
    @load_upgrades()
    @load_game()

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
    if localStorage.shitclick_shit != undefined
      savegame = JSON.parse(atob(localStorage["shitclick_savegame"]))
      @game = savegame
      clearInterval(@game.autoclick_interval)
      @autoclick_interval = setInterval (->
        app.add_shit(app.game.sps)
      ), 1000
      @refresh_shit()
      @load_upgrades()

  toggle_upgrades: ->
    $(".upgrades").stop()
    $(".btn-upgrades").toggleClass("entypo-plus").toggleClass("entypo-minus")
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
    @save_game()

  check_prices: ->
    $.each @game.upgrades, (key, value) ->
      if app.game.shit_amount >= app.get_price(value)
        $(".upgrade-"+key+" .btn-buy-upgrade").removeClass("disabled")
      else
        $(".upgrade-"+key+" .btn-buy-upgrade").addClass("disabled")

  get_price: (upgrade) ->
    result = ((upgrade.level + 1) * upgrade.cost) * (upgrade.level + 1)
    if (upgrade.level + 1) > 10
      result *= 2
    result

  refresh_shit: ->
    $(".shit-amount").html(Math.round(@game.shit_amount * 10) / 10)
    $(".sps").html(Math.round(@game.sps * 10) / 10 + " Shit / Second")

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
      @check_prices()
      @refresh_shit()
      @save_game()
      @use_upgrade(upgrade)

  use_upgrade: (upgrade) ->
    switch upgrade
      when 0
        @game.spc = @game.spc + (@game.spc / 2)
      else
        @game.sps += @game.upgrades[upgrade].sps
        clearInterval(@game.autoclick_interval)
        @autoclick_interval = setInterval (->
          app.add_shit(app.game.sps)
        ), 1000
    @refresh_shit()

  load_upgrades: ->
    $(".upgrades").html("")
    $.each @game.upgrades, (key, value) ->
      $(".upgrades").append "<div class='upgrade upgrade-"+key+"' data-upgrade='"+key+"'>" +
          "<h3>"+value.name+"<span>"+value.level+"</span></h3>" +
          "<p class='info'><strong>"+app.get_price(value)+"</strong> — "+value.desc+"</p>" +
          "<div class='btn-buy-upgrade' data-upgrade='"+key+"'>Buy</div>" +
          "<div class='btn-sell-upgrade' data-upgrade='"+key+"'>Sell</div>" +
          "<p class='effect'>"+value.effect+"</p>" +
        "</div>"
    @check_prices()