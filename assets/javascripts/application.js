// Generated by CoffeeScript 1.7.1
(function() {
  var app;

  $(document).ready(function() {
    app.init();
    return window.app = app;
  });

  app = {
    save_interval: "",
    game: {
      shit_amount: 0,
      spc: 1,
      sps: 0,
      autoclick_interval: "",
      upgrades: {
        0: {
          name: "Powershit",
          desc: "Lorem Ipsum Dolor Sit Amet ...",
          effect: "Increase shit per click",
          level: 0,
          cost: 5000,
          sps: 0
        },
        1: {
          name: "Upgrade 1",
          desc: "Lorem Ipsum Dolor Sit Amet ...",
          effect: "+0.2 Shit per second",
          level: 0,
          cost: 20,
          sps: 0.2
        },
        2: {
          name: "Upgrade 2",
          desc: "Lorem Ipsum Dolor Sit Amet ...",
          effect: "+1 Shit per second",
          level: 0,
          cost: 90,
          sps: 1
        },
        3: {
          name: "Upgrade 3",
          desc: "Lorem Ipsum Dolor Sit Amet ...",
          effect: "+3 Shit per second",
          level: 0,
          cost: 250,
          sps: 3
        },
        4: {
          name: "Upgrade 4",
          desc: "Lorem Ipsum Dolor Sit Amet ...",
          effect: "+10 Shit per second",
          level: 0,
          cost: 900,
          sps: 10
        },
        5: {
          name: "Upgrade 5",
          desc: "Lorem Ipsum Dolor Sit Amet ...",
          effect: "+30 Shit per second",
          level: 0,
          cost: 2500,
          sps: 30
        },
        6: {
          name: "Upgrade 6",
          desc: "Lorem Ipsum Dolor Sit Amet ...",
          effect: "+100 Shit per second",
          level: 0,
          cost: 8000,
          sps: 100
        },
        7: {
          name: "Upgrade 7",
          desc: "Lorem Ipsum Dolor Sit Amet ...",
          effect: "+1,000 Shit per second",
          level: 0,
          cost: 70000,
          sps: 1000
        }
      }
    },
    init: function() {
      this.bind_events();
      this.load_upgrades();
      this.load_game();
      return this.autosave();
    },
    bind_events: function() {
      $(document).on("click", ".btn-shit", function(e) {
        app.add_shit(app.game.spc);
        return app.show_amount_added(e, app.game.spc);
      });
      $(document).on("click", ".btn-upgrades", function(e) {
        return app.toggle_upgrades();
      });
      return $(document).on("click", ".btn-buy-upgrade", function(e) {
        return app.buy_upgrade($(this).data("upgrade"));
      });
    },
    save_game: function() {
      return localStorage["shitclick_savegame"] = btoa(JSON.stringify(this.game));
    },
    load_game: function() {
      var savegame;
      savegame = localStorage["shitclick_savegame"] || "";
      if (savegame !== "") {
        savegame = JSON.parse(atob(savegame));
        this.game = savegame;
        if (app.game.sps > 0) {
          this.game.autoclick_interval = setInterval((function() {
            return app.add_shit(app.game.sps / 10);
          }), 100);
        }
        this.refresh_shit();
        this.load_upgrades();
        return console.log("SHITCLICK: Existing game loaded!");
      } else {
        return console.log("SHITCLICK: No existing game found!");
      }
    },
    reset_game: function() {
      clearInterval(this.save_interval);
      clearInterval(this.game.autoclick_interval);
      localStorage.removeItem("shitclick_savegame");
      console.log("SHITCLICK: The game has successfully been resettet!");
      return console.log("SHITCLICK: Please refresh the page!");
    },
    autosave: function() {
      return this.save_interval = setInterval((function() {
        app.save_game();
        return console.log("SHITCLICK: Game saved!");
      }), 5000);
    },
    toggle_upgrades: function() {
      $(".upgrades").stop();
      $(".btn-upgrades").toggleClass("active");
      if ($(".upgrades").data("open") === "no") {
        $(".upgrades").animate({
          top: "0%"
        });
        return $(".upgrades").data("open", "yes");
      } else {
        $(".upgrades").animate({
          top: "150%"
        });
        return $(".upgrades").data("open", "no");
      }
    },
    add_shit: function(amount) {
      this.game.shit_amount += amount;
      this.check_prices();
      return this.refresh_shit();
    },
    check_prices: function() {
      return $.each(this.game.upgrades, function(key, value) {
        if (app.game.shit_amount >= app.get_price(value)) {
          return $(".upgrade-" + key + " .btn-buy-upgrade").removeClass("disabled");
        } else {
          return $(".upgrade-" + key + " .btn-buy-upgrade").addClass("disabled");
        }
      });
    },
    get_price: function(upgrade) {
      var i, result;
      result = upgrade.cost;
      i = 0;
      while (i < upgrade.level) {
        result += result * 0.3;
        i++;
      }
      return Math.round(result);
    },
    refresh_shit: function() {
      var shit;
      shit = this.format_number(this.game.shit_amount);
      $(".shit-amount").html(shit);
      $(".sps").html(this.format_number(this.game.sps) + " Shit / Second");
      return window.document.title = shit + " // Shitclick!";
    },
    format_number: function(n) {
      var d, final, i, n_arr, new_t, t;
      n = Math.round(n * 10) / 10;
      n = n.toString();
      n_arr = n.split(".");
      t = n_arr[0].split("").reverse().join("");
      if (t.length > 3) {
        if (n_arr[1]) {
          d = "." + n_arr[1];
        } else {
          d = "";
        }
        i = 0;
        new_t = "";
        while (i < t.length) {
          new_t += t[i];
          if ((i + 1) % 3 === 0) {
            new_t += ",";
          }
          i++;
        }
        new_t = new_t.split("").reverse().join("");
        if (new_t[0] === ",") {
          new_t = new_t.substring(1);
        }
        return final = new_t + d;
      } else {
        return n;
      }
    },
    show_amount_added: function(e, amount) {
      var info;
      info = $("<span class='amount-added-info'>+" + amount + "</span>");
      info.css("top", e.pageY - 50 + "px");
      info.css("left", e.pageX + "px");
      $("body").append(info);
      return info.animate({
        top: "-=100px",
        opacity: 0
      }, 500, function() {
        return $(this).remove();
      });
    },
    buy_upgrade: function(upgrade) {
      if (this.game.shit_amount >= this.get_price(this.game.upgrades[upgrade])) {
        this.game.shit_amount -= this.get_price(this.game.upgrades[upgrade]);
        this.game.upgrades[upgrade].level++;
        this.load_upgrades();
        this.refresh_shit();
        return this.use_upgrade(upgrade);
      }
    },
    use_upgrade: function(upgrade) {
      switch (upgrade) {
        case 0:
          this.game.spc *= 2;
          break;
        default:
          this.game.sps += this.game.upgrades[upgrade].sps;
          clearInterval(this.game.autoclick_interval);
          this.game.autoclick_interval = setInterval((function() {
            return app.add_shit(app.game.sps / 10);
          }), 100);
      }
      return this.refresh_shit();
    },
    load_upgrades: function() {
      $(".upgrades").html("");
      $.each(this.game.upgrades, function(key, value) {
        return $(".upgrades").append("<div class='upgrade upgrade-" + key + "' data-upgrade='" + key + "'>" + "<h3>" + value.name + "<span>" + value.level + "</span></h3>" + "<p class='info'><strong>" + app.format_number(app.get_price(value)) + "</strong> — " + value.desc + "</p>" + "<div class='btn-buy-upgrade' data-upgrade='" + key + "'>Buy</div>" + "<p class='effect'>" + value.effect + "</p>" + "</div>");
      });
      return this.check_prices();
    }
  };

}).call(this);
